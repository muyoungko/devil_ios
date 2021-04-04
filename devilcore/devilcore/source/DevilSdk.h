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

+(DevilSdk*)sharedInstance;
+(void)start:(NSString*)project_id viewController:(UIViewController*)vc complete:(void (^)(BOOL res))callback;
-(id)getCustomJevil;
-(void)addCustomJevil:(Class)a;
@end

NS_ASSUME_NONNULL_END
