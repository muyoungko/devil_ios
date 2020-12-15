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
    return self;
}

-(void) initWithLocalOnComplete:(void (^_Nonnull)(BOOL success))complete
{
    [WildCardConstructor sharedInstance].onLineMode = NO;
    NSString *path = [[NSBundle mainBundle] pathForResource:self.project_id ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:nil];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    _cloudJsonMap = json[@"cloudJsonMap"];
    _screenMap = json[@"screenMap"];
    _blockMap = json[@"block"];
    complete(YES);
}


-(void) initWithOnlineOnComplete:(void (^_Nonnull)(BOOL success))complete
{
    [WildCardConstructor sharedInstance].onLineMode = YES;
    NSString* path = [NSString stringWithFormat:@"https://console-api.deavil.com/api/project/%@", self.project_id];
    NSString* url = [NSString stringWithFormat:path, self.project_id];
    [[WildCardConstructor sharedInstance].delegate onNetworkRequest:url success:^(NSMutableDictionary* responseJsonObject) {
        if(responseJsonObject != nil)
        {
            _cloudJsonMap = responseJsonObject[@"cloudJsonMap"] ;
            _screenMap = responseJsonObject[@"screenMap"];
            _blockMap = responseJsonObject[@"block"];
            complete(YES);
        }
        else
        {
            complete(NO);
        }
    }];
}

-(NSMutableDictionary*_Nullable) getAllBlockJson
{
    return _cloudJsonMap;
}

-(NSMutableDictionary*_Nullable) getBlockJson:(NSString*_Nonnull)blockKey
{
    if(_cloudJsonMap[blockKey] != nil)
        return _cloudJsonMap[blockKey];
    else
        return nil;
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

-(NSString*) getScreenIdByName:(NSString*)screenName {
    id keys = [_screenMap allKeys];
    for(id k in keys) {
        if([_screenMap[k][@"name"] isEqualToString:screenName]){
            return k;
        }
    }
    return nil;
}

- (void) firstBlockFitScreenIfTrue:(NSString*)screenId sketch_height_more:(int)height {
    id s = _screenMap[screenId];
    id list = s[@"list"];
    if([list count] > 0) {
        id block_id = [list[0][@"block_id"] stringValue];
        id block = _blockMap[block_id];
        if([block[@"fit_to_screen"] boolValue])
            [WildCardUtil fitToScreen:_cloudJsonMap[block_id] sketch_height_more:height];
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
        if([_screenMap[k][@"splash"] boolValue]){
            return [k stringValue];
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

-(NSMutableDictionary*)getHeaderCloudJson:(NSString*)screenId{
    id h = _screenMap[screenId][@"header_block_id"];
    if(h != nil && h != [NSNull null]){
        NSString* header_block_id =  [_screenMap[screenId][@"header_block_id"] stringValue];
        return _cloudJsonMap[header_block_id];
    } else
        return nil;
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
    [WildCardAction parseAndConducts:trigger action:action meta:recognizer.meta];
}



static float SKETCH_WIDTH = 360;
static BOOL IS_TABLET = NO;
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
    if(w > 360)
        SKETCH_WIDTH = w;
    else
        SKETCH_WIDTH = 360;
    
    if(IS_TABLET)
        SKETCH_WIDTH *= 2;
    
    double s = [[NSDate date] timeIntervalSince1970];
    WildCardMeta* meta = [[WildCardMeta alloc] init];
    meta.wildCardConstructorInstanceDelegate = delegate;
    meta.parentMeta = parentMeta;
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
    
    NSDictionary* extension = layer[@"extension"];
    NSDictionary* triggerMap = layer[@"trigger"];
    
    @try{
        
        [wcMeta.generatedViews setObject:vv forKey:name];
        
        if([layer objectForKey:@"hiddenCondition"] != nil)
        {
            [outRules addObject:ReplaceRuleHidden(vv,layer, [layer objectForKey:@"hiddenCondition"])];
        }
        
        //        if([name isEqualToString:@"starsgroup"])
        //            vv.backgroundColor = [UIColor redColor];
        
        if([layer objectForKey:@"padding"] != nil) {
            
            //            if([name isEqualToString:@"stargroup"])
            //                vv.backgroundColor = [UIColor greenColor];
            
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
        {
            vv.wrap_width = YES;
        }
        if(vv.frame.size.height == 0)
        {
            vv.wrap_height = YES;
        }
        
        if(vv.wrap_width || vv.wrap_height)
        {
            [wcMeta addWrapContent:vv depth:depth];
        }
        
        if(parent != nil)
            [parent addSubview:vv];
        
        if(extension != nil)
        {
            UIView* extensionView = [WildCardExtensionConstructor construct:vv:layer:wcMeta];
            if(extensionView != nil) {
                CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
                containerRect.origin.x = containerRect.origin.y = 0;
                
                extensionView.frame = containerRect;
                [vv addSubview:extensionView];
            }
            [outRules addObject:ReplaceRuleExtension(vv ,layer, @"")];
            
            vv.userInteractionEnabled = YES;
            [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            _class = @"extension";
        }
        
        if([layer objectForKey:@"clickContent"] != nil)
        {
            [outRules addObject:ReplaceRuleClick(vv,layer, [layer objectForKey:@"clickContent"])];
            vv.userInteractionEnabled = YES;
            
            [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            
            WildCardUITapGestureRecognizer *singleFingerTap =
            [[WildCardUITapGestureRecognizer alloc] initWithTarget:[WildCardConstructor sharedInstance]
                                                            action:@selector(onClickListener:)];
            singleFingerTap.meta = wcMeta;
            [vv addGestureRecognizer:singleFingerTap];
        }
        else if(extension == nil)
        {
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
            id shadow = layer[@"shadow"];
            
            float offsetX = [WildCardConstructor convertSketchToPixel:[shadow[@"offsetX"] intValue]];
            float offsetY = [WildCardConstructor convertSketchToPixel:[shadow[@"offsetY"] intValue]];
            float blurRadius = [WildCardConstructor convertSketchToPixel:[shadow[@"blurRadius"] intValue]];
            vv.layer.masksToBounds = NO;
            vv.layer.shadowOffset = CGSizeMake(offsetX, offsetY);
            vv.layer.shadowRadius = blurRadius;
            vv.layer.shadowOpacity = [WildCardUtil alphaWithHexString:shadow[@"color"]];
            vv.layer.shadowColor = [[WildCardUtil colorWithHexStringWithoutAlpha:shadow[@"color"]] CGColor];
            vv.backgroundColor = [UIColor whiteColor];
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
        
        if([layer objectForKey:@"borderColor"] != nil && [layer objectForKey:@"borderWidth"] != nil)
        {
            UIColor* borderColor = [WildCardUtil colorWithHexString:[layer objectForKey:@"borderColor"]];
            float borderWidth =[[layer objectForKey:@"borderWidth"] floatValue];
            borderWidth = [WildCardConstructor convertSketchToPixel:borderWidth];
            
            vv.layer.borderColor = [borderColor CGColor];
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
            [outRules addObject:ReplaceRuleColor(vv ,[layer objectForKey:@"colorMapping"], @"")];
        }
        
        if ([layer objectForKey:(@"replaceUrl")] != nil)
        {
            [outRules addObject:ReplaceRuleReplaceUrl(vv ,[layer objectForKey:@"replaceUrl"], @"")];
        }
        
        if ([layer objectForKey:(@"imageContent")] != nil && ![_class isEqualToString:@"extension"])
        {
            UIView* iv = [[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
            iv.contentMode = UIViewContentModeScaleToFill;
            //iv.backgroundColor = [UIColor blueColor];
            [outRules addObject:ReplaceRuleImage(iv ,layer, [layer objectForKey:@"imageContent"])];
            [vv addSubview:iv];
            [WildCardConstructor followSizeFromFather:vv child:iv];
        } else if ([layer objectForKey:(@"imageContentResource")] != nil && ![_class isEqualToString:@"extension"])
        {
            UIImageView* iv = [[UIImageView alloc] init];
            iv.contentMode = UIViewContentModeScaleToFill;
            //iv.backgroundColor = [UIColor blueColor];
            [outRules addObject:ReplaceRuleImageResource(iv ,layer, [layer objectForKey:@"imageContentResource"])];
            [vv addSubview:iv];
            [WildCardConstructor followSizeFromFather:vv child:iv];
        } else if ([layer objectForKey:(@"localImageContent")] != nil &&  ![_class isEqualToString:@"extension"])
        {
            if([WildCardConstructor sharedInstance].onLineMode)
            {
                UIView* iv = [[WildCardConstructor sharedInstance].delegate getNetworkImageViewInstnace];
                iv.contentMode = UIViewContentModeScaleToFill;
                [vv addSubview:iv];
                [WildCardConstructor followSizeFromFather:vv child:iv];
                //[outRules addObject:ReplaceRuleLocalImage(iv, layer, [layer objectForKey:@"localImageContent"])];
                [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:iv withUrl:[layer objectForKey:(@"localImageContent")]];
            }
            else
            {
                UIImageView* iv = [[UIImageView alloc] init];
                iv.clipsToBounds = YES;
                iv.contentMode = UIViewContentModeScaleToFill;
                [vv addSubview:iv];
                NSString* imageName = [layer objectForKey:@"localImageContent"];
                NSUInteger index = [imageName rangeOfString:@"/" options:NSBackwardsSearch].location;
                imageName = [imageName substringFromIndex:index+1];
                [iv setImage: [UIImage imageNamed:imageName]];
                [WildCardConstructor followSizeFromFather:vv child:iv];
            }
        } else if ([layer objectForKey:(@"web")] != nil) {
        
            DevilWebView* web = [[DevilWebView alloc] init];
            [vv addSubview:web];
            [WildCardConstructor followSizeFromFather:vv child:web];
            NSString* url = layer[@"web"][@"url"]; 
            [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
            
            UIView* cc = [vv superview];
            vv.userInteractionEnabled = YES;
            while([[cc class] isEqual:[WildCardUIView class]]){
                cc.userInteractionEnabled = YES;
                cc = [cc superview];
            }
        }
        
        if([@"text" isEqualToString:_class])
        {
            WildCardUILabel* tv = [[WildCardUILabel alloc] init];
            [vv addSubview:tv];
            
            tv.frame = CGRectMake(0, 0, vv.frame.size.width, vv.frame.size.height);
            
            //            tv.translatesAutoresizingMaskIntoConstraints = NO;
            //            [WildCardConstructor followSizeFromFather:vv child:tv];
            
            //            vv.backgroundColor = [UIColor purpleColor];
            //            tv.backgroundColor = [UIColor yellowColor];
            
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
            
            
            float textSize = [WildCardConstructor convertTextSize:[[textSpec objectForKey:@"textSize"] floatValue]];
            
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
                tv.numberOfLines = 100;
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
            
            NSString* text = [textSpec objectForKey:@"text"];
            if(text == nil)
                text = name;
            
            tv.textColor = [WildCardUtil colorWithHexString:[textSpec objectForKey:@"textColor"]];
            
            if ([layer objectForKey:@"textContent"]) {
                NSString* textContent = [layer objectForKey:@"textContent"];
                [outRules addObject:ReplaceRuleText(tv, layer, textContent)];
            }
            else
            {
                if([WildCardConstructor sharedInstance].textTransDelegate != nil )
                    text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
                [tv setText:text];
            }
            
            
            //tv.backgroundColor = [UIColor redColor];
            
        }
        
        
        NSArray *layers = [layer objectForKey:@"layers"];
        
        NSString* arrayContentTargetNode = nil;
        NSString* arrayContentTargetNodeSurfix = nil;
        NSString* arrayContentTargetNodePrefix = nil;
        NSString* arrayContentTargetNodeSelected = nil;
        UIView* arrayContentContainer= nil;
        
        if([layer objectForKey:@"arrayContent"])
        {
            NSDictionary* arrayContent = [layer objectForKey:@"arrayContent"];
            arrayContentTargetNode = [arrayContent objectForKey:@"targetNode"];
            arrayContentTargetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
            arrayContentTargetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
            arrayContentTargetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
            
            NSString* repeatType = [arrayContent objectForKey:@"repeatType"];
            float margin = 0;
            if([arrayContent objectForKey:@"margin"] != nil)
                margin = [[arrayContent objectForKey:@"margin"] floatValue];
            margin = [WildCardConstructor convertSketchToPixel:margin];
            
            ReplaceRuleRepeat* replaceRule = ReplaceRuleRepeat(vv, layer, nil);
            [outRules addObject:replaceRule];
            
            NSDictionary* arrayContentTargetLayer = nil;
            for( int i=0;i<[layers count];i++)
            {
                NSString* childName = [[layers objectAtIndex:i] objectForKey:@"name"];
                
                if([childName isEqualToString:arrayContentTargetNode])
                {
                    arrayContentTargetLayer = [layers objectAtIndex:i];
                    break;
                }
            }
            
            if([REPEAT_TYPE_RIGHT isEqualToString:repeatType])
            {
                int minLeft = 1000000;
                for (int i = 0; layers != nil && i < [layers count]; i++) {
                    NSMutableDictionary* childLayer = layers[i];
                    NSString* childName = childLayer[@"name"];
                    if ([childName isEqualToString:arrayContentTargetNode]
                        || [childName isEqualToString:arrayContentTargetNodeSurfix]
                        || [childName isEqualToString:arrayContentTargetNodePrefix]
                        || [childName isEqualToString:arrayContentTargetNodeSelected]
                        )
                    {
                        CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                        if(minLeft > childLayoutParam.origin.x)
                            minLeft = childLayoutParam.origin.x;
                    }
                }
                vv.paddingLeft = minLeft;
                vv.wrap_width = YES;
                replaceRule.createdContainer = vv;
                vv.userInteractionEnabled = YES;
                [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            }
            else if([REPEAT_TYPE_BOTTOM isEqualToString:repeatType])
            {
                int minTop = 1000000;
                for (int i = 0; layers != nil && i < [layers count]; i++) {
                    NSMutableDictionary* childLayer = layers[i];
                    NSString* childName = childLayer[@"name"];
                    if ([childName isEqualToString:arrayContentTargetNode]
                        || [childName isEqualToString:arrayContentTargetNodeSurfix]
                        || [childName isEqualToString:arrayContentTargetNodePrefix]
                        || [childName isEqualToString:arrayContentTargetNodeSelected]
                        )
                    {
                        CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                        if(minTop > childLayoutParam.origin.y)
                            minTop = childLayoutParam.origin.y;
                    }
                }
                vv.paddingTop = minTop;
                vv.wrap_height = YES;
                replaceRule.createdContainer = vv;
                vv.userInteractionEnabled = YES;
                [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            }
            else if([REPEAT_TYPE_GRID isEqualToString:repeatType])
            {
                CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
                containerRect.origin.x = containerRect.origin.y = 0;
                WildCardGridView* container = [[WildCardGridView alloc] initWithFrame:containerRect];
                container.meta = wcMeta;
                container.depth = depth;
                arrayContentContainer = replaceRule.createdContainer = container;
                
                vv.userInteractionEnabled = YES;
                [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            }
            else if([REPEAT_TYPE_VIEWPAGER isEqualToString:repeatType])
            {
                UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
                flowLayout.itemSize = CGSizeMake(100, 100);
                [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                
                CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
                containerRect.origin.x = containerRect.origin.y = 0;
                
                UICollectionView *container = [[UICollectionView alloc] initWithFrame:containerRect collectionViewLayout:flowLayout];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"0"];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"1"];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"2"];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"3"];
                
                //container.pagingEnabled = YES;
                
                [container setShowsHorizontalScrollIndicator:NO];
                [container setShowsVerticalScrollIndicator:NO];
                container.backgroundColor = [UIColor clearColor];
                WildCardCollectionViewAdapter* adapter = [[WildCardCollectionViewAdapter alloc] init];
                adapter.collectionView = container;
                
                NSString* arrayContentTargetNode = [arrayContent objectForKey:@"targetNode"];
                for (int i = 0; layers != nil && i < [layers count]; i++) {
                    NSMutableDictionary* childLayer = layers[i];
                    NSString* childName = childLayer[@"name"];
                    if ([childName isEqualToString:arrayContentTargetNode]){
                        CGRect firstChildRect = [WildCardConstructor getFrame:layers[i]:vv];
                        adapter.viewPagerContentWidth = firstChildRect.size.width;
                        adapter.viewPagerStartPaddingX = firstChildRect.origin.x;
                        break;
                    }
                }
                        
                adapter.repeatType = repeatType;
                adapter.margin = margin;
                container.contentInset = UIEdgeInsetsMake(0, adapter.viewPagerStartPaddingX, 0, adapter.viewPagerStartPaddingX);
                adapter.meta = wcMeta;
                adapter.depth = depth;
                replaceRule.adapterForRetain = adapter;
                container.delegate = adapter;
                container.dataSource = adapter;
                
                if(triggerMap != nil && triggerMap[WILDCARD_VIEW_PAGER_CHANGED] != nil) {
                    
                    WildCardTrigger* trigger = [[WildCardTrigger alloc] initWithType:WILDCARD_VIEW_PAGER_CHANGED nodeName:vv.name node:vv];
                    NSMutableArray* actions = triggerMap[WILDCARD_VIEW_PAGER_CHANGED];
                    for(int i=0;i<[actions count];i++)
                        [trigger addAction:[WildCardAction parse:wcMeta action:actions[i]]];
                    [wcMeta addTriggerAction:trigger];
                }
                
                [adapter addViewPagerSelected:^(int position) {
                    for(int i=0;i<[adapter.data count];i++)
                    {
                        if(i==position)
                            adapter.data[i][WC_SELECTED] = @"Y";
                        else
                            adapter.data[i][WC_SELECTED] = @"N";
                    }
                    
                    [wcMeta doAllActionOfTrigger:WILDCARD_VIEW_PAGER_CHANGED node:vv.name];
                }];
                
                arrayContentContainer = replaceRule.createdContainer = container;
                
                vv.userInteractionEnabled = YES;
                [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            }
            else if([REPEAT_TYPE_HLIST isEqualToString:repeatType] || [REPEAT_TYPE_VLIST isEqualToString:repeatType])
            {
                UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
                flowLayout.itemSize = CGSizeMake(100, 100);
                if([REPEAT_TYPE_HLIST isEqualToString:repeatType])
                    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                else
                    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
                
                CGRect containerRect = [WildCardConstructor getFrame:layer:parent];
                containerRect.origin.x = containerRect.origin.y = 0;
                
                UICollectionView *container = [[UICollectionView alloc] initWithFrame:containerRect collectionViewLayout:flowLayout];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"0"];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"1"];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"2"];
                [container registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"3"];
                
                [container setShowsHorizontalScrollIndicator:NO];
                [container setShowsVerticalScrollIndicator:NO];
                container.backgroundColor = [UIColor clearColor];
                WildCardCollectionViewAdapter* adapter = [[WildCardCollectionViewAdapter alloc] init];
                adapter.repeatType = repeatType;
                adapter.margin = margin;
                adapter.meta = wcMeta;
                adapter.depth = depth;
                replaceRule.adapterForRetain = adapter;
                container.delegate = adapter;
                container.dataSource = adapter;
                
                int minLeft = 1000000;
                for (int i = 0; layers != nil && i < [layers count]; i++) {
                    NSMutableDictionary* childLayer = layers[i];
                    NSString* childName = childLayer[@"name"];
                    if ([childName isEqualToString:arrayContentTargetNode]
                        || [childName isEqualToString:arrayContentTargetNodeSurfix]
                        || [childName isEqualToString:arrayContentTargetNodePrefix]
                        || [childName isEqualToString:arrayContentTargetNodeSelected]
                        )
                    {
                        CGRect childLayoutParam = [WildCardConstructor getFrame:childLayer :nil];
                        if(minLeft > childLayoutParam.origin.x)
                            minLeft = childLayoutParam.origin.x;
                    }
                }
                container.contentInset = UIEdgeInsetsMake(0, minLeft, 0, 0);
                
                arrayContentContainer = replaceRule.createdContainer = container;
                
                vv.userInteractionEnabled = YES;
                [WildCardConstructor userInteractionEnableToParentPath:vv depth:depth];
            }
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
                
                if([childName isEqualToString:arrayContentTargetNode] && arrayContentContainer != nil)
                {
                    [vv addSubview:arrayContentContainer];
                }
                continue;
            }
            //익스텐션중에 하위 노드를 없애야하는 애들이 있다.
            else if(extension != nil && [WildCardExtensionConstructor getExtensionType:extension] != WILDCARD_EXTENSION_TYPE_CHEKBOX
                    && [WildCardExtensionConstructor getExtensionType:extension] != WILDCARD_EXTENSION_TYPE_PROGRESS_BAR)
            {
                continue;
            }
            else if([[childLayer objectForKey:@"ignore"] boolValue])
            {
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
        
        float hNextToMargin = 0;
        
        if([layer objectForKey:@"hNextToMargin"] != nil)
        {
            float a = [[layer objectForKey:@"hNextToMargin"] floatValue];
            a = [WildCardConstructor convertSketchToPixel:a];
            hNextToMargin = [[[NSNumber alloc] initWithFloat:a] floatValue];
        }
        
        //[WildCardConstructor hNextTo:[prevView superview] preview:prevView next:nextView margin:hNextToMargin];
        [wcMeta addNextChain:prevView next:nextView margin:hNextToMargin horizontal:YES depth:depth];
    }
    
    if([layer objectForKey:@"vNextTo"] != nil)
    {
        NSString* prevName = [layer objectForKey:@"vNextTo"];
        NSString* nextName = [layer objectForKey:@"name"];
        WildCardUIView* prevView = [wcMeta.generatedViews objectForKey:prevName];
        WildCardUIView* nextView = [wcMeta.generatedViews objectForKey:nextName];
        float vNextToMargin = 0;
        if([layer objectForKey:@"vNextToMargin"] != nil)
        {
            float a = [[layer objectForKey:@"vNextToMargin"] floatValue];
            a = [WildCardConstructor convertSketchToPixel:a];
            vNextToMargin = [[[NSNumber alloc] initWithFloat:a] floatValue];
        }
        
        //[WildCardConstructor vNextTo:[prevView superview] preview:prevView next:nextView margin:vNextToMargin];
        [wcMeta addNextChain:prevView next:nextView margin:vNextToMargin horizontal:NO depth:depth];
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
        else
        {
            [WildCardConstructor constructLayer2:nil :childLayer:layer:wcMeta:depth+1:i];
        }
    }
}


+(CGRect)getFrame:(NSDictionary*) layer : (WildCardUIView*)parentForPadding
{
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
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
    if(SKETCH_WIDTH >= 710)
    {
        textSize =  sketchTextSize / 2.1f;
    }
    else
    {
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
    }
    return textSize;
}
+(float) convertSketchToPixel:(float)p
{
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    float scaleAdjust = screenWidth / SKETCH_WIDTH;
    return p * scaleAdjust;
}

+(float) mesureHeight:(NSMutableDictionary*)cloudJson data:(NSMutableDictionary*)data
{
    //    float w = [layer[@"frame"][@"w"] floatValue];
    //    if(w > 360)
    //        SKETCH_WIDTH = w;
    //    else
    //        SKETCH_WIDTH = 360;
    
    if(IS_TABLET)
        SKETCH_WIDTH = 720;
    
    float h = [cloudJson[@"frame"][@"h"] floatValue];
    if(h == -2)
    {
        h = 0;
        //TODO 가변 텍스트에 의한 가변 높이는 성능상 이슈로 아직 구현 못함
        //그리드 뷰 혹은 하향반복 일 경우
        if(cloudJson[@"arrayContent"] != nil && ([cloudJson[@"arrayContent"][@"repeatType"] isEqualToString:REPEAT_TYPE_GRID] || [cloudJson[@"arrayContent"][@"repeatType"] isEqualToString:REPEAT_TYPE_BOTTOM]))
        {
            NSMutableDictionary* arrayContent = cloudJson[@"arrayContent"];
            NSString* repeatType = arrayContent[@"repeatType"];
            NSString* targetNode = [arrayContent objectForKey:@"targetNode"];
            NSArray* childLayers = [cloudJson objectForKey:@"layers"];
            NSDictionary* targetLayer = nil;
            NSDictionary* targetLayerSurfix = nil;
            NSDictionary* targetLayerPrefix = nil;
            NSDictionary* targetLayerSelected = nil;
            NSString* targetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
            NSString* targetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
            NSString* targetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
            NSString* targetNodeSelectedIf = [arrayContent objectForKey:@"targetNodeSelectedIf"];
            NSString* targetJsonString = [arrayContent objectForKey:@"targetJson"];
            NSArray* targetDataJson = (NSArray*) [MappingSyntaxInterpreter
                                                  getJsonWithPath:data : targetJsonString];
            long targetDataJsonLen = [targetDataJson count];
            
            for(int i=0;i<[childLayers count];i++)
            {
                NSDictionary* childLayer = [childLayers objectAtIndex:i];
                if([targetNode isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayer = childLayer;
                }
                else if(targetNodePrefix == nil && [targetNodePrefix isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayerPrefix = childLayer;
                }
                else if(targetNodeSurfix != nil && [targetNodeSurfix isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayerSurfix = childLayer;
                }
                else if(targetNodeSelected != nil && [targetNodeSelected isEqualToString:[childLayer objectForKey:@"name"]])
                {
                    targetLayerSelected = childLayer;
                }
            }
            
            if([repeatType isEqualToString:REPEAT_TYPE_GRID])
            {
                float w = [[[targetLayer objectForKey:@"frame"] objectForKey:@"w"] floatValue];
                float containerWidth = [[[cloudJson objectForKey:@"frame"] objectForKey:@"w"] floatValue];
                int col = (int)(containerWidth / w);
                if( (containerWidth / w) - col > 0.7f)
                    col ++;
                long row = targetDataJsonLen / col + (targetDataJsonLen % col > 0 ? 1 : 0);
                h = row * [WildCardConstructor mesureHeight:targetLayer data:data];
            } else if([repeatType isEqualToString:REPEAT_TYPE_BOTTOM])
            {
                //TODO margin 계산해야함 첫 셀의 start도 계산해야함
                float thisH = [[[targetLayer objectForKey:@"frame"] objectForKey:@"h"] floatValue];
                thisH = [WildCardConstructor convertSketchToPixel:thisH];
                float margin = [WildCardConstructor convertSketchToPixel:[arrayContent[@"margin"] floatValue]];
                h = targetDataJsonLen * thisH + margin*(targetDataJsonLen-1);
            }
            
        }
        else
        {
            NSMutableArray* arr = cloudJson[@"layers"];
            NSMutableDictionary* nextLayers = [@{} mutableCopy];
            NSMutableDictionary* rootLayers = [@{} mutableCopy];
            NSMutableDictionary* layersByName = [@{} mutableCopy];
            NSMutableDictionary* rects = [@{} mutableCopy];
            for(int i=0;i<[arr count];i++)
            {
                BOOL hidden = false;
                NSMutableDictionary* item = arr[i];
                NSString* name = arr[i][@"name"];
                float thisy = [arr[i][@"frame"][@"y"] floatValue];
                thisy = [WildCardConstructor convertSketchToPixel:thisy];
                
                float thish = 0;
                if(cloudJson[@"arrayContent"] != nil) {
                    NSMutableDictionary* arrayContent = cloudJson[@"arrayContent"];
                    NSDictionary* targetLayer = nil;
                    NSDictionary* targetLayerSurfix = nil;
                    NSDictionary* targetLayerPrefix = nil;
                    NSDictionary* targetLayerSelected = nil;
                    NSString* targetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
                    NSString* targetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
                    NSString* targetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
                    NSString* targetNodeSelectedIf = [arrayContent objectForKey:@"targetNodeSelectedIf"];
                    NSString* targetJsonString = [arrayContent objectForKey:@"targetJson"];
                    NSArray* targetDataJson = (NSArray*) [MappingSyntaxInterpreter getJsonWithPath:data : targetJsonString];
                    thish = [WildCardConstructor mesureHeight:item data:targetDataJson[0]];
                } else
                    thish = [WildCardConstructor mesureHeight:item data:data];

                layersByName[name] = arr[i];
                if(item[@"hiddenCondition"] != nil)
                    hidden = [MappingSyntaxInterpreter ifexpression:item[@"hiddenCondition"] data:data];
                if(hidden)
                    rects[name] = [NSValue valueWithCGRect:CGRectMake(0, thisy, 0, 0)];
                else
                    rects[name] = [NSValue valueWithCGRect:CGRectMake(0, thisy, 0, thish)];
                
                NSString* nextTo = arr[i][@"vNextTo"];
                if( nextTo != nil)
                    [nextLayers setObject:name forKey:nextTo];
                else
                    [rootLayers setObject:name forKey:name];
            }
            
            for(int i=0;i<[arr count];i++)
            {
                NSString* name = arr[i][@"name"];
                float thisy = [rects[name] CGRectValue].origin.y;
                float thish = [rects[name] CGRectValue].size.height;
                if(rootLayers[name]){
                    if(thisy + thish > h)
                        h = thisy + thish;
                    
                    while(nextLayers[name]){
                        NSString* nextName = nextLayers[name];
                        float margin = [layersByName[nextName][@"vNextToMargin"] floatValue];
                        float nexty = thisy + thish + [WildCardConstructor convertSketchToPixel:margin];
                        float nexth = [rects[nextName] CGRectValue].size.height;
                        if(nexty + nexth > h)
                            h = nexty + nexth;
                        thisy = nexty;
                        thish = nexth;
                        name = nextName;
                    }
                }
            }
        }
    }
    else
    {
        h = [WildCardConstructor convertSketchToPixel:h];
        BOOL tableH = IS_TABLET ? [@"Y" isEqualToString:cloudJson[@"tabletH"]] : false;
        if(tableH)
            h *= 2;
    }
    
    float padding = [self getPaddingTopBottomConverted:cloudJson];
    return h + padding;
}

+ (float)getPaddingTopBottomConverted:(id)layer{
    float paddingTop = 0 , paddingBottom = 0;
    if([layer objectForKey:@"padding"] != nil) {
        NSDictionary* padding = [layer objectForKey:@"padding"];
        if([padding objectForKey:@"paddingTop"] != nil) {
            paddingTop = [[padding objectForKey:@"paddingTop"] floatValue];
            paddingTop = [WildCardConstructor convertSketchToPixel:paddingTop];
        }
        
        if([padding objectForKey:@"paddingBottom"] != nil) {
            paddingBottom = [[padding objectForKey:@"paddingBottom"] floatValue];
            paddingBottom = [WildCardConstructor convertSketchToPixel:paddingBottom];
        }
    }
    return paddingTop + paddingBottom;
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
    if(rule.replaceType == RULE_TYPE_REPEAT)
    {
        ReplaceRuleRepeat* repeatRule = (ReplaceRuleRepeat*)rule;
        NSDictionary* layer = repeatRule.replaceJsonLayer;
        NSDictionary* arrayContent = [layer objectForKey:@"arrayContent"];
        NSString* targetNode = [arrayContent objectForKey:@"targetNode"];
        NSString* targetNodeSurfix = [arrayContent objectForKey:@"targetNodeSurfix"];
        NSString* targetNodePrefix = [arrayContent objectForKey:@"targetNodePrefix"];
        NSString* targetNodeSelected = [arrayContent objectForKey:@"targetNodeSelected"];
        NSString* targetNodeSelectedIf = [arrayContent objectForKey:@"targetNodeSelectedIf"];
        
        NSString* targetJsonString = [arrayContent objectForKey:@"targetJson"];
        NSString* repeatType = [arrayContent objectForKey:@"repeatType"];
        float margin = [[arrayContent objectForKey:@"margin"] floatValue];
        margin = [WildCardConstructor convertSketchToPixel:margin];
        BOOL innerLine = [@"Y" isEqualToString:[arrayContent objectForKey:@"innerLine"]];
        
        NSArray* targetDataJson = (NSArray*) [MappingSyntaxInterpreter
                                              getJsonWithPath:opt : targetJsonString];
        
        NSArray* childLayers = [layer objectForKey:@"layers"];
        NSDictionary* targetLayer = nil;
        NSDictionary* targetLayerSurfix = nil;
        NSDictionary* targetLayerPrefix = nil;
        NSDictionary* targetLayerSelected = nil;
        
        for(int i=0;i<[targetDataJson count];i++)
        {
            if(i == 0)
            {
                if(![[targetDataJson[i] class] isSubclassOfClass:[NSDictionary class]]
                   || targetDataJson[i][WC_INDEX] != nil)
                    break;
            }
            targetDataJson[i][WC_INDEX] = [NSString stringWithFormat:@"%d", i];
            targetDataJson[i][WC_LENGTH] = [NSString stringWithFormat:@"%lu", [targetDataJson count]];
        }
        
        for(int i=0;i<[childLayers count];i++)
        {
            NSDictionary* childLayer = [childLayers objectAtIndex:i];
            if([targetNode isEqualToString:[childLayer objectForKey:@"name"]])
            {
                targetLayer = childLayer;
            }
            else if(targetNodePrefix == nil && [targetNodePrefix isEqualToString:[childLayer objectForKey:@"name"]])
            {
                targetLayerPrefix = childLayer;
            }
            else if(targetNodeSurfix != nil && [targetNodeSurfix isEqualToString:[childLayer objectForKey:@"name"]])
            {
                targetLayerSurfix = childLayer;
            }
            else if(targetNodeSelected != nil && [targetNodeSelected isEqualToString:[childLayer objectForKey:@"name"]])
            {
                targetLayerSelected = childLayer;
            }
        }
        
        if([REPEAT_TYPE_BOTTOM isEqualToString:repeatType] || [REPEAT_TYPE_RIGHT isEqualToString:repeatType])
        {
            int i;
            for(i=0;i<[targetDataJson count];i++)
            {
                WildCardUIView* thisNode = nil;
                NSDictionary* thisLayer = targetLayer;
                int thisType = CREATED_VIEW_TYPE_NORMAL;
                NSMutableDictionary* thisData = [targetDataJson objectAtIndex:i];
                if(targetLayerSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data:thisData]){
                    thisLayer = targetLayerSelected;
                    thisType = CREATED_VIEW_TYPE_SELECTED;
                }
                
                if (i < [repeatRule.createdRepeatView count] && thisType == ((CreatedViewInfo*)repeatRule.createdRepeatView[i]).type)
                    thisNode = (WildCardUIView*)((CreatedViewInfo*)repeatRule.createdRepeatView[i]).view;
                else
                {
                    int containerDepth = ((WildCardUIView*)repeatRule.createdContainer).depth;
                    thisNode = [WildCardConstructor constructLayer:nil withLayer : thisLayer withParentMeta:meta  depth:containerDepth+1 instanceDelegate:meta.wildCardConstructorInstanceDelegate];
                    
                    if (i < [repeatRule.createdRepeatView count] ){
                        [[repeatRule.createdContainer subviews][i] removeFromSuperview];
                        [repeatRule.createdRepeatView removeObjectAtIndex:i];
                    }
                    [repeatRule.createdContainer insertSubview:thisNode atIndex:i];
                    CreatedViewInfo* createdViewInfo = [[CreatedViewInfo alloc] initWithView:thisNode type:thisType];
                    [repeatRule.createdRepeatView insertObject:createdViewInfo atIndex:i];
                    
                    BOOL horizontal = [REPEAT_TYPE_RIGHT isEqualToString:repeatType];
                    if(i > 0) {
                        WildCardUIView* prevView = (WildCardUIView*)((CreatedViewInfo*)[repeatRule.createdRepeatView objectAtIndex:i-1]).view;
                        [meta addNextChain:prevView next:thisNode margin:margin horizontal:horizontal depth:containerDepth];
                    } else {
                        if(horizontal)
                            thisNode.frame = CGRectMake([(WildCardUIView*)[thisNode superview] paddingLeft] , thisNode.frame.origin.y, thisNode.frame.size.width, thisNode.frame.size.height);
                        else
                            thisNode.frame = CGRectMake(thisNode.frame.origin.x, [(WildCardUIView*)[thisNode superview] paddingTop] , thisNode.frame.size.width, thisNode.frame.size.height);
                    }
                }
                
                thisNode.hidden = NO;
                [WildCardConstructor userInteractionEnableToParentPath:repeatRule.createdContainer depth:10];
                thisNode.userInteractionEnabled = YES;
                [WildCardConstructor applyRule:thisNode withData:[targetDataJson objectAtIndex:i]];
            }
            
            for (; i < [repeatRule.createdRepeatView count]; i++) {
                ((CreatedViewInfo*)repeatRule.createdRepeatView[i]).view.hidden = YES;
            }
        }
        else if([REPEAT_TYPE_GRID isEqualToString:repeatType])
        {
            WildCardGridView* gv = (WildCardGridView *)repeatRule.createdContainer;
            
            float w = [[[targetLayer objectForKey:@"frame"] objectForKey:@"w"] floatValue];
            float containerWidth = [[[layer objectForKey:@"frame"] objectForKey:@"w"] floatValue];
            int col = (int)(containerWidth / w);
            if( (containerWidth / w) - col > 0.7f)
                col ++;
            gv.col = col;
            gv.data = targetDataJson;
            [gv setInnerLine:innerLine];
            
            gv.cloudJsonGetter = ^NSDictionary *(int position) {
                if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                    return targetLayerSelected;
                else if(targetLayerPrefix != nil && position == 0)
                    return targetLayerPrefix;
                else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                    return targetLayerSurfix;
                
                return targetLayer;
            };
            
            gv.typeGetter = ^NSString *(int position) {
                if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                    return @"3";
                else if(targetLayerPrefix != nil && position == 0)
                    return @"0";
                else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                    return @"1";
                return @"2";
            };
            
            //gv.lineColor = [UIColor redColor];
            //gv.lineWidth = 1;
            //gv.outerWidth = 1;
            
            [gv reloadData];
        }
        else if([REPEAT_TYPE_VIEWPAGER isEqualToString:repeatType])
        {
            UICollectionView *cv = (UICollectionView *)repeatRule.createdContainer;
            WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)repeatRule.adapterForRetain;
            
            adapter.data = targetDataJson;
            
            BOOL atLeastOneSelected = false;
            for(int i=0;i<[targetDataJson count];i++)
            {
                if([@"Y" isEqualToString:targetDataJson[i][WC_SELECTED]])
                {
                    atLeastOneSelected = true;
                    break;
                }
            }
            if(!atLeastOneSelected)
                targetDataJson[0][WC_SELECTED] = @"Y";
            
            adapter.cloudJsonGetter = ^NSDictionary *(int position) {
                if(targetLayerPrefix != nil && position == 0)
                    return targetLayerPrefix;
                else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                    return targetLayerSurfix;
                return targetLayer;
            };
            
            adapter.typeGetter = ^NSString *(int position) {
                if(targetLayerPrefix != nil && position == 0)
                    return @"0";
                else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                    return @"1";
                return @"2";
            };
            
            [cv reloadData];
        }
        else if([REPEAT_TYPE_HLIST isEqualToString:repeatType] || [REPEAT_TYPE_VLIST isEqualToString:repeatType])
        {
            UICollectionView *cv = (UICollectionView *)repeatRule.createdContainer;
            WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)repeatRule.adapterForRetain;
            
            adapter.data = targetDataJson;
            adapter.cloudJsonGetter = ^NSDictionary *(int position) {
                if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                    return targetLayerSelected;
                else if(targetLayerPrefix != nil && position == 0)
                    return targetLayerPrefix;
                else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                    return targetLayerSurfix;
                return targetLayer;
            };
            
            adapter.typeGetter = ^NSString *(int position) {
                if(targetNodeSelected != nil && [MappingSyntaxInterpreter ifexpression:targetNodeSelectedIf data: targetDataJson[position]])
                    return @"3";
                else if(targetLayerPrefix != nil && position == 0)
                    return @"0";
                else if(targetLayerSurfix != nil && position == [targetDataJson count]-1)
                    return @"1";
                return @"2";
            };
            
            [cv reloadData];
        }
        
    } else if(rule.replaceType == RULE_TYPE_NETWORK_IMAGE) {
        NSString* url = nil;
        if([[opt class] isSubclassOfClass:[NSString class]])
            url = (NSString*)opt;
        else
            url = [MappingSyntaxInterpreter interpret:rule.replaceJsonKey:opt];
        
        [[WildCardConstructor sharedInstance].delegate loadNetworkImageView:rule.replaceView withUrl:url];
    } else if(rule.replaceType == RULE_TYPE_IMAGE_RESOURCE) {
        NSString* imageName = nil;
        if([[opt class] isSubclassOfClass:[NSString class]])
            imageName = (NSString*)opt;
        else
            imageName = [MappingSyntaxInterpreter interpret:rule.replaceJsonKey:opt];
        [((UIImageView*)rule.replaceView) setImage:[UIImage imageNamed:imageName]];
    } else if(rule.replaceType == RULE_TYPE_CLICK) {
        ((WildCardUIView*)rule.replaceView).stringTag = rule.replaceJsonKey;
    }
    else if(rule.replaceType == RULE_TYPE_TEXT)
    {
        UILabel* lv = (UILabel*)rule.replaceView;
        NSString* text = [MappingSyntaxInterpreter interpret:rule.replaceJsonKey:opt];
        if(text == nil)
            text = rule.replaceJsonLayer[@"textSpec"][@"text"];

        if([WildCardConstructor sharedInstance].textTransDelegate != nil )
            text = [[WildCardConstructor sharedInstance].textTransDelegate translateLanguage:text];
        
        [lv setText:text];
        //NSLog(@"%@ -> %@", rule.replaceJsonKey , text!=nil? text:@"nil");
    }
    else if(rule.replaceType == RULE_TYPE_COLOR)
    {
        NSMutableDictionary* colorMapping = rule.replaceJsonLayer;
        if(colorMapping[@"b"] != nil) {
            NSString* jsonpath = colorMapping[@"b"];
            NSString* colorCode = [MappingSyntaxInterpreter interpret:jsonpath :opt];
            UIColor *c = [WildCardUtil colorWithHexString:colorCode];
            rule.replaceView.backgroundColor = c;
            WildCardUIView* v = (WildCardUIView*)rule.replaceView;
            if(v.layer.borderWidth > 0 && colorMapping[@"f"] == nil)
                v.layer.borderColor = [c CGColor];
        }
        if(colorMapping[@"f"] != nil) {
            NSString* jsonpath = colorMapping[@"f"];
            NSString* colorCode = [MappingSyntaxInterpreter interpret:jsonpath :opt];
            if(colorCode != nil){
                UIColor *c = [WildCardUtil colorWithHexString:colorCode];
                if([rule.replaceView class] == [WildCardUIView class])
                {
                    WildCardUIView* v = (WildCardUIView*)rule.replaceView;
                    if([[v subviews] count] == 1 && [[v subviews][0] class] == [WildCardUILabel class])
                    {
                        WildCardUILabel* tv = (WildCardUILabel*)[v subviews][0];
                        [tv setTextColor:c];
                    } else if([[v subviews] count] == 1 && [[v subviews][0] class] == [UIImageView class]) {
                        UIImageView* iv = (UIImageView*)[v subviews][0];
                        iv.image = [iv.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        iv.tintColor = c;
                    } else if(v.layer.borderWidth > 0)
                    {
                        v.layer.borderColor = [c CGColor];
                    }
                    else
                        [rule.replaceView setBackgroundColor:c];
                }
                else
                    [rule.replaceView setBackgroundColor:c];
            }
        }
    }
    else if(rule.replaceType == RULE_TYPE_HIDDEN)
    {
        if([MappingSyntaxInterpreter ifexpression:rule.replaceJsonKey data:opt defaultValue:YES])
        {
            rule.replaceView.hidden = YES;
            //WildCardConstructor.parentVisible(replaceRule.replaceView, false);
        }
        else {
            rule.replaceView.hidden = NO;
            //WildCardConstructor.parentVisible(replaceRule.replaceView, true);
        }
    }
    else if(rule.replaceType == RULE_TYPE_EXTENSION)
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

@end
