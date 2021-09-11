//
//  DevilLink.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/09/09.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DevilLinkDelegate <NSObject>
- (void)createFirebaseDynamicLink:(id)param callback:(void (^)(id res))callback;
@end


@interface DevilLink : NSObject

+(DevilLink*)sharedInstance;
@property (nonatomic, weak, nullable) id <DevilLinkDelegate> delegate;

-(void)create:(id)param callback:(void (^)(id res))callback;

-(void)setReserveUrl:(NSString*)url;
-(NSString*)getReserveUrl;
-(NSString*)popReserveUrl;
-(void)consumeStandardReserveUrl;
-(BOOL)checkNotificationShouldShow:(NSDictionary*)data;

@end

NS_ASSUME_NONNULL_END
