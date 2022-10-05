//
//  DevilImageMap.h
//  devilcore
//
//  Created by Mu Young Ko on 2022/08/10.
//

#import <devilcore/devilcore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilImageMap : UIView
@property (nonatomic, retain) NSString* currentUrl;
@property (nonatomic, retain) id pinList;
-(void)construct;
-(void)showImage:(NSString*)url;
-(void)syncPin;
-(void)callback:(NSString*)command :(void (^)(id res))callback;
-(void)relocation:(NSString*)key;
-(void)setMode:(NSString*)mode :(id)param;
-(void)focus:(NSString*)key;

@end

NS_ASSUME_NONNULL_END
