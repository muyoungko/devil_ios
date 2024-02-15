//
//  DevilGoogleMapMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/10/04.
//

#import "DevilGoogleMapMarketComponent.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"
#import "DevilLocation.h"
#import "WildCardUtil.h"

@import GoogleMaps;

@interface DevilGoogleMapMarketComponent() <GMSMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, retain) GMSMapView* mapView;
@property (nonatomic, retain) NSMutableDictionary* markerDic;
@property (nonatomic, retain) NSMutableDictionary* circleDic;
@property (nonatomic, retain) NSMutableDictionary* cachedImage;
@property (nonatomic, retain) NSMutableDictionary* asyncMarkerTask;
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
    self.cachedImage = [NSMutableDictionary dictionary];
    self.asyncMarkerTask = [NSMutableDictionary dictionary];
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
            if([start_location[@"my_location"] boolValue]) {
                ;
            } else {
                double lat = [start_location[@"lat"] doubleValue];
                double lng = [start_location[@"lng"] doubleValue];
                position = CLLocationCoordinate2DMake(lat, lng);
            }
            if(start_location[@"zoom"])
                self.zoom = [start_location[@"zoom"] intValue];
        }
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:position.latitude
                                                                longitude:position.longitude
                                                                     zoom:self.zoom];
        self.mapView = [[GMSMapView alloc] initWithFrame: CGRectZero camera:camera];
        self.mapView.delegate = self;
        
        if(start_location) {
            if([start_location[@"my_location"] boolValue]) {
                self.mapView.myLocationEnabled = YES;
                self.mapView.settings.myLocationButton = YES;
                self.mapView.settings.compassButton = YES;
            } else {
                self.mapView.myLocationEnabled = NO;
            }
        }
        
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
    
    if([@"bubble" isEqualToString:type]) {
        
        NSString* color_text = param[@"color"];
        UIColor* color = [UIColor blueColor];
        if([@"blue" isEqualToString:color_text])
            color = [UIColor blueColor];
        else if([@"white" isEqualToString:color_text])
            color = [UIColor whiteColor];
        else if([@"red" isEqualToString:color_text])
            color = [UIColor redColor];
        else if([@"green" isEqualToString:color_text])
            color = [UIColor greenColor];
        else if([@"purple" isEqualToString:color_text])
            color = [UIColor purpleColor];
        else if([@"orange" isEqualToString:color_text])
            color = [UIColor orangeColor];
        
        UIFont* font = [UIFont systemFontOfSize:15];
        CGRect textSize = [WildCardUtil getTextSize:title font:font maxWidth:CGFLOAT_MAX maxHeight:CGFLOAT_MAX];
        if(textSize.size.width > 200)
            textSize.size.width = 200;
        UIView *bubbleView = [self createBubbleView:textSize.size color:color];
        
        UIView *infoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bubbleView.frame.size.width, bubbleView.frame.size.height)];
        infoView.backgroundColor = [UIColor clearColor];
        [infoView addSubview:bubbleView];
        
        int arrow_gap = 10;
        // 라벨을 추가하여 텍스트를 표시합니다.
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bubbleView.frame.size.width, bubbleView.frame.size.height - arrow_gap)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 1; // 여러 줄의 텍스트를 표시하려면 0으로 설정합니다.
        [infoView addSubview:label];

        // 마커의 정보 창에 사용자 지정 뷰를 설정합니다.
        marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
        marker.iconView = infoView;
    } else if([@"image" isEqualToString:type]){
        NSString* url = param[@"url"];
        if(_cachedImage[url] != nil) {
            UIImage *image = _cachedImage[url];
            UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
            marker.infoWindowAnchor = CGPointMake(0.5, 1.0);
            marker.iconView = imageView;
        } else {
            if(_asyncMarkerTask[url] == nil) {
                _asyncMarkerTask[url] = [@[] mutableCopy];
                [_asyncMarkerTask[url] addObject:param];
                [[WildCardConstructor sharedInstance].delegate onNetworkRequestToByte:url success:^(NSData *byte) {
                    
                    if(byte == nil || ![byte isKindOfClass:[NSData class]])
                        return;
                    
                    UIImage* image = [UIImage imageWithData:byte];
                    float width = image.size.width;
                    if(param[@"url_image_width"]) {
                        width = [WildCardConstructor convertSketchToPixel:
                                 (float)[param[@"url_image_width"] intValue]];
                        image = [DevilUtil resizeImage:image width:width];
                    }
                    _cachedImage[url] = image;
                    
                    for(id marker_param in _asyncMarkerTask[url]) {
                        [self addMarker:marker_param];
                    }
                    
                    [_asyncMarkerTask removeObjectForKey:url];
                    
                }];
            } else {
                [_asyncMarkerTask[url] addObject:param];
            }
            return;
        }
        
        
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
//        
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//            });
//        });
    }
    
    //marker.snippet = @"Current location";
    
    marker.map = self.mapView;
    marker.userData = param;
    self.markerDic[strKey] = marker;
}

-(UIView*) createBubbleView:(CGSize)textSize color:(UIColor*)color {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *bubble_body = [UIImage imageNamed:@"devil_map_bubble_body.png" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImage *bubble_arrow = [UIImage imageNamed:@"devil_map_bubble_arrow.png" inBundle:bundle compatibleWithTraitCollection:nil];
    
    UIEdgeInsets imageInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    bubble_body = [bubble_body resizableImageWithCapInsets:imageInset];
    bubble_body = [bubble_body imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    bubble_arrow = [bubble_arrow imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    
    int arrow_gap = 10;
    int padding = 10;
    UIImageView* bubbleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, textSize.width+padding*2, textSize.height+padding*2)];
    bubbleView.image = bubble_body;
    bubbleView.tintColor = color;
    
    UIImageView* bubbleArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 111/3.0f, 111/3.0f)];
    bubbleArrowView.image = bubble_arrow;
    bubbleArrowView.tintColor = color;
    
    UIView *r = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, textSize.width+padding*2, textSize.height+padding*2+arrow_gap)];
    r.backgroundColor = [UIColor clearColor];
    [r addSubview:bubbleArrowView];
    bubbleArrowView.center = CGPointMake(r.frame.size.width/2, r.frame.size.height-bubbleArrowView.frame.size.height/2);
    [r addSubview:bubbleView];
    
    return r;
}

-(void)updateMarker:(id)param{
    NSString* key = [NSString stringWithFormat:@"%@", param[@"key"]];
    
    if(self.markerDic[key]){
        //기존 마커와 비교
        id old = ((GMSMarker*)self.markerDic[key]).userData;
        if(![old[@"lat"] isEqual:param[@"lat"]] ||
           ![old[@"lng"] isEqual:param[@"lng"]] ||
           !(old[@"title"] == param[@"title"] || [old[@"title"] isEqual:param[@"title"]]) ||
           !(old[@"url"] == param[@"url"] || [old[@"url"] isEqual:param[@"url"]])
           ) {
            [self removeMarker:key];
            [self addMarker:param];
        } else {
            ((GMSMarker*)self.markerDic[key]).userData = param;
        }
    } else {
        [self addMarker:param];
    }
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
        
        marker.userData[@"lat"] = [NSNumber numberWithDouble:marker.position.latitude];
        marker.userData[@"lng"] = [NSNumber numberWithDouble:marker.position.longitude];
        
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
    
    [self camera:@{
        @"lat":[NSNumber numberWithDouble:marker.position.latitude],
        @"lng":[NSNumber numberWithDouble:marker.position.longitude],
    }];
    return YES;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // 현재 위치 업데이트
    CLLocation *currentLocation = [locations objectAtIndex:0];
//    [self.mapView animateToLocation:currentLocation.coordinate];
}


@end
