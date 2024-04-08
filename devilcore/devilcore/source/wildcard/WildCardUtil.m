//
//  WildCardUtil.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardUtil.h"
#import "WildCardUIView.h"
#import "MappingSyntaxInterpreter.h"
#import "WildCardConstructor.h"
#import "ReplaceRuleRepeat.h"
#import "Jevil.h"

static float SKETCH_WIDTH = 360;
static float SCREEN_WIDTH = 0;
static float SCREEN_HEIGHT = 0;

static BOOL IS_TABLET = NO;

@implementation WildCardUtil

+(void)setSketchWidth:(float)w {
    SKETCH_WIDTH = w;
}

+(void)setScreenWidthHeight:(float)w :(float)h {
    SCREEN_WIDTH = w;
    SCREEN_HEIGHT = h;
}

+ (float)headerHeightInPixcelIfHeader:(UIViewController*)vc {
    if(vc.navigationController.isNavigationBarHidden)
        return 0;
    else
        return [self headerHeightInPixcel];
}

+ (float)headerHeightInPixcel {
    float r = 0;
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        topPadding = window.safeAreaInsets.top;
    }
    r+=topPadding;
    return r+44;
}

+ (float)headerHeightInSketch {
    float r = 0;
    CGFloat topPadding = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        topPadding = window.safeAreaInsets.top;
    }
    r+=topPadding;
    
    return [WildCardUtil convertPixcelToSketch:r+44];
    //return 80.0f / 360.0f * SKETCH_WIDTH;
}

+(float) alphaWithHexString: (NSString *) hexString{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return alpha;
}

+ (UIColor *) colorWithHexString: (NSString *) hexString {
    if(hexString == [NSNull null])
        return nil;
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
//            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}


+ (UIColor *) colorWithHexStringWithoutAlpha: (NSString *) hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: 1.0f];
}

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}




+(BOOL)hasGravityBottom:(int)gravity
{
    switch(gravity)
    {
        case GRAVITY_BOTTOM:
        case GRAVITY_LEFT_BOTTOM:
        case GRAVITY_HCENTER_BOTTOM:
        case GRAVITY_RIGHT_BOTTOM:
            return true;
    }
    return false;
}
+(BOOL)hasGravityCenterVertical:(int)gravity
{
    switch(gravity)
    {
        case GRAVITY_VERTICAL_CENTER:
        case GRAVITY_LEFT_VCENTER:
        case GRAVITY_RIGHT_VCENTER:
        case GRAVITY_CENTER:
            return true;
    }
    return false;
}
+(BOOL)hasGravityRight:(int)gravity
{
    switch(gravity)
    {
        case GRAVITY_RIGHT:
        case GRAVITY_RIGHT_BOTTOM:
        case GRAVITY_RIGHT_TOP:
        case GRAVITY_RIGHT_VCENTER:
            return true;
    }
    return false;
}
+(BOOL)hasGravityCenterHorizontal:(int)gravity
{
    switch(gravity)
    {
        case GRAVITY_HORIZONTAL_CENTER:
        case GRAVITY_HCENTER_TOP:
        case GRAVITY_HCENTER_BOTTOM:
        case GRAVITY_CENTER:
            return true;
    }
    return false;
}


+(void)fitToScreen:(id)layer{
    [WildCardUtil fitToScreen:layer sketch_height_more:0];
}


+(void)fitToScreen:(id)layer sketch_height_more:(int)sketch_height_more {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float screenWidth = SCREEN_WIDTH;
    float screenHeight = SCREEN_HEIGHT;

    float sketch_height_of_screen = screenHeight * SKETCH_WIDTH / screenWidth;
    [WildCardUtil fitToScreenRecur:layer offsety:0 height:sketch_height_of_screen - sketch_height_more];
}

+(void)fitToScreenRecur:(id)layer offsety:(float)offsety height:(float)height{
    id frame = layer[@"frame"];
    
    int alignment = [frame[@"alignment"] intValue];
    switch (alignment) {
        case GRAVITY_LEFT_BOTTOM:
        case GRAVITY_BOTTOM:
        case GRAVITY_RIGHT_BOTTOM:
        case GRAVITY_HCENTER_BOTTOM:
            return;
    }
    
    if(layer[@"market"] && [@"kr.co.july.blockdrawer" isEqualToString:layer[@"market"][@"type"]])
        return;
    
    float y = [frame[@"y"] floatValue];
    float h = [frame[@"h"] floatValue];

    if(offsety + y + h > height) {
        h -= (offsety + y + h) - height;
        frame[@"h"] = [NSNumber numberWithFloat:h];
    }

    id layers = layer[@"layers"];
    if(layers != nil && layer[@"arrayContent"] == nil){
        for(int i=0;i<[layers count];i++){
            [WildCardUtil fitToScreenRecur:layers[i] offsety:(offsety + y) height:height];
        }
    }
}

+(CGRect)getGlobalFrame:(UIView*)v {
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    return [v.superview convertRect:v.frame toView:rootView];
}

+(float) convertPixcelToSketch:(float)p {
    int screenWidth = SCREEN_WIDTH;
    float scaleAdjust = SKETCH_WIDTH / screenWidth;
    return p * scaleAdjust;
}

+(float) convertSketchToPixel:(float)p {
    int screenWidth = SCREEN_WIDTH;
    float scaleAdjust = screenWidth / SKETCH_WIDTH;
    return p * scaleAdjust;
}



+(float) cachedImagePixcelHeight:(NSString*)url height:(float)height{
    static id heightMapByUrl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        heightMapByUrl = [@{} mutableCopy];
    });
    
    if(height > 0) {
        heightMapByUrl[url] = [NSNumber numberWithFloat:height];
    }
    if(heightMapByUrl[url])
        return [heightMapByUrl[url] floatValue];
    else
        return 0;
}

+(float) measureHeight:(NSMutableDictionary*)cloudJson data:(NSMutableDictionary*)data
{
    float h = [cloudJson[@"frame"][@"h"] floatValue];
    /**
     TODO : match_h 구현해야함(관련성부터 파악)
     */
    if(h != -2) {
        
        /**
         2023/7/16
         bottomMargin 감안해서 높이 계산
         */
        float margin = [WildCardUtil getMarginTopBottomConverted:cloudJson];
        return [WildCardConstructor convertSketchToPixel:h] + margin;
    }
    
    h = 0;
    /**
     이미지인경우 scapeType wrap_heigth를 감안해야한다 이미지를 불러오고 그에 따라 높이를 변경하는 구조이며,
     이미지가 불러오면 데이터에 해당 이미지의 w와 h를 넣어준다
     
     */
    
    if([@"wrap_height" isEqualToString:cloudJson[@"scaleType"]]){
        NSString* imageContent = cloudJson[@"imageContent"];
        NSString* url = [MappingSyntaxInterpreter interpret:imageContent :data];
        float cachedH = [WildCardUtil cachedImagePixcelHeight:url height:0];
        if(cachedH > 0) {
            h = cachedH;
        } else
            h = [WildCardUtil convertSketchToPixel:[cloudJson[@"frame"][@"oh"] floatValue]];
        
    } else if([@"text" isEqualToString:cloudJson[@"_class"]]){
        NSString* textContent = cloudJson[@"textContent"];
        NSString* text = [MappingSyntaxInterpreter interpret:textContent :data];
        NSDictionary* textSpec = [cloudJson objectForKey:@"textSpec"];
        float textSize = [WildCardConstructor convertTextSize:[[textSpec objectForKey:@"textSize"] floatValue]];
        if(cloudJson[@"dynamicTextSize"]) {
            NSString* s = [Jevil get:cloudJson[@"dynamicTextSize"]];
            if(s) {
                textSize = [s intValue];
                textSize = [WildCardConstructor convertTextSize:textSize];
            }
        }
        UIFont* font = nil;
        if([[textSpec objectForKey:@"bold"] boolValue])
            font = [UIFont boldSystemFontOfSize:textSize];
        else
            font = [UIFont systemFontOfSize:textSize];
        float w = [cloudJson[@"frame"][@"w"] intValue];
        float paddingLeft = 0;
        float paddingRight = 0;
        if(cloudJson[@"padding"]) {
            if(cloudJson[@"padding"][@"paddingLeft"])
                paddingLeft = [WildCardUtil convertSketchToPixel:[cloudJson[@"padding"][@"paddingLeft"] intValue]];
            if(cloudJson[@"padding"][@"paddingRight"])
                paddingRight = [WildCardUtil convertSketchToPixel:[cloudJson[@"padding"][@"paddingRight"] intValue]];
        }
        
        BOOL wrap_width = (w == -2);
        if(wrap_width)
            w = [WildCardUtil convertSketchToPixel:[cloudJson[@"frame"][@"max_width"] intValue]] - paddingLeft - paddingRight;
        else
            w = [WildCardUtil convertSketchToPixel:w];
        /**
         wrap_content 텍스트의 경우 높이가 text가 nil이면 0이 나오고, @"" 이면 한 줄만큼나온다.
         실제 meta에서 그릴때는 한줄로 취급된다
         */
        if(text == nil)
            text = @"";
        CGRect rect = [self getTextSize:text font:font maxWidth:w maxHeight:CGFLOAT_MAX];
        h = rect.size.height;
        
        //NSLog(@"text height - %@ %@ %f", cloudJson[@"name"], text, h);
    } else if(cloudJson[@"arrayContent"] != nil && ([cloudJson[@"arrayContent"][@"repeatType"] isEqualToString:REPEAT_TYPE_GRID] || [cloudJson[@"arrayContent"][@"repeatType"] isEqualToString:REPEAT_TYPE_BOTTOM]))
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
            h = row * [WildCardUtil measureHeight:targetLayer data:data];
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
        NSMutableDictionary* hiddenByChildName = [@{} mutableCopy];
        NSMutableDictionary* layersByName = [@{} mutableCopy];
        NSMutableDictionary* rects = [@{} mutableCopy];
        /**
         일단 자식들의 정보를 구축한다.
         일단 자식들 각자의 고유 높이를 구해 rects에 넣어놓고
         또한 루트레이어를 구해 rootlayer에 넣고
         nextLayer도 구한다
         */
        for(int i=0;i<[arr count];i++)
        {
            BOOL hidden = false;
            NSMutableDictionary* child = arr[i];
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
                thish = [WildCardUtil measureHeight:child data:targetDataJson[0]];
            } else {
                thish = [WildCardUtil measureHeight:child data:data];
                //NSLog(@"child height - %@ %d", child[@"name"], thish);
            }

            layersByName[name] = arr[i];
            if(child[@"hiddenCondition"] != nil)
                hidden = [MappingSyntaxInterpreter ifexpression:child[@"hiddenCondition"] data:data defaultValue:YES];
            else if(child[@"showCondition"] != nil)
                hidden = ![MappingSyntaxInterpreter ifexpression:child[@"showCondition"] data:data defaultValue:NO];
            
            if(hidden) {
                hiddenByChildName[name] = name;
                rects[name] = [NSValue valueWithCGRect:CGRectMake(0, thisy, 0, 0)];
            } else {
                rects[name] = [NSValue valueWithCGRect:CGRectMake(0, thisy, 0, thish)];
            }
            
            //NSLog(@"rect %@ %@", name, rects[name]);
            
            NSString* nextTo = arr[i][@"vNextTo"];
            if( nextTo != nil)
                [nextLayers setObject:name forKey:nextTo];
            else
                [rootLayers setObject:name forKey:name];
        }
        
        /**
         각 루트레이어 nextChain을 따라가면서 각 루트레이어의 최종 높이를 구한다
         */
        for(int i=0;i<[arr count];i++)
        {
            NSString* name = arr[i][@"name"];
            
            /**
             루트레이어는 다른 레이어에의 크기나 내용에 영향 받지 않는 절대 위치를 가진 레이어들이다.
             이 레이어가 히든이라도 넥스트 레이어들이 이어나가야하기 때문에  hiddenLayer는 높이 0으로 취급한다
             */
            if(!rootLayers[name])
                continue;
            
            float thisy = [rects[name] CGRectValue].origin.y;
            float thish = [rects[name] CGRectValue].size.height;
            
            //NSLog(@"%@ y-%f h-%f", name, thisy, thish);
            
            /**
             A1 hidden처리된된 자식중에 thisy 때문에 부모의 높이를 늘려버리는 경우가 있다.
             이 thisy는 히든처리된 자식 뒤에 바로 붙기위해서 필요하긴 하다.
             next 체인에서 특정 노드 이상은 hidden 처리되어 y좌표도 반영되면 안된다.
             혹은 hidden 처리되었더라도 그 노드의 next체인이 hidden이 아니라면, 이 노드의 y좌표는 높이에 반영되어야한다.
             따라서 어떤 노드부터 y좌표에 반영되어야하는지 먼저 확보해야한다
             TODO : MeasureWidth도 같은 방식으로 처리해야함
             */ 
            NSString* cursorNodeName = name;
            id nextChainList = [@[name] mutableCopy];
            while(nextLayers[cursorNodeName]){
                NSString* nextName = nextLayers[name];
                [nextChainList addObject:nextName];
                cursorNodeName = nextLayers[cursorNodeName];
            }
            
            
            /**
             h를 확대해간다
             */
            BOOL thisHidden = hiddenByChildName[name] != nil;
            if(thisy + thish > h){
//                NSLog(@"%@ expended by %@ y:%d h:%d hidden:%d", cloudJson[@"name"], name, (int)thisy , (int)thish, thisHidden);
                h = thisy + thish;
            }
            
            while(nextLayers[name]){
                NSString* nextName = nextLayers[name];
                
                id thisLayer = layersByName[name];
                id nextLayer = layersByName[nextName];
                
                BOOL nextHidden = hiddenByChildName[nextName] != nil;
                /**
                 
                 */
                
                /**
                 2021/09/23
                 prev(this)와 next사이에 margin만 고려한다
                 prev의 paddingBtttom과 next의 paddingTop은 모든 컨텐츠의 높이가 정해지면, 마지막으로 결정된다 동시에 recursion하게 결정된다
                 margin도 padding과 마찬가지로 마지막에 recursion하게 결정된다
                 
                 2021/10/22 next가 hidden이더라도 relative margin은 적용되어야한다. next 체인 A B C에서 B가 hidden이더라도 margin은 hidden여부와 관계 없이 계속 적용되어야한다
                 if(!nextHidden)을 주석처리함
                 관련 케이스 https://console.deavil.com/#/block/37844916
                 
                 노드 명     variable height   margin    y,-height
                 top_desc           vh                            311-50
                 second_desc                       10         372-180
                 desc                   vh               5          558-19
                 detail_img                            20         hidden 여기서 이게 히든처리되서 20만큼 높이가 덜 나온다 -> 2021/10/23, 20만큼 덜 나오는게 맞고, WildCardMeta의 requestLayout를 수정해야한다
                 Bottom                                 20        623-40
                 
                 2021/10/23
                 https://console.deavil.com/#/block/3356033983
                 next가 hidden이더라도 relative margin은 적용되어야하는데 이경우는 적용되면 안된다?
                 if(!nextHidden)의 주석을 다시 품
                 */
                float vNextToMargin = 0;
                if(!nextHidden)
                {
                    vNextToMargin = [layersByName[nextName][@"vNextToMargin"] floatValue];
                }
                
                float nexty = thisy + thish + [WildCardConstructor convertSketchToPixel:(vNextToMargin)];
                float nexth = [rects[nextName] CGRectValue].size.height;
                //A1 경우를 검사해서 h에 영향을 주지 않도록 해야한다
                /**
                 역시 h를 확대해간다
                 */
                if(nexty + nexth > h) {
                    //NSLog(@"%@ expended! by %@ y:%d h:%d hidden:%d", cloudJson[@"name"], nextName, (int)nexty , (int)nexth, nextHidden);
                    h = nexty + nexth;
                }
                    
                thisy = nexty;
                thish = nexth;
                name = nextName;
                thisHidden = nextHidden;
            }
        }
    }
    
    float padding = [WildCardUtil getPaddingTopBottomConverted:cloudJson];
    float margin = [WildCardUtil getMarginTopBottomConverted:cloudJson];
    
//    if(padding > 0)
//        NSLog(@"%@ expended! by padding %d", cloudJson[@"name"], (int)padding);

    return h + padding + margin;
}

+ (float)getMarginTopBottomConverted:(id)layer{
    float nextTopMargin = 0;
    float nextBottomMargin = 0;
    if(layer[@"margin"]) {
        nextTopMargin = [layer[@"margin"][@"marginTop"] floatValue];
        nextBottomMargin = [layer[@"margin"][@"marginBottom"] floatValue];
    }
    
    return [WildCardConstructor convertSketchToPixel:nextTopMargin + nextBottomMargin];
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

+(UIView*)findView:(id)layer name:(NSString*)name {
    if([name isEqualToString:layer[@"name"]])
        return layer;
    
    for(id c in layer[@"layers"]) {
        id r = [self findView:c name:name];
        if(r)
            return r;
    }
    
    return nil;
}

+ (BOOL)isTablet {
    return IS_TABLET;
}

+(CGRect)getTextSize:(NSString*)text font:(UIFont*)font maxWidth:(CGFloat)width maxHeight:(CGFloat)height {
    NSDictionary *attributes = @{NSFontAttributeName: font};
    if(width == CGFLOAT_MAX) {
        CGRect r = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return r;
    } else {
        CGRect r = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingUsesDeviceMetrics | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil];
        //상하가 너무 딱맞음
        r.size.height+=3;
        return r;
    }
}

@end
