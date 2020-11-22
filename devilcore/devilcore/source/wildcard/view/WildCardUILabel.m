//
//  WildCardUILabel.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardUILabel.h"
#import "WildCardUIView.h"
#import "WildCardUtil.h"

@implementation WildCardUILabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stroke = NO;
        self.wrap_width = NO;
        self.wrap_height = NO;
        self.lineBreakMode = NSLineBreakByCharWrapping;
        self.alignment = GRAVITY_LEFT_TOP;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    [super setText:text];

    if(_wrap_width && _wrap_height)
    {
        WildCardUIView* parent = (WildCardUIView*)[self superview];
        NSDictionary *attributes = @{NSFontAttributeName: self.font};
        CGRect textSize = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        self.frame = CGRectMake(parent.paddingLeft, parent.paddingTop, textSize.size.width, textSize.size.height);
        CGRect superFrame = parent.frame;
        parent.frame = CGRectMake(superFrame.origin.x, superFrame.origin.y, parent.paddingLeft + self.frame.size.width + parent.paddingRight, parent.paddingTop + self.frame.size.height + parent.paddingBottom);
    }
    else if(_wrap_width)
    {
        WildCardUIView* parent = (WildCardUIView*)[self superview];
        NSDictionary *attributes = @{NSFontAttributeName: self.font};
        CGRect textSize = [self.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        self.frame = CGRectMake(parent.paddingLeft, 0, textSize.size.width, self.frame.size.height);
        
        CGRect superFrame = parent.frame;
        parent.frame = CGRectMake(superFrame.origin.x, superFrame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    else if(_wrap_height)
    {
        WildCardUIView* parent = (WildCardUIView*)[self superview];
        NSDictionary *attributes = @{NSFontAttributeName: self.font};
        CGRect textSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        self.frame = CGRectMake(0, parent.paddingTop, self.frame.size.width, textSize.size.height);
        
        CGRect superFrame = parent.frame;
        parent.frame = CGRectMake(superFrame.origin.x, superFrame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    else
    {
        if([WildCardUtil hasGravityCenterVertical:_alignment] ||
           [WildCardUtil hasGravityBottom:_alignment])
        {
            
        }
        else
        {
            WildCardUIView* parent = (WildCardUIView*)[self superview];
            NSDictionary *attributes = @{NSFontAttributeName: self.font};
            if(self.numberOfLines == 1)
            {
                
            }
            else
            {
                CGRect textSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
                self.frame = CGRectMake(0, parent.paddingTop, self.frame.size.width, textSize.size.height);
            }
        }
    }
    
    if(_wrap_height||_wrap_width)
    {
        //WildCardUIView* parent = [self superview];
        //NSLog(@"wrapContent(text) - %@ (%f, %f)" , parent.name, parent.frame.size.width, parent.frame.size.height);
    }
    
    if(_stroke)
    {
        _strokeRect = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, 1);
    }
}

- (void)drawTextInRect:(CGRect)rect {
    
    if(_stroke)
    {
        [super drawTextInRect:rect];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, [self.textColor CGColor]);
        CGContextFillRect(ctx, _strokeRect);
    }
    else{
        [super drawTextInRect:rect];
    }
}

@end
