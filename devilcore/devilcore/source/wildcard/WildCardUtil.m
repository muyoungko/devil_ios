//
//  WildCardUtil.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardUtil.h"
#import "WildCardUIView.h"

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

    if(y + h > height) {
        h -= (y + h) - height;
        frame[@"h"] = [NSNumber numberWithFloat:h];
    }

    id layers = layer[@"layers"];
    if(layers != nil){
        for(int i=0;i<[layers count];i++){
            [WildCardUtil fitToScreenRecur:layers[i] offsety:(offsety + y) height:height];
        }
    }
}

@end
