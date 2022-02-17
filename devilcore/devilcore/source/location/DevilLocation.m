//
//  DevilLocation.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/22.
//

#import "DevilLocation.h"
#import "WildCardConstructor.h"
#import "DevilUtil.h"

@interface DevilLocation () <CLLocationManagerDelegate>

@property void (^callback)(id result);
@property (nonatomic, retain) CLLocationManager* locationManager;
@property BOOL place;

@end

@implementation DevilLocation

+ (DevilLocation*)sharedInstance {
    static DevilLocation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (void) initLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
}

- (void)unrequestLocationUpdate{
    if(self.locationManager != nil){
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)getCurrentLocation:(void (^)(id result))callback{
    self.place = NO;
    self.callback = callback;
    [self startLocation];
}
- (void)getCurrentPlace:(void (^)(id result))callback{
    self.place = YES;
    self.callback = callback;
    [self startLocation];
}

- (void)startLocation{
    if(self.locationManager == nil) {
        [self initLocationManager];
    }
    if(CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
       CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse ||
       CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized){
        [self.locationManager startUpdatingLocation];
    } else{
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        if(self.callback != nil) {
            self.callback(@{@"r":@FALSE, @"msg":@"No Authrization"});
            self.callback = nil;
        }
    }
    else if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
             status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations API_AVAILABLE(ios(6.0), macos(10.9)){
    
    if(self.callback != nil) {
        if(self.place) {
            NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
            id dict = [NSDictionary dictionaryWithContentsOfFile:path];
            
            NSString* api_key = dict[@"google_place_api_key"];
            NSString* lang = @"ko";
            NSString* url = [NSString stringWithFormat:
                             @"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@&language=%@",
                             locations[0].coordinate.latitude,
                             locations[0].coordinate.longitude,
                             api_key,
                             lang
                             ];
            if(api_key == nil) {
                self.callback(@{@"r":@FALSE, @"msg":@"google_place_api_key is not exists"});
                self.callback = nil;
                return;
            }
            
            [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:@{} success:^(NSMutableDictionary *res) {
                
                id r = [@{} mutableCopy];
                
                if(!res){
                    r[@"r"] = @FALSE;
                    r[@"msg"] = @"Network not available";
                } else {
                    id results = res[@"results"];
                    if([results count] > 0){
                        id address_components = results[0][@"address_components"];
                        for(id result in results) {
                            id types = result[@"types"];
                            BOOL found = false;
                            for(id type in types){
                                if([type isEqualToString:@"postal_code"]){
                                    found = true;
                                    address_components = result[@"address_components"];
                                    break;
                                }
                            }
                            
                            if(found)
                                break;
                        }
                        
                        NSString* address1 = @"";
                        NSString* address2 = @"";
                        NSString* address3 = @"";
                        NSString* address4 = @"";
                        for(int i=(int)[address_components count]-1;i>=0;i--){
                            if([address_components[i][@"types"] containsObject:@"administrative_area_level_1"]){
                                address1 = address_components[i][@"short_name"];
                                if(i-1 >= 0)
                                    address2 = address_components[i-1][@"short_name"];
                                if(i-2 >= 0)
                                    address3 = address_components[i-2][@"short_name"];
                                if(i-3 >= 0 && [address_components[i-3][@"types"] containsObject:@"sublocality"])
                                    address4 = address_components[i-3][@"short_name"];
                                break;
                            }
                        }
                        
                        r[@"r"] = @TRUE;
                        r[@"address1"] = address1;
                        r[@"address2"] = address2;
                        r[@"address3"] = address3;
                        r[@"address4"] = address4;
                        r[@"lat"] = [NSNumber numberWithDouble:locations[0].coordinate.latitude];
                        r[@"lng"] = [NSNumber numberWithDouble:locations[0].coordinate.longitude];
                    }
                }
                
                if(self.callback != nil){
                    self.callback(r);
                    self.callback = nil;
                }
            }];
        } else {
            self.callback(@{@"r":@TRUE,
                            @"lat":[NSNumber numberWithDouble:locations[0].coordinate.latitude],
                            @"lng":[NSNumber numberWithDouble:locations[0].coordinate.longitude]
                          });
            self.callback = nil;
        }
    }
    
    //[self placeApiLat:locations[0].coordinate.latitude lon:locations[0].coordinate.longitude];
    
    [self unrequestLocationUpdate];
}


- (void)search:(NSString*)keyword :(void (^)(id result))callback{
    self.callback = callback;
    UIDevice *device = [UIDevice currentDevice];
    NSString* udid = [[device identifierForVendor] UUIDString];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* api_key = dict[@"google_place_api_key"];
    NSString* lang = @"ko";
    NSString* url = [NSString stringWithFormat:
                     @"https://maps.googleapis.com/maps/api/place/autocomplete/json?language=%@&key=%@&types=geocode&input=%@&sessiontoken=%@",
                     lang,
                     api_key,
                     urlencode(keyword),
                     udid
                     ];
    if(api_key == nil) {
        self.callback(@{@"r":@FALSE, @"msg":@"google_place_api_key is not exists"});
        self.callback = nil;
        return;
    }
    
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:@{} success:^(NSMutableDictionary *res) {
        id r = [@{} mutableCopy];
        
        if(!res){
            r[@"r"] = @FALSE;
            r[@"msg"] = @"Network not available";
        } else {
            id predictions = res[@"predictions"];
            id list = [@[] mutableCopy];
            for(id prediction in predictions){
                id terms = prediction[@"terms"];
                if([terms count] < 3)
                    continue;
                
                id types = prediction[@"types"];
                if(![types containsObject:@"sublocality_level_2"])
                    continue;
                
                NSString* address = @"";
                int index = 0;
                id j = [@{} mutableCopy];
                
                for(int i=[terms count]-2;i>=0;i--){
                    
                    if(![address isEqualToString:@""])
                        address = [address stringByAppendingString:@" "];
                    address = [address stringByAppendingString:terms[i][@"value"]];
                    
                    if(index == 0)
                        j[@"address1"] = terms[i][@"value"];
                    if(index == 1)
                        j[@"address2"] = terms[i][@"value"];
                    if(index == 2)
                        j[@"address3"] = terms[i][@"value"];
                    if(index == 3)
                        j[@"address4"] = terms[i][@"value"];
                    index++;
                }
                
                j[@"terms"] = terms;
                j[@"address"] = address;
                [list addObject:j];
            }
        
            r[@"r"] = @TRUE;
            r[@"list"] = list;
        }
        
        if(self.callback != nil){
            self.callback(r);
            self.callback = nil;
        }
    }];
}

@end
