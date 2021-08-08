//
//  DevilDrawer.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/06/19.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "WildCardDrawerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DevilDrawer : NSObject

@property (nonatomic, retain) NSMutableDictionary* keep;
@property (nonatomic, retain) WildCardDrawerView* activeWildCardDrawerView;

+(DevilDrawer*)sharedInstance;
+(void)menuReady:(NSString*)blockName :(id)param;
+(void)menuOpen:(NSString*)blockName;
+(void)menuClose;
-(void)hide:(UIViewController*)vc;
-(void)show:(UIViewController*)vc;
-(void)update:(UIViewController*) vc;

@end

NS_ASSUME_NONNULL_END
