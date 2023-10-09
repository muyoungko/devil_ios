//
//  DevilGoogleMapMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/10/04.
//

#import "DevilGoogleMapMarketComponent.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"

@import GoogleMaps;
@import GoogleMapsUtils;


@interface DevilGoogleMapMarketComponent() <GMSMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, retain) GMSMapView* mapView;
@property (nonatomic, retain) NSMutableDictionary* markerDic;
@property (nonatomic, retain) NSMutableDictionary* circleDic;
@property (nonatomic, assign) float zoom;
@property BOOL consumeStartLocation;
@property (nonatomic, copy) void (^markerClick)(id);
@property (nonatomic, copy) void (^mapClick)(id);
@property (nonatomic, copy) void (^camera)(id);
@property (nonatomic, copy) void (^dragStart)(id);
@property (nonatomic, copy) void (^dragEnd)(id);



@end

@implementation DevilGoogleMapMarketComponent

-(void)initialized {
    [super initialized];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* api_key = dict[@"GoogleMapKey"];
    [GMSServices provideAPIKey:api_key];
    self.markerDic = [NSMutableDictionary dictionary];
    self.circleDic = [NSMutableDictionary dictionary];
    self.zoom = 14;
    self.consumeStartLocation = false;

}

-(void)created{
    [super created];
}

-(CLLocationCoordinate2D) currentLocation {
    //위치 매니저를 생성하고 현재 위치를 받아옵니다.
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate =self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];

    CLLocation *location = [locationManager location];
    return [location coordinate];
}

-(void)update:(id)opt{
    [super update:opt];
    if(!self.consumeStartLocation) {
        CLLocationCoordinate2D position = [self currentLocation];
        self.consumeStartLocation = true;
        id start_location_path = self.marketJson[@"select3"];
        id start_location = [MappingSyntaxInterpreter getJsonWithPath:opt : start_location_path];
        if(start_location) {
            double lat = [start_location[@"lat"] doubleValue];
            double lng = [start_location[@"lng"] doubleValue];
            if(start_location[@"zoom"])
                self.zoom = [start_location[@"zoom"] intValue];
            
            position = CLLocationCoordinate2DMake(lat, lng);
        }
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:position.latitude
                                                                longitude:position.longitude
                                                                     zoom:self.zoom];
        self.mapView = [[GMSMapView alloc] initWithFrame: CGRectZero camera:camera];
        self.mapView.delegate = self;
        self.mapView.myLocationEnabled = NO;
        [self.vv addSubview:self.mapView];
        [WildCardConstructor followSizeFromFather:self.vv child:self.mapView];
        [WildCardConstructor userInteractionEnableToParentPath:self.mapView depth:5];
        
    }
}


-(void)camera:(id)param{

    if ([param objectForKey:@"zoom"] != nil) {
        self.zoom = [[param objectForKey:@"zoom"] floatValue];
    }

    NSString* strLat = [NSString stringWithFormat:@"%@", param[@"lat"]];
    NSString* strLogi = [NSString stringWithFormat:@"%@", param[@"lng"]];
    CLLocationDegrees latitude = [strLat doubleValue];
    CLLocationDegrees longitude = [strLogi doubleValue];

    GMSCameraPosition *newPosition = [GMSCameraPosition cameraWithLatitude:latitude
            longitude:longitude
            zoom:self.zoom];

    [self.mapView animateToCameraPosition:newPosition];
}

-(void)addMarker:(id)param{
    NSString* strKey = [NSString stringWithFormat:@"%@", param[@"key"]];
    NSString* strLat = [NSString stringWithFormat:@"%@", param[@"lat"]];
    NSString* strLogi = [NSString stringWithFormat:@"%@", param[@"lng"]];
    NSString* type = param[@"type"];
    NSString* title = param[@"title"];
    CLLocationDegrees latitude = [strLat doubleValue];
    CLLocationDegrees longitude = [strLogi doubleValue];

    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(latitude, longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    
    marker.draggable = [param[@"draggable"] boolValue];
    //marker.icon = [UIImage imageNamed:@"pin.png"];
    
    if([@"bubble" isEqualToString:type]) {
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        infoView.backgroundColor = [UIColor whiteColor];

        // 라벨을 추가하여 텍스트를 표시합니다.
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 80)];
        label.text = title;
        label.numberOfLines = 0; // 여러 줄의 텍스트를 표시하려면 0으로 설정합니다.
        [infoView addSubview:label];

        // 마커의 정보 창에 사용자 지정 뷰를 설정합니다.
        marker.infoWindowAnchor = CGPointMake(0.5, 0.2);
        marker.iconView = infoView;
    }
    
    marker.map = self.mapView;
    marker.userData = param;
    self.markerDic[strKey] = marker;
}

-(void)updateMarker:(id)param{
    NSString* strKey = [NSString stringWithFormat:@"%@", param[@"key"]];
    __weak typeof(self) weakSelf = self;
    [self.markerDic enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;

        if([((NSString*)key) isEqualToString:strKey]) {
            [strongSelf removeMarker: strKey];
        }
    }];

    [self addMarker:param];
}

-(void)removeMarker:(NSString*)strKey{
    [self.markerDic enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if([((NSString*)key) isEqualToString:strKey]) {
            ((GMSMarker*)object).map = nil;
        }
    }];
}

-(void)addCircle:(id)param{
    NSString* strKey = [NSString stringWithFormat:@"%@", param[@"key"]];
    NSString* strLat = [NSString stringWithFormat:@"%@", param[@"lat"]];
    NSString* strLogi = [NSString stringWithFormat:@"%@", param[@"lng"]];
    NSString* strRadius = [NSString stringWithFormat:@"%@", param[@"radius"]];
    CLLocationDegrees latitude = [strLat doubleValue];
    CLLocationDegrees longitude = [strLogi doubleValue];
    CLLocationDistance radius = [strRadius doubleValue] * 1000;

    GMSCircle* circle = [GMSCircle circleWithPosition:(CLLocationCoordinate2DMake(latitude, longitude)) radius:radius];
    circle.strokeColor = UIColorFromRGB(0x2559AB);
    circle.strokeWidth = 1;
    circle.fillColor = UIColorFromRGBA(0x202559AB);
    circle.map = self.mapView;

    [self.circleDic setValue:circle forKey:strKey];
}

-(void)removeCircle:(NSString*)strKey{
    [self.circleDic enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if([((NSString*)key) isEqualToString:strKey]) {
            ((GMSCircle*)object).map = nil;
        }
    }];
}


-(void)callbackMarkerClick :(void (^)(id markerJson))callback {
    self.markerClick = callback;
}

-(void)callbackMapClick :(void (^)(id camera))callback {
    self.mapClick = callback;
}

-(void)callbackCamera :(void (^)(id))callback {
    self.camera = callback;
}

-(void)callbackDragStart :(void (^)(id))callback {
    self.dragStart = callback;
}
-(void)callbackDragEnd :(void (^)(id))callback {
    self.dragEnd = callback;
}


#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"Marker dragging begin");
    if(self.dragStart != nil) {
        self.dragStart([self getMarkerJsonFromMarker:marker]);
    }
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    NSLog(@"Marker dragging");
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    NSLog(@"Marker dragging end");
    if(self.dragEnd != nil) {
        self.dragEnd([self getMarkerJsonFromMarker:marker]);
    }
}

- (id)getMarkerJsonFromMarker:(GMSMarker *)marker {
    return marker.userData;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"Marker touch");
    if(self.mapClick != nil) {
        self.mapClick(@{
            @"lat":[NSNumber numberWithDouble:coordinate.latitude],
            @"lng":[NSNumber numberWithDouble:coordinate.longitude],
            @"zoom":[NSNumber numberWithInt:mapView.camera.zoom],
            });
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if(self.camera != nil) {
        self.zoom = position.zoom;
        self.camera(@{
            @"lat" : [NSNumber numberWithDouble:position.target.latitude],
            @"lng" : [NSNumber numberWithDouble:position.target.longitude],
            @"zoom" : [NSNumber numberWithInt:position.zoom]
        });
    }
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if(self.markerClick)
        self.markerClick([self getMarkerJsonFromMarker:marker]);
    
    return NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 현재 위치 업데이트
    CLLocation *currentLocation = [locations objectAtIndex:0];
//    [self.mapView animateToLocation:currentLocation.coordinate];
}


@end
