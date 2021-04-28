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
+ (void)uploadS3:(NSArray*)file :(JSValue *)callback;
+ (void)sendPushKeyWithDevilServer;
+ (void)postThenWithHeader:(NSString *)url :(id)header :(id)param :(JSValue *)callback;
+ (void)update;
+ (void)updateThis;
+ (void)popup:(NSString*)blockName :(NSDictionary*)param :(JSValue *)callback;
+ (void)popupSelect:(NSArray *)arrayString :(NSDictionary*)param :(JSValue *)callback;
+ (void)resetTimer:(NSString *)nodeName;
+ (int)getViewPagerSelectedIndex:(NSString *)nodeName;
+ (BOOL)wifiIsOn;
+ (void)wifiList:(JSValue *)callback;
+ (void)wifiConnect:(NSString*)ssid :(NSString*)password :(JSValue *)callback;
+ (void)camera:(NSDictionary*)param :(JSValue *)callback;
@end

@interface Jevil : NSObject <Jevil>

@end

NS_ASSUME_NONNULL_END
