//
//  WifiManager.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/14.
//
@import SystemConfiguration.CaptiveNetwork;

#import "WifiManager.h"

@interface WifiManager()

@property (nonatomic, retain) CLLocationManager* locationManager;
@property void (^callback)(id res);
@property BOOL released;

@end

@implementation WifiManager

-(void)connect:(NSString*)ssid :(void (^)(id res)) callback {
    self.callback = callback;
    self.released = false;
    [self performSelector:@selector(connectCore:) withObject:ssid afterDelay:1];
}

-(void)connectCore:(NSString*)ssid {
    if(!self.released){
        NSString *currentWifiSSID = nil;
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *ifnam in ifs) {
            NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (info[@"SSID"]) {
                currentWifiSSID = info[@"SSID"];
            }
        }
        
        if(currentWifiSSID != nil && [ssid isEqualToString:currentWifiSSID]){
            if(self.callback != nil){
                self.callback(@{@"r":@TRUE});
                self.callback = nil;
            }
        } else
            [self performSelector:@selector(connectCore:) withObject:ssid afterDelay:1];
    }
}

-(void)getWifList:(void (^)(id res)) callback {
    self.callback = callback;
    
    if(!self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied ||
       CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined){
        [self.locationManager requestWhenInUseAuthorization];
    } else {
        [self getWifiListCore];
    }
}

- (void) getWifiListCore {
    if(self.callback){
        NSString *currentWifiSSID = nil;
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *ifnam in ifs) {
            NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (info[@"SSID"]) {
                currentWifiSSID = info[@"SSID"];
            }
        }
        
        // Get the dictionary containing the captive network infomation
        id r = [@{} mutableCopy];
        r[@"list"] = [@[] mutableCopy];
        
        if(currentWifiSSID){
            [r[@"list"] addObject:[@{
                @"ssid":currentWifiSSID
            } mutableCopy]];
        }
        
        self.callback(r);
        self.callback = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(self.callback){
        
        if (status == kCLAuthorizationStatusDenied) {
            self.callback([NSNull null]);
            self.callback = nil;
        }
        else if (status == kCLAuthorizationStatusAuthorized) {
            [self getWifiListCore];
        }
    }
    
}

-(void)dismiss {
    self.released = true;
}

@end
