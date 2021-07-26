//
//  DevilSdk.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/11/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevilSdkDelegate<NSObject>
@required
-(float)startLoading;
-(float)stopLoading;
@end

@interface DevilSdk : NSObject

@property (nonatomic, weak, nullable) id <DevilSdkDelegate> devilSdkDelegate;
@property (nonatomic, retain) NSMutableDictionary* registeredClass;

+(DevilSdk*)sharedInstance;
+(void)start:(NSString*)project_id viewController:(UIViewController*)vc complete:(void (^)(BOOL res))callback;
-(id)getCustomJevil;
-(void)addCustomJevil:(Class)a;
-(void)registScreenController:(NSString*)screenName class:(Class)class;
-(Class)getRegisteredScreenClassOrDevil:(NSString*)screenName;
@end

NS_ASSUME_NONNULL_END
