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
- (void)onNetworkRequestToByte:(NSString*)url success:(void (^)(NSData* byte))success;
- (void)onNetworkRequestGet:(NSString*)url header:(NSDictionary*)header success:(void (^)(NSMutableDictionary* responseJsonObject))success;
- (void)onNetworkRequestPost:(NSString*)url header:(NSDictionary*)header json:(NSDictionary*)json success:(void (^)(NSMutableDictionary* responseJsonObject))success;

@optional
- (void)onNetworkRequestPut:(NSString*)url header:(NSDictionary*)header data:(NSData*)data success:(void (^)(NSMutableDictionary* responseJsonObject))success;

-(UIView*)onCustomExtensionCreate:(WildCardMeta *)meta extensionLayer:(NSDictionary*) extension;

-(void)onCustomExtensionUpdate:(UIView*)view meta:(WildCardMeta *)meta extensionLayer:(NSDictionary*)extension data:(NSMutableDictionary*) data;

-(void)onCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node;
@end

@protocol WildCardConstructorTextTransDelegate<NSObject>
@required
-(NSString*)translateLanguage:(NSString*)text;
@end

@protocol WildCardConstructorTextConvertDelegate<NSObject>
@required
-(float)convertTextSize:(int)sketchTextSize;
@end

@protocol WildCardConstructorLoading<NSObject>
@required
-(float)startLoading;
-(float)stopLoading;
@end


@interface WildCardConstructor : NSObject

+ (WildCardConstructor*)sharedInstance;
+ (WildCardConstructor*)sharedInstance:(NSString*)project_id;

@property (nonatomic, retain) NSString* _Nullable project_id;

@property BOOL onLineMode;
@property (nonatomic, weak, nullable) id <WildCardConstructorGlobalDelegate> delegate;
@property (nonatomic, weak, nullable) id <WildCardConstructorTextConvertDelegate> textConvertDelegate;
@property (nonatomic, weak, nullable) id <WildCardConstructorTextTransDelegate> textTransDelegate;
@property (nonatomic, weak, nullable) id <WildCardConstructorLoading> loadingDelegate;

@property (nonatomic, retain) NSMutableDictionary* _Nullable cloudJsonMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable screenMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable blockMap;
@property (nonatomic, retain) NSMutableDictionary* _Nullable project;
@property (nonatomic, retain) NSString* _Nullable xButtonImageName;

+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer;
+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer instanceDelegate:(id)delegate;
+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer withParentMeta:(WildCardMeta*)parentMeta depth:(int)depth instanceDelegate:(id)delegate;
+(void) applyRuleMeta:(WildCardMeta*)meta withData:(NSMutableDictionary*)opt;
+(void) applyRule:(WildCardUIView*_Nonnull)v withData:(NSMutableDictionary*_Nonnull)opt;
+(void) applyRuleCore:(WildCardMeta*)meta rule:(ReplaceRule*)rule withData:(NSMutableDictionary*)opt;
+(float) convertSketchToPixel:(float)p;
+(float) convertTextSize:(int)sketchTextSize;
+(void) followSizeFromFather:(UIView*)vv child:(UIView*)tv;
+(void) userInteractionEnableToParentPath:(UIView*)vv depth:(int)depth;
+(NSData*)getLocalFile:(NSString*)path;
+(CGRect)getFrame:(NSDictionary*) layer : (WildCardUIView*)parentForPadding;
+ (float)getPaddingTopBottomConverted:(id)layer;

-(void) initWithLocalOnComplete:(void (^_Nonnull)(BOOL success))complete;
-(void) initWithOnlineOnComplete:(void (^_Nonnull)(BOOL success))complete;
-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey;
-(NSMutableDictionary*_Nullable) getAllBlockJson;

-(NSString*)getFirstScreenId;
-(NSString*)getScreenIdByName:(NSString*)screenName;
-(NSString*)getBlockIdByName:(NSString*)blockName;
-(void)firstBlockFitScreenIfTrue:(NSString*)screenId sketch_height_more:(int)height;
-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey withName:(NSString*)nodeName;
-(NSMutableArray*)getScreenIfList:(NSString*)screen;
-(NSMutableDictionary*)getScreen:(NSString*)screenId;
-(NSMutableDictionary*)getHeaderCloudJson:(NSString*)screenId;
-(NSMutableDictionary*)getFooterCloudJson:(NSString*)screenId;
+(BOOL)isTablet;

@end




