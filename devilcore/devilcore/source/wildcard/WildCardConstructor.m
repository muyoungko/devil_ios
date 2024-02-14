//
//  WildCardConstructor.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardConstructor.h"
#import "ReplaceRuleClick.h"
#import "ReplaceRuleImage.h"
#import "ReplaceRuleImageResource.h"
#import "ReplaceRuleText.h"
#import "ReplaceRuleRepeat.h"
#import "ReplaceRuleHidden.h"
#import "ReplaceRuleLocalImage.h"
#import "ReplaceRuleReplaceUrl.h"
#import "ReplaceRuleExtension.h"
#import "ReplaceRuleColor.h"
#import "ReplaceRuleStrip.h"
#import "ReplaceRuleIcon.h"
#import "ReplaceRuleVideo.h"
#import "ReplaceRuleWeb.h"
#import "ReplaceRuleMarket.h"
#import "ReplaceRuleQrcode.h"
#import "ReplaceRuleAccessibility.h"
#import "WildCardUtil.h"
#import "WildCardUILabel.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardCollectionViewAdapter.h"
#import "WildCardGridView.h"
#import "WildCardExtensionConstructor.h"
#import "WildCardAction.h"
#import "WildCardTrigger.h"
#import "WildCardUITapGestureRecognizer.h"
#import "WildCardMeta.h"
#import "WildCardFunction.h"
#import "DevilWebView.h"
#import "WildCardTimer.h"
#import "WildCardPagerTabStrip.h"
#import "WildCardPagerTabStripMaker.h"
#import "Lottie/Lottie.h"
#import "WildCardUITextView.h"
#import "WildCardUIPageControl.h"
#import "WildCardUICollectionView.h"
#import "WildCardEventTracker.h"
#import "JevilInstance.h"

//#import "UIImageView+AFNetworking.h"

@implementation WildCardConstructor


static NSString *default_project_id = nil;
+ (WildCardConstructor*)sharedInstance {
    
    return [WildCardConstructor sharedInstance:default_project_id];
}

+ (WildCardConstructor*)sharedInstance:(NSString*)project_id {
    default_project_id = project_id;
    static NSMutableDictionary* sharedInstanceMap = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        sharedInstanceMap = [[NSMutableDictionary alloc] init];
    });
    if(!sharedInstanceMap[project_id]){
        WildCardConstructor* wildCardConstructor = [[WildCardConstructor alloc] init];
        wildCardConstructor.project_id = project_id;
        sharedInstanceMap[project_id] = wildCardConstructor;
    }
    return sharedInstanceMap[project_id];
}

-(id)init
{
    self = [super init];
    self.xButtonImageName = nil;
    self.localImageMode = NO;
    return self;
}

+(NSData*)getLocalFile:(NSString*)path {
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[resourcePath stringByAppendingPathComponent:path]];
    return data;
}

-(void) initWithLocalOnComplete:(void (^_Nonnull)(BOOL success))complete
{
    [WildCardConstructor sharedInstance].onLineMode = NO;
    NSData *data = [WildCardConstructor getLocalFile:[NSString stringWithFormat:@"assets/json/%@.json", self.project_id]];

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [self initWithProject:self.project_id json:json];
    
    complete(YES);
}


-(void) initWithOnlineOnComplete:(void (^_Nonnull)(BOOL success))complete
{
    [WildCardConstructor sharedInstance].onLineMode = YES;
    NSString* path = [NSString stringWithFormat:@"https://console-api.deavil.com/api/project/%@", self.project_id];
//    NSString* path = [NSString stringWithFormat:@"http://192.168.45.205:6111/api/project/%@", self.project_id];

    NSString* url = [NSString stringWithFormat:path, self.project_id];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* responseJsonObject) {
        if(responseJsonObject != nil)
        {
            [self initWithProject:self.project_id json:responseJsonObject];
            
            complete(YES);
        }
        else
        {
            complete(NO);
        }
    }];
}

-(void)saveLastProject:(NSMutableDictionary*)json {
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:json options:0 error:nil];
    id aaa = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *prefix = aaa[0];
    NSString* targetPath = [prefix stringByAppendingPathComponent:[@"last_project" stringByAppendingPathExtension:@"json"]];
    [jsonData writeToFile:targetPath atomically:YES];
}

-(NSMutableDictionary*)readLastProject {
    id aaa = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *prefix = aaa[0];
    NSString* targetPath = [prefix stringByAppendingPathComponent:[@"last_project" stringByAppendingPathExtension:@"json"]];
    if([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        NSData* data = [NSData dataWithContentsOfFile:targetPath];
        if(data) {
            return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
    }
    return nil;
}

-(void) initWithOnlineVersion:(NSString*)version onComplete:(void (^_Nonnull)(BOOL success))complete
{
    [WildCardConstructor sharedInstance].onLineMode = YES;
    NSString* path = [NSString stringWithFormat:@"http://img.deavil.com/dist/%@/%@/json/%@.json",
                      self.project_id,
                      version,
                      self.project_id];
    NSString* url = [NSString stringWithFormat:path, self.project_id];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* responseJsonObject) {
        if(responseJsonObject != nil)
        {
            [self saveLastProject:responseJsonObject];
            [self initWithProject:self.project_id json:responseJsonObject];
            complete(YES);
        }
        else
        {
            id project = [self readLastProject];
            if(project) {
                [self initWithProject:self.project_id json:project];
                complete(YES);
            }
            else
                complete(NO);
        }
    }];
}

-(void)initWithProject:(NSString*)projectId json:(id)projectJson {
    NSString* project_id = self.project_id;
    _cloudJsonMap = projectJson[@"cloudJsonMap"] ;
    _tabletCloudJsonMap = projectJson[@"tabletCloudJsonMap"] ;
    _landscapeCloudJsonMap = projectJson[@"landscapeCloudJsonMap"] ;
    _tabletLandscapeCloudJsonMap = projectJson[@"tabletLandscapeCloudJsonMap"] ;
    _themeCloudJsonMap = projectJson[@"themeCloudJsonMap"] ;
    _use_theme = [projectJson[@"use_theme"] boolValue];
    _screenMap = projectJson[@"screenMap"];
    _blockMap = projectJson[@"block"];
    _project = projectJson[@"project"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:
     [NSString stringWithFormat:@"UDID_%@", project_id]
     ];
    [[NSUserDefaults standardUserDefaults] setObject:@"iphone" forKey:
     [NSString stringWithFormat:@"MODEL_%@", project_id]];
    [[NSUserDefaults standardUserDefaults] setObject:@"iOS" forKey:
     [NSString stringWithFormat:@"OS_%@", project_id]];
     
    [[NSUserDefaults standardUserDefaults] setObject:[[UIDevice currentDevice] systemVersion] forKey:
     [NSString stringWithFormat:@"OS_VERSION_%@", project_id]];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:[NSString stringWithFormat:@"APP_VERSION_%@", project_id]];
        
    [[NSUserDefaults standardUserDefaults] setObject:@"Apple Inc." forKey:
     [NSString stringWithFormat:@"MANUFACTURER_%@", project_id]];
    [[NSUserDefaults standardUserDefaults] setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:[NSString stringWithFormat:@"PACKAGE_%@", project_id]];
    
    [[NSUserDefaults standardUserDefaults] setObject:project_id forKey:[NSString stringWithFormat:@"PROJECT_ID_%@", project_id]];
    
    NSString* fcm = [[NSUserDefaults standardUserDefaults] objectForKey:@"FCM"];
    if(fcm)
        [[NSUserDefaults standardUserDefaults] setObject:fcm forKey:[NSString stringWithFormat:@"FCM_%@", project_id]];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"x-access-token_1605234988599"]
                                              forKey:[NSString stringWithFormat:@"DEVIL_X_ACCESS_TOKEN_%@", project_id]];
    
    [WildCardConstructor resetIsTablet];
    [[NSUserDefaults standardUserDefaults] setObject:IS_TABLET?@"Y":@"N" forKey:[NSString stringWithFormat:@"IS_TABLET_%@", project_id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [WildCardConstructor resetSketchWidth];
    
    if(projectJson[@"language"]) {
        BOOL collect_prod = [projectJson[@"language_collect_prod"] boolValue];
        [DevilLang parseLanguage:projectJson[@"language"] :collect_prod];
    } else {
        [[DevilLang sharedInstance] clear];
    }
    
    if(projectJson[@"default_word_wrap"])
        self.default_word_wrap = [projectJson[@"default_word_wrap"] boolValue];
}

-(NSMutableDictionary*_Nullable) getAllBlockJson
{
    return _cloudJsonMap;
}

-(NSString*_Nullable) getBlockIdByName:(NSString*_Nonnull)blockName{
    id keys = [_blockMap allKeys];
    for(id k in keys) {
        if([_blockMap[k][@"name"] isEqualToString:blockName]){
            return k;
        }
    }
    return nil;
}

-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey {
    return [self getBlockJson:blockKey :NO];
}

-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey :(BOOL)landscape
{
    id r = nil;
    if(_use_theme) {
        NSString* theme = [Jevil get:@"THEME"];
        if (theme != nil && _themeCloudJsonMap != nil && _themeCloudJsonMap[blockKey] != nil) {
            id theTheme = _themeCloudJsonMap[blockKey][theme];
            if (theTheme != nil) {
                if (IS_TABLET && landscape && theTheme[@"tablet_landscape_cloud_json"] != nil)
                    r = theTheme[@"cloud_json"];
                else if (IS_TABLET && theTheme[@"tablet_cloud_json"] != nil)
                    r = theTheme[@"tablet_cloud_json"];
                else if (landscape && theTheme[@"landscape_cloud_json"] != nil)
                    r = theTheme[@"landscape_cloud_json"];
                else if (theTheme[@"cloud_json"] != nil)
                    r = theTheme[@"cloud_json"];
            }
        }
    }
    
    if(r == nil) {
        if(IS_TABLET && landscape && _tabletCloudJsonMap[blockKey] != nil)
            return _tabletLandscapeCloudJsonMap[blockKey];
        else if(IS_TABLET && _tabletCloudJsonMap[blockKey] != nil)
            return _tabletCloudJsonMap[blockKey];
        else if(_landscapeCloudJsonMap[blockKey] != nil && landscape)
            return _landscapeCloudJsonMap[blockKey];
        else if(_cloudJsonMap[blockKey] != nil)
            return _cloudJsonMap[blockKey];
    }
    return r;
}

-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey withName:(NSString*)nodeName
{
    if(_cloudJsonMap[blockKey] != nil)
    {
        NSMutableDictionary* root = _cloudJsonMap[blockKey];
        return [self findJsonRoot:root withName:nodeName];
    }
    else
        return nil;
}

-(NSString*) getDeclaredCode
{
    id declared = self.project[@"declared"];
    id ks = [declared allKeys];
    NSString* r = @"";
    for(id k in ks) {
        NSString* s = declared[k];
        r = [r stringByAppendingFormat:@"%@\n", s];
    }
    return r;
}


-(NSString*) getScreenIdByName:(NSString*)screenName {
    id keys = [_screenMap allKeys];
    for(id k in keys) {
        if([_screenMap[k][@"name"] isEqualToString:screenName]){
            return k;
        }
    }
    return nil;
}

- (NSString*) getFirstBlock:(NSString*)screenId {
    id s = _screenMap[screenId];
    id list = s[@"list"];
    if([list count] > 0) {
        id block_id = [list[0][@"block_id"] stringValue];
        return block_id;
    }
    return nil;
}

- (BOOL) isFirstBlockFitScreen:(NSString*)screenId {
    id s = _screenMap[screenId];
    id list = s[@"list"];
    if([list count] > 0) {
        id block_id = [list[0][@"block_id"] stringValue];
        id block = _blockMap[block_id];
        if(block && block[@"fit_to_screen"] != [NSNull null] && [block[@"fit_to_screen"] boolValue])
            return YES;
    }
    return NO;
}

- (void) firstBlockFitScreenIfTrue:(NSString*)screenId sketch_height_more:(int)height landscape:(BOOL)isLandscape{
    id s = _screenMap[screenId];
    id list = s[@"list"];
    if([list count] > 0) {
        id block_id = [list[0][@"block_id"] stringValue];
        id block = _blockMap[block_id];
        if(block && block[@"fit_to_screen"] != [NSNull null] && [block[@"fit_to_screen"] boolValue]) {
            id cj = [self getBlockJson:block_id :isLandscape];
            [WildCardConstructor updateSketchWidth:cj];
            [WildCardUtil fitToScreen: cj sketch_height_more:height];
        }
    }
}

-(NSMutableDictionary*_Nullable) findJsonRoot:(NSMutableDictionary*_Nonnull)root withName:(NSString*)nodeName
{
    if(root == nil)
        return nil;
    
    if([root[@"name"] isEqualToString:nodeName])
        return root;
    
    NSArray* a = root[@"layers"];
    if(a != nil)
    {
        for(int i=0;i<[a count];i++)
        {
            NSMutableDictionary* c = [self findJsonRoot:a[i] withName:nodeName];
            if(c != nil)
                return c;
        }
    }
    
    return nil;
}


-(NSString*)getFirstScreenId {
    id keys = [_screenMap allKeys];
    for(id k in keys) {
        if(_screenMap[k][@"splash"] != [NSNull null] && [_screenMap[k][@"splash"] boolValue]){
            return [NSString stringWithFormat:@"%@", k];
        }
    }
    return nil;
}

-(NSMutableArray*)getScreenIfList:(NSString*)screen
{
    return _screenMap[screen][@"list"];
}

-(NSMutableDictionary*)getScreen:(NSString*)screenId{
    return _screenMap[screenId];
}

-(NSMutableDictionary*)getHeaderCloudJson:(NSString*)screenId :(BOOL)isLandscape{
    id h = _screenMap[screenId][@"header_block_id"];
    if(h != nil && h != [NSNull null] && ![@"" isEqual:h]){
        NSString* header_block_id =  [_screenMap[screenId][@"header_block_id"] stringValue];
        return [self getBlockJson:header_block_id:isLandscape];
    } else
        return nil;
}

-(NSMutableDictionary*)getFooterCloudJson:(NSString*)screenId :(BOOL)isLandscape{
    id h = _screenMap[screenId][@"footer_block_id"];
    if(h != nil && h != [NSNull null] && ![@"" isEqual:h]){
        NSString* footer_block_id =  [_screenMap[screenId][@"footer_block_id"] stringValue];
        id n = _screenMap[screenId][@"fix_footer"];
        BOOL fix_footer = n == [NSNull null] || [n boolValue] == false ? false : true;
        id r = [@{} mutableCopy];
        r[@"fix_footer"] = fix_footer?@TRUE:@FALSE;
        r[@"cloudJson"] = [self getBlockJson:footer_block_id:isLandscape];
        return r;
    } else
        return nil;
}

-(NSMutableDictionary*)getInsideFooterCloudJson:(NSString*)screenId :(BOOL)isLandscape{
    id h = _screenMap[screenId][@"inside_footer_block_id"];
    if(h != nil && h != [NSNull null] && ![@"" isEqual:h]){
        NSString* header_block_id =  [_screenMap[screenId][@"inside_footer_block_id"] stringValue];
        return [self getBlockJson:header_block_id:isLandscape];
    } else
        return nil;
}

-(void)onExtensionPageControlClickListener:(id)sender {
    WildCardUIPageControl* pc = (WildCardUIPageControl*)sender;
    UIView* v = [pc.meta getView:pc.viewPagerNodeName];
    WildCardUICollectionView* c = (WildCardUICollectionView*)[v subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    [adapter scrollToIndex:(int)pc.currentPage view:c];
}

-(void)onExtensionCheckBoxClickListener:(WildCardUITapGestureRecognizer *)recognizer
{
    WildCardMeta* meta = recognizer.meta;
    NSDictionary* extension = recognizer.extensionForCheckBox;
    NSString* onNodeName = extension[@"select3"];
    NSString* offNodeName = extension[@"select4"];
    NSString* watch = extension[@"select5"];
    NSString* onValue = extension[@"select6"];
    NSString* clickAction = extension[@"select8"];
    WildCardUIView* onNodeView = meta.generatedViews[onNodeName];
    WildCardUIView* offNodeView = meta.generatedViews[offNodeName];
    BOOL check = YES;
    if([meta.correspondData[watch] isEqualToString:onValue])
    {
        check = YES;
    }
    else
    {
        check = NO;
    }
    
    check = !check;
    
    id layer = recognizer.rule.replaceJsonLayer;
    recognizer.rule.replaceView.accessibilityLabel = [NSString stringWithFormat:@"%@ %@", layer[@"name"], check?@"선택됨":@"선택안됨"];
    
    if(check)
    {
        onNodeView.hidden = NO;
        offNodeView.hidden = YES;
        
        meta.correspondData[watch] = onValue;
    }
    else
    {
        onNodeView.hidden = YES;
        offNodeView.hidden = NO;
        
        meta.correspondData[watch] = @"N";
    }
    
    //TODO trigger should contain meta, triggering view, node name
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    [WildCardAction parseAndConducts:trigger action:clickAction meta:recognizer.meta];
    
    
    NSMutableDictionary* t = meta.triggersByName[recognizer.nodeName];
    if(t[WILDCARD_NODE_CLICKED] != nil)
        [t[WILDCARD_NODE_CLICKED] doAllAction];
}

-(void)onClickListener:(WildCardUITapGestureRecognizer *)recognizer
{
    WildCardUIView* vv = (WildCardUIView*)recognizer.view;
    NSString *action = vv.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    trigger.node = vv;
    [[WildCardEventTracker sharedInstance] onClickEvent:recognizer.ga data:recognizer.meta.correspondData];
    [WildCardAction parseAndConducts:trigger action:action meta:recognizer.meta];
}

-(void)script:(WildCardUITapGestureRecognizer *)recognizer
{
    WildCardUIView* vv = (WildCardUIView*)recognizer.view;
    NSString *script = vv.stringTag;
    WildCardTrigger* trigger = [[WildCardTrigger alloc] init];
    trigger.node = vv;
    id gaData = nil;
    if(recognizer.gaDataPath)
        gaData = [MappingSyntaxInterpreter getJsonWithPath:recognizer.meta.correspondData :recognizer.gaDataPath];
    [[WildCardEventTracker sharedInstance] onClickEvent:recognizer.ga data:gaData];
    [WildCardAction execute:trigger script:script meta:recognizer.meta];
}



static float SKETCH_WIDTH = 360;
static float SCREEN_WIDTH = 0;
static float SCREEN_HEIGHT = 0;
static BOOL IS_TABLET = NO;

+(void)resetSketchWidth{
    NSString* screenId = [[WildCardConstructor sharedInstance] getFirstScreenId];
    
    id s = [WildCardConstructor sharedInstance].screenMap[screenId];
    id list = s[@"list"];
    if([list count] > 0) {
        id block_id = [list[0][@"block_id"] stringValue];
        id cloudJson = [[WildCardConstructor sharedInstance] getBlockJson:block_id];
        SKETCH_WIDTH = [cloudJson[@"frame"][@"w"] intValue];
        if(IS_TABLET)
            SKETCH_WIDTH *= 2;
        [WildCardUtil setSketchWidth:SKETCH_WIDTH];
    }
}

+(void)updateSketchWidth:(id)layer{
    float w = [layer[@"frame"][@"w"] floatValue];
    if(w > 360)
        SKETCH_WIDTH = w;
    else
        SKETCH_WIDTH = 360;
    
    [WildCardUtil setSketchWidth:SKETCH_WIDTH];
}

+(void)updateScreenWidthHeight:(float)w :(float)h {
    SCREEN_WIDTH = w;
    SCREEN_HEIGHT = h;
    [WildCardUtil setScreenWidthHeight:SCREEN_WIDTH:SCREEN_HEIGHT];
}

+(void)resetIsTablet{
    IS_TABLET = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

+(BOOL)isTablet{
    return IS_TABLET;
}

+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer
{
    return [WildCardConstructor constructLayer:cell withLayer:layer withParentMeta:nil depth:0 instanceDelegate:nil];
}
+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer instanceDelegate:(id)delegate
{
    return [WildCardConstructor constructLayer:cell withLayer:layer withParentMeta:nil depth:0 instanceDelegate:delegate];
}

+(WildCardUIView*_Nonnull) constructLayer:(UIView*_Nullable)cell withLayer:(NSDictionary*_Nonnull)layer withParentMeta:(WildCardMeta*)parentMeta depth:(int)depth instanceDelegate:(id)delegate
{
    float w = [layer[@"frame"][@"w"] floatValue];
    double s = [[NSDate date] timeIntervalSince1970];
    WildCardMeta* meta = [[WildCardMeta alloc] init];
    meta.wildCardConstructorInstanceDelegate = delegate;
    if(parentMeta) {
        meta.parentMeta = parentMeta;
        if(!parentMeta.childMetas) {
            parentMeta.childMetas = [@[] mutableCopy];
        }
        [parentMeta.childMetas addObject:meta];
    }
    WildCardUIView* v = [WildCardConstructor constructLayer1:cell:layer:nil:meta:depth:0];
    [WildCardConstructor constructLayer2:cell:layer:nil:meta:depth:0];
    v.meta = meta;
    meta.rootView = v;
    double e = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"Construct time - %f", (e-s));
    return v;
}

+(void) userInteractionEnableToParentPath:(UIView*)vv depth:(int)depth
{
    WildCardUIView* parent_cursor = (WildCardUIView*)[vv superview];
    for(int i=0;i<depth;i++)
    {
        if(parent_cursor == nil)
            break;
        
        //if([parent_cursor isKindOfClass:[WildCardUIView class]])
        //NSLog(@"userInteractionEnableToParentPath - %@", [parent_cursor name]);
        parent_cursor.userInteractionEnabled = YES;
        parent_cursor = (WildCardUIView*)[parent_cursor superview];
    }
}

+(void) followSizeFromFather:(UIView*)vv child:(UIView*)tv
{
    tv.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(tv, vv);
    
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tv]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [vv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tv]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
}


+(WildCardUIView*) constructLayer1:(WildCardUIView*)parent
                                  :(NSDictionary*)layer
                                  :(NSDictionary*)pLayer
                                  :(WildCardMeta*)wcMeta
                                  :(int)depth
                                  :(int)subindex
{
    NSString* _class = [layer objectForKey:@"_class"];
    NSString* name = [layer objectForKey:@"name"];
    NSMutableArray* outRules = wcMeta.replaceRules;
    
    WildCardUIView* vv = [[WildCardUIView alloc] init];
    vv.name = name;
    vv.depth = depth;
    vv.isAccessibilityElement = NO;
    
    NSDictionary* extension = layer[@"extension"];
    NSDictionary* triggerMap = layer[@"trigger"];
    
    @try{
        
        [wcMeta.generatedViews setObject:vv forKey:name];
        
        if([layer objectForKey:@"hiddenCondition"] != nil || [layer objectForKey:@"showCondition"] != nil)
        {
            ReplaceRuleHidden* rule = [[ReplaceRuleHidden alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:nil];
        }
        
        if([layer objectForKey:@"padding"] != nil) {
            NSDictionary* padding = [layer objectForKey:@"padding"];
            if([padding objectForKey:@"paddingLeft"] != nil) {
                float paddingLeft = [[padding objectForKey:@"paddingLeft"] floatValue];
                paddingLeft = [WildCardConstructor convertSketchToPixel:paddingLeft];
                vv.paddingLeft = paddingLeft;
            }
            
            if([padding objectForKey:@"paddingRight"] != nil) {
                float paddingRight = [[padding objectForKey:@"paddingRight"] floatValue];
                paddingRight = [WildCardConstructor convertSketchToPixel:paddingRight];
                vv.paddingRight = paddingRight;
            }
            
            if([padding objectForKey:@"paddingTop"] != nil) {
                float paddingTop = [[padding objectForKey:@"paddingTop"] floatValue];
                paddingTop = [WildCardConstructor convertSketchToPixel:paddingTop];
                vv.paddingTop = paddingTop;
            }
            
            if([padding objectForKey:@"paddingBottom"] != nil) {
                float paddingBottom = [[padding objectForKey:@"paddingBottom"] floatValue];
                paddingBottom = [WildCardConstructor convertSketchToPixel:paddingBottom];
                vv.paddingBottom = paddingBottom;
            }
        }
        
        
        CGRect rect = [WildCardConstructor getFrame:layer:parent];
        vv.frame = rect;
        
        if([layer objectForKey:@"margin"] != nil) {
            NSDictionary* margin = [layer objectForKey:@"margin"];
            
            if([margin objectForKey:@"marginRight"] != nil) {
                vv.rightMargin = [self convertSketchToPixel:[[margin objectForKey:@"marginRight"] floatValue]];
            }
            if([margin objectForKey:@"marginBottom"] != nil) {
                vv.bottomMargin = [self convertSketchToPixel:[[margin objectForKey:@"marginBottom"] floatValue]];
            }
        }
        
        if(triggerMap != nil)
        {
            //TODO
        }
        
        NSDictionary* frame = [layer objectForKey:@"frame"];
        if([frame objectForKey:@"alignment"] != nil)
        {
            int alignment = [[frame objectForKey:@"alignment"] intValue];
            vv.alignment = alignment;
            
            switch (alignment) {
                case GRAVITY_VERTICAL_CENTER:
                case GRAVITY_BOTTOM:
                case GRAVITY_HORIZONTAL_CENTER:
                case GRAVITY_RIGHT:
                case GRAVITY_CENTER:
                case GRAVITY_LEFT_VCENTER:
                case GRAVITY_LEFT_BOTTOM:
                case GRAVITY_RIGHT_TOP:
                case GRAVITY_RIGHT_VCENTER:
                case GRAVITY_RIGHT_BOTTOM:
                case GRAVITY_HCENTER_TOP:
                case GRAVITY_HCENTER_BOTTOM:
                    [wcMeta addGravity:vv depth:depth];
                    break;
                default:
                    break;
            }
        }
        
        if(vv.frame.size.width == 0)
            vv.wrap_width = YES;
        
        if(vv.frame.size.height == 0)
            vv.wrap_height = YES;
        
        if([layer[@"match_h"] boolValue]) {
            vv.match_height = YES;
            [wcMeta addMatchParent:vv depth:depth];
        }
        
        if(vv.wrap_width || vv.wrap_height)
        {
            [wcMeta addWrapContent:vv depth:depth];
        }
        
        if(parent != nil)
            [parent addSubview:vv];
        
        NSArray *layers = [layer objectForKey:@"layers"];
        id shouldContinueChild = @[];
        id result = [@{} mutableCopy];
        
        if(extension != nil)
        {
            UIView* extensionView = [WildCardExtensionConstructor construct:vv:layer:wcMeta];
            if(extensionView != nil) {
                CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
                containerRect.origin.x = containerRect.origin.y = 0;
                if([extensionView isMemberOfClass:[WildCardUITextView class]] && ((WildCardUITextView*)extensionView).variableHeight ) {
                    [wcMeta addWrapContent:vv depth:depth];
                }
                
                extensionView.frame = containerRect;
                [vv addSubview:extensionView];
                
            }
            [outRules addObject:ReplaceRuleExtension(vv ,layer, @"")];
            
            vv.userInteractionEnabled = YES;
            [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            _class = @"extension";
        }
        
        if(layer[@"market"]) {
            ReplaceRuleMarket* rule = [[ReplaceRuleMarket alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        }
        
        if([layer objectForKey:@"clickContent"] || [layer objectForKey:@"clickJavascript"])
        {
            ReplaceRuleClick* rule = [[ReplaceRuleClick alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
            vv.isAccessibilityElement = YES;
            vv.accessibilityTraits = UIAccessibilityTraitButton;
            vv.accessibilityLabel = name;
            
            if(layer[@"accessibility"]){
                ReplaceRuleAccessibility* rule2 = [[ReplaceRuleAccessibility alloc] initWithRuleJson:layer];
                [outRules addObject:rule2];
                [rule2 constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
            }
            
        } else if(extension == nil) {
            vv.userInteractionEnabled = NO;
        }
        
        if(layer[@"backgroundGradient"] != nil){
            NSDictionary* backgroundGradient = layer[@"backgroundGradient"];
            CAGradientLayer* gradient = [CAGradientLayer layer];
            UIColor *colorOne = [WildCardUtil colorWithHexString:backgroundGradient[@"fromColor"]];
            UIColor *colorTwo = [WildCardUtil colorWithHexString:backgroundGradient[@"toColor"]];
            gradient.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
            gradient.frame = vv.frame;
            gradient.startPoint = CGPointMake([backgroundGradient[@"fromX"] floatValue],[backgroundGradient[@"fromY"] floatValue]);
            gradient.endPoint = CGPointMake([backgroundGradient[@"toX"] floatValue],[backgroundGradient[@"toY"] floatValue]);
            
            [vv.layer addSublayer:gradient];
        }
        else if([layer objectForKey:@"backgroundColor"] != nil)
        {
            vv.backgroundColor = [WildCardUtil colorWithHexString:[layer objectForKey:@"backgroundColor"]];
        }
        
        //shadow
        if([layer objectForKey:@"shadow"]){
            
            //NSLog(@"shadow %@", name);
            id shadow = layer[@"shadow"];
            
            float offsetX = [WildCardConstructor convertSketchToPixel:[shadow[@"offsetX"] intValue]];
            float offsetY = [WildCardConstructor convertSketchToPixel:[shadow[@"offsetY"] intValue]];
            float blurRadius = [WildCardConstructor convertSketchToPixel:[shadow[@"blurRadius"] intValue]];
            vv.layer.masksToBounds = NO;
            vv.layer.shadowOffset = CGSizeMake(offsetX, offsetY);
            vv.layer.shadowRadius = blurRadius;
            vv.layer.shadowOpacity = [WildCardUtil alphaWithHexString:shadow[@"color"]];
            vv.layer.shadowColor = [[WildCardUtil colorWithHexStringWithoutAlpha:shadow[@"color"]] CGColor];
            //vv.backgroundColor = [UIColor whiteColor];
        }
        
        //        if([@"text" isEqualToString:_class])
        //        {
        //            vv.backgroundColor = [UIColor redColor];
        //        }
        
        if([layer objectForKey:@"path"] != nil)
        {
            //TODO : path
            //vv.alpha =[[layer objectForKey:@"path"] floatValue];
        }
        
        if([layer objectForKey:@"alpha"] != nil)
        {
            vv.alpha =[[layer objectForKey:@"alpha"] floatValue];
        }
        
        if(layer[@"borderColor"] != nil && [layer objectForKey:@"borderWidth"] != nil)
        {
            UIColor* borderColor = [WildCardUtil colorWithHexString:[layer objectForKey:@"borderColor"]];
            float borderWidth =[[layer objectForKey:@"borderWidth"] floatValue];
            borderWidth = [WildCardConstructor convertSketchToPixel:borderWidth];
            
            vv.layer.borderColor = [borderColor CGColor];
            
            // 2021.08.29 하프 라운드의 경우 찌그러지는 현상이 있어서 색이 같으면 border를 없앤다
            if(layer[@"borderColor"] != [NSNull null] && [layer[@"borderColor"] isEqualToString:layer[@"backgroundColor"]])
                vv.layer.borderWidth = 0;
            else
                vv.layer.borderWidth = borderWidth;
            
            
            if ([layer objectForKey:@"borderRound"] && [[layer objectForKey:@"borderRound"] boolValue]) {
                
                if ([layer objectForKey:@"borderRoundCorner"])
                {
                    float c = [WildCardConstructor convertSketchToPixel:[[layer objectForKey:@"borderRoundCorner"] intValue]];
                    float h = [[[layer objectForKey:@"frame"] objectForKey:@"h"] floatValue];
                    //2019.12.25 vv.wrap_height 일 경우 원으로 만들어야할 경우가 있다고?? 일단 기억이 안나서 vv.wrap_height를 추가한다.
                    if(c < h/2 || vv.wrap_height)
                    {
                        vv.layer.cornerRadius = c;
                        if(layer[@"borderRoundCorners"]){
                            if(@available(iOS 11.0, *)){
                                id clist = layer[@"borderRoundCorners"];
                                vv.layer.maskedCorners = 0;
                                if([clist[0] intValue] > 0)
                                    vv.layer.maskedCorners |= kCALayerMinXMinYCorner;
                                if([clist[1] intValue] > 0)
                                    vv.layer.maskedCorners |= kCALayerMaxXMinYCorner;
                                if([clist[2] intValue] > 0)
                                    vv.layer.maskedCorners |= kCALayerMaxXMaxYCorner;
                                if([clist[3] intValue] > 0)
                                    vv.layer.maskedCorners |= kCALayerMinXMaxYCorner;
                            }
                        }
                    }
                    else
                    {
                        if(vv.wrap_height)
                        {
                            vv.cornerRadiusHalf = YES;
                        }
                        else
                        {
                            vv.layer.cornerRadius = vv.frame.size.height/2;
                        }
                    }
                }
                else
                {
                    if(vv.wrap_height)
                    {
                        vv.cornerRadiusHalf = YES;
                    }
                    else
                    {
                        vv.layer.cornerRadius = vv.frame.size.height/2;
                    }
                }
                //vv.layer.masksToBounds = true;
                
                if ([layer objectForKey:@"backgroundColor"] != nil) {
                    //TODO
                    //vv.setFillColor(Color.parseColor(layer.optString("backgroundColor")));
                    //vv.backgroundColor = [UIColor clearColor];
                }
            }
        }
        
        if ([layer objectForKey:(@"colorMapping")] != nil)
        {
            ReplaceRuleColor* rule = [[ReplaceRuleColor alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        }
        
        if ([layer objectForKey:(@"qrcode")] != nil)
        {
            ReplaceRuleQrcode* rule = [[ReplaceRuleQrcode alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        } else if ([layer objectForKey:(@"imageContent")] != nil && ![_class isEqualToString:@"extension"])
        {
            ReplaceRuleImage* rule = [[ReplaceRuleImage alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        } else if ([layer objectForKey:(@"imageContentResource")] != nil && ![_class isEqualToString:@"extension"]) {
            ReplaceRuleImageResource* rule = [[ReplaceRuleImageResource alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        } else if(layer[@"video"]){
            ReplaceRuleVideo* replaceRuleVideo = [[ReplaceRuleVideo alloc] initWithRuleJson:layer[@"video"]];
            [replaceRuleVideo constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
            [outRules addObject:replaceRuleVideo];
        } else if ([layer objectForKey:(@"localImageContent")] != nil &&  ![_class isEqualToString:@"extension"]) {
            ReplaceRuleLocalImage* rule = [[ReplaceRuleLocalImage alloc] initWithRuleJson:layer];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        } else if ([layer objectForKey:(@"web")] != nil) {
            ReplaceRuleWeb* rule = [[ReplaceRuleWeb alloc] init];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        } else if ([layer objectForKey:(@"icon")] != nil) {
            ReplaceRuleIcon* rule = [[ReplaceRuleIcon alloc] init];
            [outRules addObject:rule];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
        } else if ([layer objectForKey:(@"lottie")] != nil) {
            id lottie = layer[@"lottie"];
            NSString* url = lottie[@"url"];
            
            [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* json) {
                
                float lw = [json[@"w"] floatValue];
                float lh = [json[@"h"] floatValue];
                float todow, todoh;
                float w = vv.frame.size.width;
                float h = vv.frame.size.height;
                if(w/lw > h/lh){
                    //높이에 맞춤
                    todoh = h;
                    todow = lw * h/lh;
                } else {
                    todow = w;
                    todoh = lh * w/lw;
                }
                 
                LOTAnimationView* lv = [LOTAnimationView animationFromJSON:json];
                lv.contentMode = UIViewContentModeScaleAspectFit;
                lv.frame = CGRectMake(0, 0, todow, todoh);
                lv.center = CGPointMake(w/2.0f, h/2.0f);
                [vv addSubview:lv];
                
                if([@"Y" isEqualToString:lottie[@"infinite"]])
                    lv.loopAnimation = YES;
                
                if([@"Y" isEqualToString:lottie[@"autoStart"]])
                    [lv play];
            }];
        }
        
        if(layer[@"strip"]){
            ReplaceRuleStrip* rule = [[ReplaceRuleStrip alloc] init];
            [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
            [outRules addObject:rule];
        }
        
        if([@"text" isEqualToString:_class])
        {
            WildCardUILabel* tv = [[WildCardUILabel alloc] init];
            //tv.isAccessibilityElement = YES;
            [vv addSubview:tv];
            
            if([@"Y" isEqualToString:layer[@"textSelection"]]) {
                tv.textSelection = true;
            }
            
            tv.frame = CGRectMake(0, 0, vv.frame.size.width, vv.frame.size.height);
            tv.lineBreakMode = NSLineBreakByTruncatingTail;// | NSLineBreakByCharWrapping;
            
            NSDictionary* textSpec = [layer objectForKey:@"textSpec"];
            
            if([[textSpec objectForKey:@"stroke"] boolValue])
                tv.stroke = YES;
            else
                tv.stroke = NO;
            
            int halignment = 1;
            int valignment = 0;
            if([textSpec objectForKey:@"alignment"] != nil)
                halignment = [[textSpec objectForKey:@"alignment"] intValue];
            if([textSpec objectForKey:@"valignment"] != nil)
                valignment = [[textSpec objectForKey:@"valignment"] intValue];
            
            if(halignment == 3)
                halignment = GRAVITY_LEFT;
            else if(halignment == 17)
                halignment = GRAVITY_HORIZONTAL_CENTER;
            else if(halignment == 5)
                halignment = GRAVITY_RIGHT;
            
            if(valignment == 0) {
                valignment = GRAVITY_TOP;
            }
            else if(valignment == 1) {
                valignment = GRAVITY_VERTICAL_CENTER;
            }
            else if(valignment == 2) {
                valignment = GRAVITY_BOTTOM;
            }
            
            tv.alignment = halignment | valignment;
            
            if([WildCardUtil hasGravityCenterHorizontal:tv.alignment])
                tv.textAlignment = NSTextAlignmentCenter;
            else if([WildCardUtil hasGravityRight:tv.alignment])
                tv.textAlignment = NSTextAlignmentRight;
            
            
            float sketchTextSize = [[textSpec objectForKey:@"textSize"] floatValue];
            if(layer[@"dynamicTextSize"]) {
                NSString* s = [Jevil get:layer[@"dynamicTextSize"]];
                if(s)
                    sketchTextSize = [s intValue];
            }
            float textSize = [WildCardConstructor convertTextSize:sketchTextSize];
            
            if([[textSpec objectForKey:@"bold"] boolValue])
            {
                tv.font = [UIFont boldSystemFontOfSize:textSize];
            }
            else
            {
                tv.font = [UIFont systemFontOfSize:textSize];
            }
            
            
            if(!vv.wrap_width && [textSpec objectForKey:@"lines"] != nil)
            {
                int lines = [[textSpec objectForKey:@"lines"] intValue];
                tv.numberOfLines = lines;
            }
            else
            {
                //default should be 100 because static text
                tv.numberOfLines = 1000;
            }
            
            //tv.backgroundColor = [UIColor yellowColor];
            //vv.backgroundColor = [UIColor blueColor];
            
            if(vv.frame.size.width == 0)
            {
                tv.wrap_width = YES;
            }
            
            if(vv.frame.size.height == 0)
            {
                tv.wrap_height = YES;
            }
            
            if(frame[@"max_width"])
                tv.max_width = [WildCardUtil convertSketchToPixel:[frame[@"max_width"] intValue]];
            
            NSString* text = [textSpec objectForKey:@"text"];
            if(text == nil)
                text = name;
            
            tv.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
            
            if ([layer objectForKey:@"textContent"]) {
                ReplaceRuleText* rule = [[ReplaceRuleText alloc] initWithRuleJson:layer];
                [rule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
                rule.replaceView = tv;
                [outRules addObject:rule];
            }
            else
            {
                if([WildCardConstructor sharedInstance].textTransDelegate != nil )
                    text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
                [tv setText:text];
            }
            
            if(layer[@"lineBreak"] && [layer[@"lineBreak"] isEqualToString:@"word_wrap"])
                tv.word_wrap = YES;
            
            //tv.backgroundColor = [UIColor redColor];
            if(layer[@"timer"]){
                WildCardTimer* wildCardTimer = [[WildCardTimer alloc] initWith:wcMeta
                                                                              :tv
                                                                              :layer
                                                                              :name
                                                                              :vv
                                                ];
                [wildCardTimer startTimeFrom:tv.text];
            }
        }

        if([layer objectForKey:@"arrayContent"])
        {
            ReplaceRuleRepeat* replaceRule = [[ReplaceRuleRepeat alloc] initWithRuleJson:layer];
            [replaceRule constructRule:wcMeta parent:parent vv:vv layer:layer depth:depth result:result];
            if(result[@"shouldContinueChild"])
                shouldContinueChild = result[@"shouldContinueChild"];
            [outRules addObject:replaceRule];
        }
        
        for (int i = 0; layers != nil && i < [layers count]; i++)
        {
            NSDictionary* childLayer = [layers objectAtIndex:i];
            NSString* childName = childLayer[@"name"];
            if([shouldContinueChild containsObject:childName] ) {
                continue;
            } else if(extension != nil && [WildCardExtensionConstructor getExtensionType:extension] != WILDCARD_EXTENSION_TYPE_CHEKBOX
                    && [WildCardExtensionConstructor getExtensionType:extension] != WILDCARD_EXTENSION_TYPE_PROGRESS_BAR)
            {
                continue;
            }
            else if([[childLayer objectForKey:@"ignore"] boolValue])
            {
                continue;
            }
            else if(childLayer[@"fix"])
            {
                UIViewController* vc = [JevilInstance currentInstance].vc;
                if([vc isMemberOfClass:[DevilController class]]) {
                    DevilController* dc = (DevilController*)vc;
                    [dc addFixedView:childLayer x:0 y:0];
                }
                
                continue;
            }
            else
            {
                [WildCardConstructor constructLayer1:vv:childLayer:layer:wcMeta:depth+1:i];
            }
        }
    }
    @catch(NSException* e)
    {
        NSLog(@"%@", e);
    }
    return vv;
}

+(void) constructLayer2:(UIView*)parent
                       :(NSDictionary*)layer
                       :(NSDictionary*)pLayer
                       :(WildCardMeta*)wcMeta
                       :(int)depth
                       :(int)subindex
{
    if([layer objectForKey:@"hNextTo"] != nil)
    {
        NSString* prevName = [layer objectForKey:@"hNextTo"];
        NSString* nextName = [layer objectForKey:@"name"];
        WildCardUIView* prevView = [wcMeta.generatedViews objectForKey:prevName];
        WildCardUIView* nextView = [wcMeta.generatedViews objectForKey:nextName];
        
        if(!prevView)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"(Layout Rule)Node name '%@' is not exists.", prevName] userInfo:nil];
        if(!nextView)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"(Layout Rule)Node name '%@' is not exists.", nextName] userInfo:nil];
            
        float hNextToMargin = 0;
        
        if([layer objectForKey:@"hNextToMargin"] != nil)
        {
            float a = [[layer objectForKey:@"hNextToMargin"] floatValue];
            a = [WildCardConstructor convertSketchToPixel:a];
            hNextToMargin = [[[NSNumber alloc] initWithFloat:a] floatValue];
        }
        
        [wcMeta addNextChain:prevView next:nextView margin:hNextToMargin nextType:WC_NEXT_TYPE_HORIZONTAL depth:depth];
    }
    
    if([layer objectForKey:@"hPrevTo"] != nil)
    {
        NSString* prevName = [layer objectForKey:@"hPrevTo"];
        NSString* nextName = [layer objectForKey:@"name"];
        WildCardUIView* prevView = [wcMeta.generatedViews objectForKey:prevName];
        WildCardUIView* nextView = [wcMeta.generatedViews objectForKey:nextName];
        
        if(!prevView)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"(Layout Rule)Node name '%@' is not exists.", prevName] userInfo:nil];
        if(!nextView)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"(Layout Rule)Node name '%@' is not exists.", nextName] userInfo:nil];
        
        float hPrevToMargin = 0;
        
        if([layer objectForKey:@"hPrevToMargin"] != nil)
        {
            float a = [[layer objectForKey:@"hPrevToMargin"] floatValue];
            a = [WildCardConstructor convertSketchToPixel:a];
            hPrevToMargin = [[[NSNumber alloc] initWithFloat:a] floatValue];
        }
        
        [wcMeta addNextChain:prevView next:nextView margin:hPrevToMargin nextType:WC_NEXT_TYPE_HORIZONTAL_PREV depth:depth];
    }
    
    if([layer objectForKey:@"vNextTo"] != nil)
    {
        NSString* prevName = [layer objectForKey:@"vNextTo"];
        NSString* nextName = [layer objectForKey:@"name"];
        WildCardUIView* prevView = [wcMeta.generatedViews objectForKey:prevName];
        WildCardUIView* nextView = [wcMeta.generatedViews objectForKey:nextName];
        
        if(!prevView)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"(Layout Rule)Node name '%@' is not exists.", prevName] userInfo:nil];
        if(!nextView)
            @throw [NSException exceptionWithName:@"Devil" reason:[NSString stringWithFormat:@"(Layout Rule)Node name '%@' is not exists.", nextName] userInfo:nil];
        
        float vNextToMargin = 0;
        if([layer objectForKey:@"vNextToMargin"] != nil)
        {
            float a = [[layer objectForKey:@"vNextToMargin"] floatValue];
            a = [WildCardConstructor convertSketchToPixel:a];
            vNextToMargin = [[[NSNumber alloc] initWithFloat:a] floatValue];
        }
        
        [wcMeta addNextChain:prevView next:nextView margin:vNextToMargin nextType:WC_NEXT_TYPE_VERTICAL depth:depth];
    }
    
    NSString* name = layer[@"name"];
       
    if(layer[@"strip"]){
        id stripLayer = layer[@"strip"];
        WildCardPagerTabStrip* strip = [[wcMeta.generatedViews objectForKey:name] subviews][0];
        NSString* vpName = stripLayer[@"vp"];
        UIView* maybeVp = [[wcMeta.generatedViews objectForKey:vpName] subviews][0];
        if([[maybeVp class] isEqual:[UICollectionView class]]){
            UICollectionView* vp = (UICollectionView*)maybeVp;
            strip.viewPager = vp;
        }
    }
    
    NSArray *layers = [layer objectForKey:@"layers"];
    
    NSString* arrayContentTargetNode = nil;
    NSString* arrayContentTargetNodeSurfix = nil;
    NSString* arrayContentTargetNodePrefix = nil;
    NSString* arrayContentTargetNodeSelected = nil;
    
    if([layer objectForKey:@"arrayContent"])
    {
        NSDictionary* arrayContent = [layer objectForKey:@"arrayContent"];
        arrayContentTargetNode = [arrayContent objectForKey:@"targetNode"];
        arrayContentTargetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
        arrayContentTargetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
        arrayContentTargetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
    }
    
    for (int i = 0; layers != nil && i < [layers count]; i++)
    {
        NSDictionary* childLayer = [layers objectAtIndex:i];
        NSString* childName = [childLayer objectForKey:@"name"];
        if(arrayContentTargetNode != nil &&
           (
            [childName isEqualToString:arrayContentTargetNode]
            || [childName isEqualToString:arrayContentTargetNodeSurfix]
            || [childName isEqualToString:arrayContentTargetNodePrefix]
            || [childName isEqualToString:arrayContentTargetNodeSelected]
            )
           ) {
            continue;
        }
        else if([[childLayer objectForKey:@"ignore"] boolValue])
        {
            continue;
        }
        else if(childLayer[@"fix"])
        {
            continue;
        }
        else
        {
            [WildCardConstructor constructLayer2:nil :childLayer:layer:wcMeta:depth+1:i];
        }
    }
}


+(CGRect)getFrame:(NSDictionary*) layer : (WildCardUIView*)parentForPadding
{
    int screenWidth = SCREEN_WIDTH;
    NSDictionary* frame = [layer objectForKey:@"frame"];
    
    float w = [[frame objectForKey:@"w"] floatValue];
    float h = [[frame objectForKey:@"h"] floatValue];
    float x = [[frame objectForKey:@"x"] floatValue];
    float y = [[frame objectForKey:@"y"] floatValue];
    
    BOOL tableW = IS_TABLET ? [@"Y" isEqualToString:layer[@"tabletW"]] : false;
    BOOL tableH = IS_TABLET ? [@"Y" isEqualToString:layer[@"tabletH"]] : false;
    BOOL tableX = IS_TABLET ? [@"Y" isEqualToString:layer[@"tabletX"]] : false;
    BOOL tableY = IS_TABLET ? [@"Y" isEqualToString:layer[@"tabletY"]] : false;
    
    float scaleAdjust = screenWidth / SKETCH_WIDTH;
    
    if(w >= 0)
    {
        w *= scaleAdjust;
        if(tableW)
            w *= 2;
    }
    else
        w = 0;
    if(h >= 0)
    {
        h *= scaleAdjust;
        if(tableH)
            h *= 2;
    }
    else
        h = 0;
    
    if(x >= 0)
    {
        x *= scaleAdjust;
        if(tableX)
            x *= 2;
    }
    
    if(y >= 0)
    {
        y *= scaleAdjust;
        if(tableY)
            y *= 2;
    }
    
    if(parentForPadding != nil)
    {
        if([parentForPadding class] == [WildCardUIView class])
        {
            x += parentForPadding.paddingLeft;
            y += parentForPadding.paddingTop;
        }
    }
    
    //    h = round(h);
    //    w = round(w);
    //    x = round(x);
    //    y = round(y);
    
    CGRect r = CGRectMake(x, y, w, h);
    return r;
}

+(float) convertTextSize:(int)sketchTextSize
{
    
    if([WildCardConstructor sharedInstance].textConvertDelegate != nil )
        return [[WildCardConstructor sharedInstance].textConvertDelegate convertTextSize:sketchTextSize];
    
    float textSize = 0;
    switch(sketchTextSize)
    {
        case 15:
        case 14:
            textSize = sketchTextSize + 2.0f;
            break;
        case 11:
        case 12:
        case 18:
            textSize = sketchTextSize + 1.0f;
            break;
        default:
            textSize = sketchTextSize + 1.0f;
    }
    return textSize;
}

+(float) convertSketchToPixel:(float)p
{
    int screenWidth = SCREEN_WIDTH;
    float scaleAdjust = screenWidth / SKETCH_WIDTH;
    return p * scaleAdjust;
}




+(void) applyRuleMeta:(WildCardMeta*)meta withData:(NSMutableDictionary*)opt
{
    @try{
        //NSLog(@"applyRule");
        meta.correspondData = opt;
        for(int i=0;i<[meta.replaceRules count];i++)
        {
            ReplaceRule* rule = [meta.replaceRules objectAtIndex:i];
            [WildCardConstructor applyRuleCore:meta rule:rule withData:opt];
        }
        
        [meta requestLayout];
    }@catch(NSException* e)
    {
        NSLog(@"%@", e);
        NSLog(@"%@",[NSThread callStackSymbols]);
    }
}

+(void) applyRule:(WildCardUIView*)v withData:(NSMutableDictionary*)opt
{
    //NSLog(@"applyRule");
    v.meta.correspondData = opt;
    for(int i=0;i<[v.meta.replaceRules count];i++)
    {
        ReplaceRule* rule = [v.meta.replaceRules objectAtIndex:i];
        @try{
            [WildCardConstructor applyRuleCore:v.meta rule:rule withData:opt];
        }@catch(NSException* e)
        {
            NSLog(@"-----%@ - %@----------------", rule.replaceJsonLayer, rule);
            NSLog(@"%@", e);
            NSLog(@"%@",[NSThread callStackSymbols]);
        }
    }
    
    [v.meta requestLayout];
}


+(void) applyRuleCore:(WildCardMeta*)meta rule:(ReplaceRule*)rule withData:(NSMutableDictionary*)opt
{
    [rule updateRule:meta data:opt];
    
    if(rule.replaceType == RULE_TYPE_EXTENSION)
    {
        [WildCardExtensionConstructor update:meta extensionRule:(ReplaceRuleExtension*)rule data:opt];
    }
    else if(rule.replaceType == RULE_TYPE_REPLACE_URL)
    {
        NSDictionary* replaceUrl = rule.replaceJsonLayer;
        NSString* urlJsonPath = rule.replaceJsonLayer[@"url"];
        NSString* url = [MappingSyntaxInterpreter interpret:urlJsonPath :opt];
        NSString* onceKey = [NSString stringWithFormat:@"%@%@", @"RULE_TYPE_REPLACE_URL", url];
        if(url != nil && ![@"Y" isEqualToString:[opt objectForKey:onceKey]])
        {
            [opt setObject:@"Y" forKey:onceKey];
            
            NSString* fromJsonPath = replaceUrl[@"from"];
            NSString* toJsonPath = replaceUrl[@"to"];
            
            [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* responseJsonObject) {
                if(responseJsonObject != nil)
                {
                    NSObject* value = [MappingSyntaxInterpreter getJsonWithPath:responseJsonObject : fromJsonPath];
                    
                    NSRange lastT = [toJsonPath rangeOfString:@">" options:NSBackwardsSearch];
                    NSString* toJsonPathParent = nil;
                    NSString* toNodeName = toJsonPath;
                    
                    NSMutableDictionary* to = opt;
                    if(lastT.length > 0) {
                        toJsonPathParent = [toJsonPath substringToIndex:lastT.location];
                        toNodeName = [toJsonPath substringFromIndex:lastT.location +1];
                        
                        to = (NSMutableDictionary*)[MappingSyntaxInterpreter getJsonWithPath:opt : toJsonPathParent];
                    }
                    
                    if([value class] == [NSArray class] && [((NSArray*)value) count] == 0)
                    {
                        
                    }
                    else
                    {
                        if(value != nil)
                            [to setObject:value forKey:toNodeName];
                    }
                    
                    [WildCardConstructor applyRuleMeta:meta withData:opt];
                }
            }];
            
        }
    }
}

-(UIInterfaceOrientationMask) supportedOrientation : (NSString*)screenId :(NSString*)limitOrientation {
    UIInterfaceOrientationMask r = UIInterfaceOrientationMaskPortrait;
    id s = _screenMap[screenId];
    id list = s[@"list"];
    if([list count] > 0) {
        id blockKey = [list[0][@"block_id"] stringValue];
        
        if([@"landscape" isEqualToString:limitOrientation]) {
            if(IS_TABLET && _tabletLandscapeCloudJsonMap[blockKey] != nil) {
                r = UIInterfaceOrientationMaskLandscape;
            } else if(!IS_TABLET && _landscapeCloudJsonMap[blockKey] != nil) {
                r = UIInterfaceOrientationMaskLandscape;
            }
        } else {
            r = UIInterfaceOrientationMaskPortrait;
            if([DevilSdk sharedInstance].autoChangeOrientation)
                r = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
        }
    }
    
    return r;
}

@end
