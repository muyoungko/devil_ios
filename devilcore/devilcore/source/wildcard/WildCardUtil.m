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

static float SKETCH_WIDTH = 360;
static BOOL IS_TABLET = NO;

@implementation WildCardUtil

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
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
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
    float screenWidth = (float)screenRect.size.width;
    float screenHeight = (float)screenRect.size.height;

    float sketch_height_of_screen = screenHeight * 360 / screenWidth;
    [WildCardUtil fitToScreenRecur:layer offsety:0 height:sketch_height_of_screen - sketch_height_more];
}

+(void)fitToScreenRecur:(id)layer offsety:(float)offsety height:(float)height{
    id frame = layer[@"frame"];
    float y = [frame[@"y"] floatValue];
    float h = [frame[@"h"] floatValue];

    if(offsety + y + h > height) {
        h -= (offsety + y + h) - height;
        frame[@"h"] = [NSNumber numberWithFloat:h];
    }

    id layers = layer[@"layers"];
    if(layers != nil){
        for(int i=0;i<[layers count];i++){
            [WildCardUtil fitToScreenRecur:layers[i] offsety:(offsety + y) height:height];
        }
    }
}

+(CGRect)getGlobalFrame:(UIView*)v {
    UIView* rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    return [v.superview convertRect:v.frame toView:rootView];
}

+(float) convertSketchToPixel:(float)p {
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
        if([@"text" isEqualToString:cloudJson[@"_class"]]){
            NSString* textContent = cloudJson[@"textContent"];
            NSString* text = [MappingSyntaxInterpreter interpret:textContent :data];
            NSDictionary* textSpec = [cloudJson objectForKey:@"textSpec"];
            float textSize = [WildCardConstructor convertTextSize:[[textSpec objectForKey:@"textSize"] floatValue]];
            UIFont* font = nil;
            if([[textSpec objectForKey:@"bold"] boolValue])
                font = [UIFont boldSystemFontOfSize:textSize];
            else
                font = [UIFont systemFontOfSize:textSize];
            float w = [cloudJson[@"frame"][@"w"] floatValue];
            w = [WildCardConstructor convertSketchToPixel:w];
            
            NSDictionary *attributes = @{NSFontAttributeName: font};
            CGRect rect = [text boundingRectWithSize:CGSizeMake(w, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];

            h = rect.size.height;
        }
        
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
                h = row * [WildCardUtil mesureHeight:targetLayer data:data];
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
                    thish = [WildCardUtil mesureHeight:item data:targetDataJson[0]];
                } else
                    thish = [WildCardUtil mesureHeight:item data:data];

                layersByName[name] = arr[i];
                if(item[@"hiddenCondition"] != nil)
                    hidden = [MappingSyntaxInterpreter ifexpression:item[@"hiddenCondition"] data:data defaultValue:YES];
                else if(item[@"showCondition"] != nil)
                    hidden = ![MappingSyntaxInterpreter ifexpression:item[@"showCondition"] data:data defaultValue:NO];
                
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
    
    float padding = [WildCardConstructor getPaddingTopBottomConverted:cloudJson];
    NSLog(@"%@ %f %f", cloudJson[@"name"], h, padding);
    return h + padding;
}




@end
