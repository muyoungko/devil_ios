//
//  Jevil.h
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/15.
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Jevil <JSExport>

+ (instancetype)contactWithName:(NSString *)name
                          phone:(NSString *)phone
                        address:(NSString *)address;

+ (BOOL)isLogin;
+ (void)go:(NSString*)screenName :(id)param;
+ (void)replaceScreen:(NSString*)screenName :(id)param;
+ (void)rootScreen:(NSString*)screenName :(id)param;
+ (void)tab:(NSString*)screenName;
+ (void)finish:(id)callbackData;
+ (void)finishThen:(JSValue *)callback;
+ (void)back;
+ (void)toast:(NSString*)msg;
+ (void)alert:(NSString*)msg;
+ (void)alertFinish:(NSString*)msg;
+ (void)alertThen:(NSString*)msg :(JSValue *)callback;
+ (void)confirm:(NSString*)msg :(NSString*)yes :(NSString*)no :(JSValue *)callback;
+ (void)startLoading;
+ (void)stopLoading;
+ (void)save:(NSString *)key :(NSString *)value;
+ (void)remove:(NSString *)key;
+ (NSString*)get:(NSString *)key;
+ (void)get:(NSString *)url then:(JSValue *)callback;
+ (void)post:(NSString *)url :(id)param then:(JSValue *)callback;
+ (void)put:(NSString *)url :(id)param then:(JSValue *)callback;
+ (void)uploadS3:(NSArray*)file :(JSValue *)callback;
+ (void)sendPushKeyWithDevilServer;
+ (void)getThenWithHeader:(NSString *)url :(id)header :(JSValue *)callback;
+ (void)postThenWithHeader:(NSString *)url :(id)header :(id)param :(JSValue *)callback;
+ (void)update;
+ (void)updateThis;
+ (void)focus:(NSString*)nodeName;
+ (void)hideKeyboard;
+ (void)scrollTo:(NSString*)nodeName :(int)index :(BOOL)noani;
+ (void)scrollUp:(NSString*)nodeName;
+ (void)popup:(NSString*)blockName :(NSDictionary*)param :(JSValue *)callback;
+ (void)popupClose;
+ (void)popupClose:(BOOL)yes;
+ (void)popupAddress:(NSDictionary*)param :(JSValue *)callback;
+ (void)popupSelect:(NSArray *)arrayString :(NSDictionary*)param :(JSValue *)callback;
+ (void)popupDate:(NSDictionary*)param :(JSValue *)callback;
+ (void)resetTimer:(NSString *)nodeName;
+ (int)getViewPagerSelectedIndex:(NSString *)nodeName;
+ (BOOL)wifiIsOn;
+ (void)wifiList:(JSValue *)callback;
+ (void)wifiConnect:(NSString*)ssid :(NSString*)password :(JSValue *)callback;
+ (void)camera:(NSDictionary*)param :(JSValue *)callback;
+ (void)share:(NSString*)url;
+ (void)out:(NSString*)url;
+ (void)download:(NSString*)url;
+ (void)sound:(NSDictionary*)param;
+ (void)soundTick:(JSValue*)callback;
+ (void)soundPause;
+ (void)soundStop;
+ (void)soundResume;
+ (void)soundMove:(int)sec;
+ (void)soundSpeed:(NSString*)speed;
+ (void)speechRecognizer:(NSDictionary*)param :(JSValue*)callback;
+ (void)stopSpeechRecognizer;
+ (void)getLocation:(NSDictionary*)param :(JSValue*)callback;
+ (void)setText:(NSString*)node :(NSString*)text;
+ (void)webLoad:(NSString*)node :(JSValue *)callback;
+ (void)scrollDragged:(NSString*)node :(JSValue *)callback;
+ (void)scrollEnd:(NSString*)node :(JSValue *)callback;
+ (void)textChanged:(NSString*)node :(JSValue *)callback;
+ (void)textFocusChanged:(NSString*)node :(JSValue *)callback;
+ (void)videoViewAutoPlay;
+ (void)isWifi:(JSValue *)callback;
+ (void)getCurrentLocation:(NSDictionary*)param :(JSValue*)callback;
+ (void)getCurrentPlace:(NSDictionary*)param :(JSValue*)callback;
+ (void)searchPlace:(NSDictionary*)param :(JSValue*)callback;
+ (JSValue*)parseUrl:(NSString*)url;
+ (void)menuReady:(NSString*)node :(NSDictionary*)param;
+ (void)menuOpen:(NSString*)node;
+ (void)menuClose;
+ (void)setTimer:(NSString*)key :(int)milli_sec :(JSValue*)callback;
+ (void)removeTimer:(NSString*)key;
@end

@interface Jevil : NSObject <Jevil>

@end

NS_ASSUME_NONNULL_END
