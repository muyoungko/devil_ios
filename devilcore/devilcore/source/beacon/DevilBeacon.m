//
//  DevilBeacon.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/08/27.
//

#import "DevilBeacon.h"

@interface DevilBeacon()

@property (nonatomic, retain) CBPeripheral* selectedDevice;
@property (nonatomic, retain) CBCharacteristic *characteristic;
@property (nonatomic, retain) id setting_list;
@property (nonatomic, retain) id found;
@property (nonatomic, retain) CBCentralManager* cbmanager;

@property void (^completeCallback)(id res);
@property void (^foundCallback)(id res);

@end

@implementation DevilBeacon
+ (DevilBeacon*)sharedInstance {
    static DevilBeacon *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void)scan:(id)param complete:(void (^)(id res))completeCallback found:(void (^)(id res))foundCallback {
    self.completeCallback = completeCallback;
    self.foundCallback = foundCallback;
    
    if(!self.cbmanager) {
        self.cbmanager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    self.found = [@{} mutableCopy];
    
    if (self.cbmanager.state == CBManagerStatePoweredOn){
        [self.found removeAllObjects];
        [self.cbmanager scanForPeripheralsWithServices:@[] options:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        if(self.completeCallback) {
            self.completeCallback(@{@"r":@TRUE});
        }
    }
}
- (void)stop {
    if (self.cbmanager) {
        [self.cbmanager stopScan];
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

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    //발견한 장치를 logging
    NSLog(@"Discovered %@ %@ at %@", peripheral.name, advertisementData, RSSI);
    
    //내 프로젝트에서는 특정 장비만 지원하는 Fido asm의 역할을 수행하기 때문에 필터링을 한다.
    NSString *name = [peripheral.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *mac = [peripheral identifier].description;
    
    CBPeripheral *discovered = [peripheral copy];
    
    if([self.found objectForKey:mac] == nil) {
        [self.found setObject:discovered forKey:mac];
        if(self.foundCallback) {
            self.foundCallback(@{@"r":@TRUE, @"mac":mac});
        }
    }
}

@end
