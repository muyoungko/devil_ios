//
//  DevilDebugView.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

#import <UIKit/UIKit.h>
#import "DevilController.h"

NS_ASSUME_NONNULL_BEGIN

#define DEVIL_LOG_SCREEN @"SCREEN"
#define DEVIL_LOG_REQUEST @"REQUEST"
#define DEVIL_LOG_RESPONSE @"RESPONSE"
#define DEVIL_LOG_BLUETOOTH @"BLE"
#define DEVIL_LOG_BILL @"BILL"
#define DEVIL_LOG_NFC @"NFC"
#define DEVIL_LOG_CUSTOM @"LOG"

@interface DevilDebugView : UIView

@property(retain, nonatomic) NSMutableArray* logList;

+ (void)constructDebugViewIf:(DevilController*)vc;
+(DevilDebugView*)sharedInstance;
- (void)log:(NSString*)type title:(NSString*)title log:(id)log;
- (void)clearLog;

@end

NS_ASSUME_NONNULL_END
