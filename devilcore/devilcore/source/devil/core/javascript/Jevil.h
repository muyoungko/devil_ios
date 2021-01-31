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
+ (void)go:(NSString*)screenName :(NSString*)dataString;
+ (void)replaceScreen:(NSString*)screenName;
+ (void)rootScreen:(NSString*)screenName;
+ (void)finish:(NSString*)callbackDataString;
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
+ (void)post:(NSString *)url :(NSString*)param then:(JSValue *)callback;
+ (void)update;
+ (void)popup:(NSString*)blockName :(NSString*)title :(NSString*)yes :(NSString*)no :(JSValue *)callback;
+ (void)popupSelect:(NSString *)arrayString :(NSString*)selectedKey :(JSValue *)callback;
+ (void)resetTimer:(NSString *)nodeName;
+ (int)getViewPagerSelectedIndex:(NSString *)nodeName;

@end

@interface Jevil : NSObject <Jevil>

@end

NS_ASSUME_NONNULL_END
