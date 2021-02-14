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

@end

@implementation WifiManager

-(void)getWifList:(void (^)(id res)) callback {
    self.callback = callback;
    
    if(!self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(self.callback){
        
        if (status == kCLAuthorizationStatusDenied) {
            self.callback(nil);
        }
        else if (status == kCLAuthorizationStatusAuthorized) {
            NSString *wifiName = nil;
            NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
            for (NSString *ifnam in ifs) {
                NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
                if (info[@"SSID"]) {
                    wifiName = info[@"SSID"];
                }
            }
            
            // Get the dictionary containing the captive network infomation
            CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(kCNNetworkInfoKeySSID);

            // Get the count of the key value pairs to test if it has worked
            int count = CFDictionaryGetCount(captiveNtwrkDict);
            
            CFArrayRef myArray = CNCopySupportedInterfaces();
            CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
            self.callback(nil);
        }
        
        self.callback = nil;
    }
    
}


@end
