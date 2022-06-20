//
//  DevilBle.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/21.
//

#import "DevilBle.h"
@import UIKit;
@import MediaPlayer;
#import <CoreBluetooth/CoreBluetooth.h>
#import "Jevil.h"
#import "DevilDebugView.h"

@interface DevilBle () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property void (^callbackList)(id res);
@property void (^callbackConnect)(id res);
@property void (^callbackDisconnect)(id res);
@property void (^callbackAdvertise)(id res);
@property void (^callbackRead)(id res);

@property NSTimeInterval startScanSec;
@property float scanSec;

@property (nonatomic, retain) id characteristics;
@property (nonatomic, retain) CBCentralManager* cbmanager;
@property (nonatomic, retain) id blue_list;

@end


@implementation DevilBle

+ (DevilBle*)sharedInstance {
    static DevilBle *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance inititalize];
    });
    return sharedInstance;
}

- (void)inititalize {
    self.blue_list = [@[] mutableCopy];
    self.characteristics = [@{} mutableCopy];
    self.cbmanager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)list:(id)param :(void (^)(id res))callback{
    self.callbackList = callback;
    if(param[@"sec"])
        self.scanSec = [param[@"sec"] floatValue];
    else
        self.scanSec = 10;
    self.startScanSec = [[NSDate date] timeIntervalSince1970];
    [self performSelector:@selector(scan) withObject: nil afterDelay:0.5f];
}

- (void)scan {
    if (self.cbmanager.state == CBManagerStatePoweredOff){
        [Jevil alert:@"abc"];
//        [self showBluetoothSettingAlert];
        if(self.callbackList) {
            self.callbackList(@{
                @"r":@FALSE,
            });
        }
    } else {
        [self.blue_list removeAllObjects];
//        [self.characteristics removeAllObjects];
        [self.cbmanager scanForPeripheralsWithServices:@[] options:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    //발견한 장치를 logging
    /**
     advertisementData 샘플
     {
         kCBAdvDataIsConnectable = 1;
         kCBAdvDataLocalName = "[TV] Samsung 8 Series (65)";
         kCBAdvDataManufacturerData = {length = 26, bytes = 0x75004204 01206f17 07000000 00000000 ... 00000000 00000000 };
         kCBAdvDataRxPrimaryPHY = 1;
         kCBAdvDataRxSecondaryPHY = 0;
         kCBAdvDataTimestamp = "675832519.907693";
     }
     */
    NSString* udid = [peripheral.identifier description];
    
    BOOL already = false;
    for(id b in self.blue_list) {
        CBPeripheral* ble = (CBPeripheral*)b;
        if([[ble.identifier description] isEqualToString:udid]) {
            already = true;
            break;
        }
    }
    if(!already) {
        NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
        [self.blue_list addObject:peripheral];
        
        if(self.callbackList) {
            self.callbackList([@{
                @"r":@TRUE,
                @"list":[self bleListArray]
            } mutableCopy]);
        }
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if(now - self.startScanSec > self.scanSec) {
        [self.cbmanager stopScan];
    }
}

- (void)bleRelease {
    for(CBPeripheral* ble in self.blue_list) {
        if(ble.state == CBPeripheralStateConnected || ble.state == CBPeripheralStateConnecting)
            [self.cbmanager cancelPeripheralConnection:ble];
    }
}

- (void)disconnect:(NSString*)udid :(void (^)(id res))callback {
    CBPeripheral* device = nil;
    for(CBPeripheral* b in self.blue_list) {
        NSString* thisUdid = [b.identifier description];
        if([thisUdid isEqualToString:udid]) {
            device = b;
            break;
        }
    }
    
    if(!device) {
        callback(@{@"r":@FALSE, @"msg":@"No Device"});
        return;
    }
    
    NSLog(@"try disconnect :%@",device.name);
    [self.cbmanager cancelPeripheralConnection:device];
}

- (void)connect:(NSString*)udid :(void (^)(id res))callback{
    CBPeripheral* device = nil;
    for(CBPeripheral* b in self.blue_list) {
        NSString* thisUdid = [b.identifier description];
        if([thisUdid isEqualToString:udid]) {
            device = b;
            break;
        }
    }
    
    if(!device) {
        callback(@{@"r":@FALSE, @"msg":@"No Device"});
        return;
    }
    
    NSLog(@"try connect :%@",device.name);
    [_cbmanager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
    device.delegate = self;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if(self.callbackConnect) {
        NSString* udid = [peripheral.identifier description];
        NSString* name = [self nameFromDevice:peripheral];
        self.callbackConnect(@{
            @"udid":udid,
            @"name":name,
            @"list":[self bleListArray],
        });
        
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_BLUETOOTH title:@"connected" log:@{
            @"udid":udid,
            @"name":name,
        }];
    }
    [peripheral discoverServices:@[]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if(self.callbackDisconnect) {
        NSString* udid = [peripheral.identifier description];
        NSString* name = [self nameFromDevice:peripheral];
        self.callbackDisconnect(@{
            @"udid":udid,
            @"name":name,
            @"list":[self bleListArray],
        });
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_BLUETOOTH title:@"disconnected" log:@{
            @"udid":udid,
            @"name":name,
        }];
    }
}


- (void)send:(NSString*)udid :(NSString*)hexString :(void (^)(id res))callback {
    CBPeripheral* device = nil;
    for(CBPeripheral* b in self.blue_list) {
        NSString* thisUdid = [b.identifier description];
        if([thisUdid isEqualToString:udid]) {
            device = b;
            break;
        }
    }
    
    if(!device || !self.characteristics[udid]) {
        callback(@{@"r":@FALSE, @"msg":@"No Connected Device"});
        return;
    }
    
    id cs = self.characteristics[udid];
    NSData* data = [self fromHexString:hexString];
    for(CBCharacteristic* c in cs) {
        [device writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
    }
    
    NSString* name = [self nameFromDevice:device];
    [[DevilDebugView sharedInstance] log:DEVIL_LOG_BLUETOOTH title:@"write" log:@{
        @"udid":udid,
        @"name":name,
        @"data":hexString,
    }];
}

- (void)callback:(NSString*)command :(void (^)(id res))callback{
    if([@"connected" isEqualToString:command]) {
        self.callbackConnect = callback;
    } else if([@"advertise" isEqualToString:command]) {
        self.callbackAdvertise = callback;
    } else if([@"read" isEqualToString:command]) {
        self.callbackRead = callback;
    } else if([@"disconnected" isEqualToString:command]) {
        self.callbackDisconnect = callback;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if(central.state == CBManagerStateUnknown){
    } else if(central.state == CBManagerStateResetting){
    } else if(central.state == CBManagerStateUnsupported){
    } else if(central.state == CBManagerStateUnauthorized){
    } else if(central.state == CBManagerStatePoweredOff){
    } else if(central.state == CBManagerStatePoweredOn){
        
    }
}

- (void)showBluetoothSettingAlert {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=Bluetooth"] options:@{} completionHandler:nil];
}

- (void)destroy{
    if(self.cbmanager != nil) {
        [self.cbmanager stopScan];
        self.cbmanager = nil;
        self.callbackConnect = nil;
        self.callbackRead = nil;
        self.callbackAdvertise = nil;
        self.callbackDisconnect = nil;
        self.callbackList = nil;
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error != nil) {
        NSLog(@"discoverServices error : peripheral: %@, error: %@",peripheral.name,error.debugDescription);
    } else {
        for (CBService *service in peripheral.services) {
            NSLog(@"discoverd service : %@",service.debugDescription);
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSString* udid = [peripheral.identifier description];
    self.characteristics[udid] = service.characteristics;
    for (CBCharacteristic *charater in service.characteristics) {
        NSLog(@"discovered Characteristic :%@",charater.debugDescription);
        peripheral.delegate = self;
        [peripheral setNotifyValue:YES forCharacteristic:charater];
        [peripheral readValueForCharacteristic:charater];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    NSLog(@"didUpdateValueForCharacteristic");
    if(characteristic.value.length > 0) {
        NSString* udid = [peripheral.identifier description];
        NSString* name = [self nameFromDevice:peripheral];
        id json = @{
            @"udid":udid,
            @"name":name,
            @"value":[self hexString:characteristic.value],
        };
        [[DevilDebugView sharedInstance] log:DEVIL_LOG_BLUETOOTH title:@"read" log:json];
        
        if(self.callbackRead) {
            self.callbackRead(json);
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error{
    NSLog(@"peripheral didReadRSSI");
}


- (NSString *) hexString : (NSData*)data
{
    NSUInteger bytesCount = data.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = data.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        if (chars == NULL) {
            // malloc returns null if attempting to allocate more memory than the system can provide. Thanks Cœur
            [NSException raise:NSInternalInconsistencyException format:@"Failed to allocate more memory" arguments:nil];
            return nil;
        }
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

- (NSData*) fromHexString : (NSString*)command{
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    NSLog(@"%@", commandToSend);
    return commandToSend;
}


- (NSMutableArray*) bleListArray {
    id list = [@[] mutableCopy];
    for(id b in self.blue_list) {
        CBPeripheral* ble = (CBPeripheral*)b;
        NSString *thisName = [self nameFromDevice:ble];
        
        NSString *thisUdid = [ble.identifier description];
        
        NSString* state = @"unknown";
        if(ble.state == CBPeripheralStateConnected)
            state = @"connected";
        else if(ble.state == CBPeripheralStateConnecting)
            state = @"connecting";
        else if(ble.state == CBPeripheralStateDisconnecting)
            state = @"disconnecting";
        else if(ble.state == CBPeripheralStateDisconnected)
            state = @"disconnected";
        
        [list addObject:
             [@{
                @"name":thisName,
                @"udid":thisUdid,
                @"status":state,
             } mutableCopy]
        ];
    }
    
    return list;
}

-(NSString*) nameFromDevice:(CBPeripheral*)ble {
    NSString *thisName = @"";
    if(ble.name)
        thisName = [ble.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return thisName;
}

@end
