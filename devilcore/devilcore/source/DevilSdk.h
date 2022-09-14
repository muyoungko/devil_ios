//
//  DevilSdk.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/11/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DevilController;

@protocol DevilSdkDelegate<NSObject>
@required
-(float)startLoading;
-(float)stopLoading;
@end

@protocol DevilSdkScreenDelegate<NSObject>
@required
-(DevilController*)getScreenViewController:(NSString*)screenName;
@end

@protocol DevilSdkGoogleAdsDelegate<NSObject>
@required
-(void)loadAds:(id)params complete:(void (^)(id res))callback;
-(void)showAds:(id)params complete:(void (^)(id res))callback;
@end

@interface DevilSdk : NSObject

@property (nonatomic, weak, nullable) id <DevilSdkDelegate> devilSdkDelegate;
@property (nonatomic, weak, nullable) id <DevilSdkScreenDelegate> devilSdkScreenDelegate;
@property (nonatomic, weak, nullable) id <DevilSdkGoogleAdsDelegate> devilSdkGoogleAdsDelegate;

@property (nonatomic, retain) NSMutableDictionary* registeredClass;

+(DevilSdk*)sharedInstance;
+(void)start:(NSString*)project_id viewController:(UIViewController*)vc complete:(void (^)(BOOL res))callback;
+(void)start:(NSString*)project_id screenId:(NSString*)screen_id controller:(Class)controllerClass viewController:(UIViewController*)vc complete:(void (^)(BOOL res))callback;
-(id)getCustomJevil;
-(void)addCustomJevil:(Class)a;
-(void)registScreenController:(NSString*)screenName class:(Class)class;
-(Class)getRegisteredScreenClassOrDevil:(NSString*)screenName;
-(UIViewController*)getRegisteredScreenViewController:(NSString*)screenName;

@end

NS_ASSUME_NONNULL_END
