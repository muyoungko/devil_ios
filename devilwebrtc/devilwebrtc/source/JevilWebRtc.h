//
//  JevilWebRtc.h
//  devilwebrtc
//
//  Created by Mu Young Ko on 2023/09/16.
//

#import <Foundation/Foundation.h>
@import JavaScriptCore;


NS_ASSUME_NONNULL_BEGIN

@protocol JevilWebRtc <JSExport>

+ (void)start:(id)param :(JSValue *)callback;

@end

@interface JevilWebRtc : NSObject<JevilWebRtc>

@end

NS_ASSUME_NONNULL_END
