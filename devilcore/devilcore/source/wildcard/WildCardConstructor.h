//
//  WildCardConstructor.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WildCardUIView.h"
#import "ReplaceRule.h"

@class UIView;
@class WildCardMeta;

@protocol WildCardConstructorGlobalDelegate<NSObject>

@required
- (UIView*)getNetworkImageViewInstnace;
- (void)loadNetworkImageView:(UIView*)networkImageView withUrl:(NSString*)url;
- (void)onNetworkRequest:(NSString*)url success:(void (^)(NSMutableDictionary* responseJsonObject))success;
- (void)onNetworkRequestHttp:(NSString*)method :(NSString*)url :(NSDictionary*)header :(NSDictionary*)body :(void (^)(NSMutableDictionary* responseJsonObject))success;
- (void)onNetworkRequestToByte:(NSString*)url success:(void (^)(NSData* byte))success;
- (void)onNetworkRequestGet:(NSString*)url header:(NSDictionary*)header success:(void (^)(NSMutableDictionary* responseJsonObject))success;
- (void)onNetworkRequestPost:(NSString*)url header:(NSDictionary*)header json:(NSDictionary*)json success:(void (^)(NSMutableDictionary* responseJsonObject))success;

@optional
- (void)onMultiPartPost:(NSString*)urlString header:(id)header name:(NSString*)name filename:(NSString*)filename filePath:(NSString*)filePath progress:(void (^)(long sentByte, long totalByte))callback complete:(void (^)(id res))callback;
- (void)cancelNetworkImageView:(UIView*)networkImageView;
- (void)loadNetworkImageViewWithSize:(UIView*)networkImageView withUrl:(NSString*)url callback:(void (^)(CGSize size))callback;
- (void)onNetworkRequestPut:(NSString*)url header:(NSDictionary*)header json:(NSDictionary*)json success:(void (^)(NSMutableDictionary* responseJsonObject))success;
-(UIView*)onCustomExtensionCreate:(WildCardMeta *)meta extensionLayer:(NSDictionary*) extension;
-(void)onCustomExtensionUpdate:(UIView*)view meta:(WildCardMeta *)meta extensionLayer:(NSDictionary*)extension data:(NSMutableDictionary*) data;
-(void)onCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node;
@end

@protocol WildCardConstructorTextTransDelegate<NSObject>
@required
-(NSString*)translateLanguage:(NSString*)text;
-(NSString*)translateLanguage:(NSString*)text:(NSString*)node;
@end

@protocol WildCardConstructorTextConvertDelegate<NSObject>
@required
-(float)convertTextSize:(int)sketchTextSize;
@end

@interface WildCardConstructor : NSObject

+ (WildCardConstructor*)sharedInstance;
+ (WildCardConstructor*)sharedInstance:(NSString*)project_id;

@property (nonatomic, retain) NSString* _Nullable project_id;

@property BOOL hideIcon;
@property BOOL onLineMode;
@property BOOL localImageMode;
@property BOOL default_word_wrap;
@property BOOL use_theme;
@property (nonatomic, weak, nullable) id <WildCardConstructorGlobalDelegate> delegate;
@property (nonatomic, weak, nullable) id <WildCardConstructorTextConvertDelegate> textConvertDelegate;
@property (nonatomic, weak, nullable) id <WildCardConstructorTextTransDelegate> textTransDelegate;

@property (nonatomic, retain) NSMutableDictionary* _Nullable cloudJsonMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable tabletCloudJsonMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable landscapeCloudJsonMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable tabletLandscapeCloudJsonMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable themeCloudJsonMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable screenMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable blockMap;
@property (nonatomic, retain) NSMutableArray* _Nullable resourceList;
@property (nonatomic, retain) NSMutableDictionary* _Nullable project;
@property (nonatomic, retain) NSString* _Nullable xButtonImageName;

+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer;
+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer instanceDelegate:(id)delegate;
+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer withParentMeta:(WildCardMeta*)parentMeta depth:(int)depth instanceDelegate:(id)delegate;
+(void) applyRuleMeta:(WildCardMeta*)meta withData:(JSValue* _Nonnull)opt;
+(void) applyRule:(WildCardUIView*_Nonnull)v withData:(JSValue* _Nonnull)opt;
+(void) applyRuleCore:(WildCardMeta*)meta rule:(ReplaceRule*)rule withData:(JSValue* _Nonnull)opt;
+(float) convertSketchToPixel:(float)p;
+(float) convertTextSize:(int)sketchTextSize;
+(void) followSizeFromFather:(UIView*)vv child:(UIView*)tv;
+(void) userInteractionEnableToParentPath:(UIView*)vv depth:(int)depth;
+(NSData*)getLocalFile:(NSString*)path;
+(CGRect)getFrame:(NSDictionary*) layer : (WildCardUIView*)parentForPadding;

-(void) initWithLocalOnComplete:(void (^_Nonnull)(BOOL success))complete;
-(void) initWithOnlineOnComplete:(void (^_Nonnull)(BOOL success))complete;
-(void) initWithOnlineVersion:(NSString*)version onComplete:(void (^_Nonnull)(BOOL success))complete;
-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey;
-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey :(BOOL)landscape;
-(NSString*) getDeclaredCode;
-(NSMutableDictionary*_Nullable) getAllBlockJson;

-(NSString*)getFirstScreenId;
-(NSString*)getScreenIdByName:(NSString*)screenName;
-(NSString*)getBlockIdByName:(NSString*)blockName;
-(NSString*)getFirstBlock:(NSString*)screenId;
-(BOOL)isFirstBlockFitScreen:(NSString*)screenId;
-(void)firstBlockFitScreenIfTrue:(NSString*)screenId sketch_height_more:(int)height landscape:(BOOL)isLandscape;
-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey withName:(NSString*)nodeName;
-(NSMutableArray*)getScreenIfList:(NSString*)screen;
-(NSMutableDictionary*)getScreen:(NSString*)screenId;
-(NSMutableDictionary*)getHeaderCloudJson:(NSString*)screenId :(BOOL)isLandscape;
-(NSMutableDictionary*)getFooterCloudJson:(NSString*)screenId :(BOOL)isLandscape;
-(NSMutableDictionary*)getInsideFooterCloudJson:(NSString*)screenId :(BOOL)isLandscape;
+(BOOL)isTablet;
+(void)resetIsTablet;
+(void)updateSketchWidth:(id)layer;
+(void)updateScreenWidthHeight:(float)w :(float)h;
-(UIInterfaceOrientationMask) supportedOrientation : (NSString*)screenId :(NSString*)limitOrientation;
-(void)startLoading;
-(void)stopLoading;

@end




