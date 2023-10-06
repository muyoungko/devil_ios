//
//  DevilGoogleMapMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/10/04.
//

#import "DevilGoogleMapMarketComponent.h"
#import "WildCardConstructor.h"

@import GoogleMaps;
@import GoogleMapsUtils;


@interface DevilGoogleMapMarketComponent() <GMSMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, retain) GMSMapView* mapView;
@property (nonatomic, retain) NSMutableDictionary* markerDic;
@property (nonatomic, retain) NSMutableDictionary* circleDic;
@property (nonatomic, assign) float zoom;
@property (nonatomic, copy) void (^markerClick)(double, double, NSString*, NSString*);
@property (nonatomic, copy) void (^mapClick)(double, double);
@property (nonatomic, copy) void (^camera)(double, double);
@property (nonatomic, copy) void (^dragStart)(double, double, NSString*, NSString*);
@property (nonatomic, copy) void (^dragEnd)(double, double, NSString*, NSString*);



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

}

-(void)created{
    [super created];
    CLLocationCoordinate2D coordinate = [self currentLocation];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:self.zoom];
    self.mapView = [[GMSMapView alloc] initWithFrame: CGRectZero camera:camera];
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    [self.vv addSubview:self.mapView];
    [WildCardConstructor followSizeFromFather:self.vv child:self.mapView];
    [WildCardConstructor userInteractionEnableToParentPath:self.mapView depth:5];
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
    CLLocationDegrees latitude = [strLat doubleValue];
    CLLocationDegrees longitude = [strLogi doubleValue];

    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(latitude, longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    marker.draggable = YES;
    marker.icon = [UIImage imageNamed:@"pin.png"];
    marker.map = self.mapView;

    [self.markerDic setValue:marker forKey:strKey];
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
    CLLocationDistance radius = [strRadius doubleValue] * 10 * 1000;

    GMSCircle* circle = [GMSCircle circleWithPosition:(CLLocationCoordinate2DMake(latitude, longitude)) radius:radius];

    // 원의 윤곽선 색상 설정
    circle.strokeColor = [UIColor redColor];

    // 원의 윤곽선 두께 설정
    circle.strokeWidth = 3;

    // 원의 채우기 색상 설정
    circle.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];

    // 원을 지도에 추가
    circle.map = self.mapView;

    [self.circleDic setValue:circle forKey:strKey];
    [self.mapView animateToLocation:CLLocationCoordinate2DMake(latitude, longitude)];
}

-(void)removeCircle:(NSString*)strKey{
    [self.circleDic enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if([((NSString*)key) isEqualToString:strKey]) {
            ((GMSCircle*)object).map = nil;
        }
    }];
}


-(void)callbackMarkerClick :(void (^)(double lat, double longi, NSString* title, NSString* desc))callback {
    self.markerClick = callback;
}

-(void)callbackMapClick :(void (^)(double lat, double longi))callback {
    self.mapClick = callback;
}

-(void)callbackCamera :(void (^)(double lat, double longi))callback {
    self.camera = callback;
}

-(void)callbackDragStart :(void (^)(double lat, double longi, NSString* title, NSString* desc))callback {
    self.dragStart = callback;
}
-(void)callbackDragEnd :(void (^)(double lat, double longi, NSString* title, NSString* desc))callback {
    self.dragEnd = callback;
}


#pragma mark - GMSMapViewDelegate
- (void)mapView:(GMSMapView *)mapView didBeginDraggingMarker:(GMSMarker *)marker {
    NSLog(@"Marker dragging begin");
    if(self.dragStart != nil) {
        self.dragStart(marker.position.latitude, marker.position.longitude, marker.title, marker.snippet);
    }
}

- (void)mapView:(GMSMapView *)mapView didDragMarker:(GMSMarker *)marker {
    NSLog(@"Marker dragging");
}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    NSLog(@"Marker dragging end");
    if(self.dragEnd != nil) {
        self.dragEnd(marker.position.latitude, marker.position.longitude, marker.title, marker.snippet);
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"Marker touch");
    if(self.mapClick != nil) {
        self.mapClick(coordinate.latitude, coordinate.longitude);
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if(self.camera != nil) {
        self.camera(position.target.latitude, position.target.longitude);
    }
}
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    self.markerClick(marker.position.latitude, marker.position.longitude, marker.title, marker.snippet);
    return NO;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 현재 위치 업데이트
    CLLocation *currentLocation = [locations objectAtIndex:0];
    [self.mapView animateToLocation:currentLocation.coordinate];
}


@end
