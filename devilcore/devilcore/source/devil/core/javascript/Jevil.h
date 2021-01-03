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
+ (void)finish;        
+ (void)alert:(NSString*)msg;
+ (void)alertFinish:(NSString*)msg;
+ (void)startLoading;
+ (void)stopLoading;
+ (void)save:(NSString *)key :(NSString *)value;
+ (void)remove:(NSString *)key;
+ (NSString*)get:(NSString *)key;
+ (void)get:(NSString *)url then:(JSValue *)callback;
+ (void)post:(NSString *)url :(NSString*)param then:(JSValue *)callback;
+ (void)update;

@end

@interface Jevil : NSObject <Jevil>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *phone;
@property (nonatomic, readonly) NSString *address;

@end

NS_ASSUME_NONNULL_END
