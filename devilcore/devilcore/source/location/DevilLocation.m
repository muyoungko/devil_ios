//
//  DevilLocation.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/05/22.
//

#import "DevilLocation.h"
#import "WildCardConstructor.h"
#import "DevilUtil.h"
#import "DevilExceptionHandler.h"

@interface DevilLocation () <CLLocationManagerDelegate>

@property void (^callback)(id result);
@property (nonatomic, retain) CLLocationManager* locationManager;
@property BOOL place;
@property (nonatomic, retain) NSString* placeType;

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
- (void)getCurrentPlace:(id)param :(void (^)(id result))callback{
    self.place = YES;
    self.placeType = param[@"type"];
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

- (void)placeApiWithGoogle:(double)lat :(double)lng {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString* api_key = dict[@"google_place_api_key"];
    NSString* lang = @"ko";
    NSString* url = [NSString stringWithFormat:
                     @"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@&language=%@",
                     lat,
                     lng,
                     api_key,
                     lang
                     ];
    if(api_key == nil) {
        self.callback(@{@"r":@FALSE, @"msg":@"google_place_api_key is not exists"});
        self.callback = nil;
        return;
    }
    
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:@{@"X-Ios-Bundle-Identifier":[[NSBundle mainBundle] bundleIdentifier]} success:^(NSMutableDictionary *res) {
        
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
                r[@"lat"] = [NSNumber numberWithDouble:lat];
                r[@"lng"] = [NSNumber numberWithDouble:lng];
            }
        }
        
        if(self.callback != nil){
            self.callback(r);
            self.callback = nil;
        }
    }];
}

- (void)dongApiWithKakao:(double)lat :(double)lng {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id dict = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSString* api_key = dict[@"KakaoRestKey"];
    NSString* url = [NSString stringWithFormat:
                     @"https://dapi.kakao.com/v2/local/geo/coord2address.json?x=%f&y=%f&input_coord=WGS84",
                     lng,
                     lat
                     ];
    if(api_key == nil) {
        self.callback(@{@"r":@FALSE, @"msg":@"KakaoRestKey is not exists"});
        self.callback = nil;
        return;
    }
    
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:@{
        @"Authorization":[NSString stringWithFormat:@"KakaoAK %@", api_key]
    } success:^(NSMutableDictionary *res) {
        
        id r = [@{} mutableCopy];
        
        if(!res){
            r[@"r"] = @FALSE;
            r[@"msg"] = @"Network not available";
        } else {
            id results = res[@"documents"];
            if([results count] > 0){
                id address = results[0][@"address"];
                r[@"r"] = @TRUE;
                r[@"address1"] = address[@"region_1depth_name"];
                r[@"address2"] = address[@"region_2depth_name"];
                if(address[@"region_3depth_name"])
                    r[@"address3"] = address[@"region_3depth_name"];
                if(address[@"region_4depth_name"])
                    r[@"address4"] = address[@"region_4depth_name"];
                r[@"address_name"] = address[@"address_name"];
                NSString* url2 = [NSString stringWithFormat:
                                 @"https://dapi.kakao.com/v2/local/search/address.json?query=%@",
                                 urlencode(r[@"address_name"])
                                 ];
                [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url2 header:@{
                    @"Authorization":[NSString stringWithFormat:@"KakaoAK %@", api_key]
                } success:^(NSMutableDictionary *res) {
                    id results = res[@"documents"];
                    if([results count] > 0){
                        id dong = results[0];
                        r[@"lat"] = [NSNumber numberWithDouble:[dong[@"y"] doubleValue]];
                        r[@"lng"] = [NSNumber numberWithDouble:[dong[@"x"] doubleValue]];
                    }
                    
                    if(self.callback != nil){
                        self.callback(r);
                        self.callback = nil;
                    }
                }];
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations API_AVAILABLE(ios(6.0), macos(10.9)){
    
    if(self.callback != nil) {
        if(self.place) {
            double lat = locations[0].coordinate.latitude;
            double lng = locations[0].coordinate.longitude;
            if([@"kakao" isEqualToString:self.placeType])
                [self dongApiWithKakao:lat:lng];
            else
                [self placeApiWithGoogle:lat:lng];
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


- (void)searchKoreanDongWithKakao:(NSString*)keyword :(void (^)(id result))callback{
    self.callback = callback;
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id devilConfig = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSString* KakaoRestKey = devilConfig[@"KakaoRestKey"];
    if(!KakaoRestKey){
        self.callback(@{@"r":@FALSE, @"msg":@"KakaoRestKey is null"});
        self.callback = nil;
        return;
    }
    
    NSString* url = [NSString stringWithFormat:
                     @"https://dapi.kakao.com/v2/local/search/address.json?query=%@",
                     urlencode(keyword)
                     ];
    NSString* Authorization = [NSString stringWithFormat:@"KakaoAK %@", KakaoRestKey];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequestGet:url header:@{@"Authorization": Authorization} success:^(NSMutableDictionary *res) {
        id r = [@{} mutableCopy];
        
        if(!res || ![res isKindOfClass:[NSDictionary class]]){
            r[@"r"] = @FALSE;
            r[@"msg"] = @"Network not available or Kakao Authorization is failed. Check Key";
        } else {
            id dd = res[@"documents"];
            id list = [@[] mutableCopy];
            for(id d in dd) {
                id j = [@{} mutableCopy];
                j[@"address"] = d[@"address_name"];
                j[@"address1"] = d[@"address"][@"region_1depth_name"];
                j[@"address2"] = d[@"address"][@"region_2depth_name"];
                j[@"address3"] = d[@"address"][@"region_3depth_h_name"];
                j[@"address4"] = d[@"address"][@"region_3depth_name"];
                if(!empty(j[@"address3"]) || !empty(j[@"address4"]))
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
