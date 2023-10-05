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

@interface DevilGoogleMapMarketComponent()
@property (nonatomic, retain) GMSMapView* mapView;
@property (nonatomic, retain) NSMutableArray* markers;
@end

@implementation DevilGoogleMapMarketComponent

-(void)initialized {
    [super initialized];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"devil" ofType:@"plist"];
    id dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* api_key = dict[@"GoogleMapKey"];
    [GMSServices provideAPIKey:api_key];
    self.markers = [NSMutableArray array];

}

-(void)created{
    [super created];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6.0];
    self.mapView = [[GMSMapView alloc] initWithFrame: CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    [self.vv addSubview:self.mapView];
    [WildCardConstructor followSizeFromFather:self.vv child:self.mapView];
    [WildCardConstructor userInteractionEnableToParentPath:self.mapView depth:5];
}

-(void)update:(id)opt{
    [super update:opt];
}


-(void)camera:(id)param{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6.0];
    [self.mapView moveCamera:camera];
}

-(void)addMarker:(id)param{
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(self.mapView.camera.target.latitude, self.mapView.camera.target.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:mapCenter];
    [self.markers addObject:marker];
    marker.icon = [UIImage imageNamed:@"pin.png"];
    marker.map = self.mapView;
}


-(void)updateMarker:(id)param{
}

-(void)removeMarker:(id)param{

    for (GMSMarker* marker in self.markers) {
        marker.map = nil;
    }
}

-(void)addCircle:(id)param{
}

-(void)removeCircle:(id)param{
}

-(void)callback:(id)param{
}

@end
