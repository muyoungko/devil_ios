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
+ (void)update;
+ (void)popup:(NSString*)blockName :(NSDictionary*)param :(JSValue *)callback;
+ (void)popupSelect:(NSArray *)arrayString :(NSString*)selectedKey :(JSValue *)callback;
+ (void)resetTimer:(NSString *)nodeName;
+ (int)getViewPagerSelectedIndex:(NSString *)nodeName;
+ (void)wifiList:(JSValue *)callback;
@end

@interface Jevil : NSObject <Jevil>

@end

NS_ASSUME_NONNULL_END
