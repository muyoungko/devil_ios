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
#import "Jevil.h"
#import "WildCardConstructor.h"

@implementation WildCardUILabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.stroke = NO;
        self.wrap_width = NO;
        self.wrap_height = NO;
        self.alignment = GRAVITY_LEFT_TOP;
        self.max_height = -1;
        self.textSelection = NO;
        self.word_wrap = NO;
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
}

- (void)setTextSelection:(BOOL)textSelection{
    if(textSelection){
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textPressed:)];
        [WildCardConstructor userInteractionEnableToParentPath:self depth:10];
        [[self superview] addGestureRecognizer:longPress];
        [self setUserInteractionEnabled:YES];
    }
}

- (void) textPressed:(UILongPressGestureRecognizer *) gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:self.text];
        [Jevil toast:@"클립보드에 복사되었습니다"];
    }
}

- (void)setText:(NSString *)text
{
    [super setText:text];

    /**
     한줄처리 ... 처리
     두줄이상 ... 처리 charwrap, wordwrap
     wrap_height - charwrap, wordwrap
     wrap_height, wrap_width - charwrap, wordwrap
     */
    
    if(_wrap_width && _wrap_height)
    {
        WildCardUIView* parent = (WildCardUIView*)[self superview];
        CGRect textSize = [WildCardUtil getTextSize:self.text font:self.font
                                           maxWidth:(self.max_width?self.max_width - parent.paddingLeft - parent.paddingRight:CGFLOAT_MAX)
                                          maxHeight:CGFLOAT_MAX];
        
        //i 나 j, g가 조금씩 짤리니 조금씩 키워줘야함
        self.frame = CGRectMake(parent.paddingLeft, parent.paddingTop, textSize.size.width+4, textSize.size.height+4);
        CGRect superFrame = parent.frame;
        parent.frame = CGRectMake(superFrame.origin.x, superFrame.origin.y, parent.paddingLeft + self.frame.size.width + parent.paddingRight, parent.paddingTop + self.frame.size.height + parent.paddingBottom);
        self.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else if(_wrap_width)
    {
        WildCardUIView* parent = (WildCardUIView*)[self superview];
        CGRect textSize = [WildCardUtil getTextSize:self.text font:self.font
                                            maxWidth:CGFLOAT_MAX
                                           maxHeight:self.frame.size.height];
        self.frame = CGRectMake(parent.paddingLeft, 0, textSize.size.width, self.frame.size.height);
        
        CGRect superFrame = parent.frame;
        parent.frame = CGRectMake(superFrame.origin.x, superFrame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    else if(_wrap_height)
    {
        WildCardUIView* parent = (WildCardUIView*)[self superview];
        CGRect textSize = [WildCardUtil getTextSize:self.text font:self.font maxWidth:self.frame.size.width maxHeight:self.frame.size.height];
        
        textSize.size.height = MIN(self.font.lineHeight * self.numberOfLines, textSize.size.height);
            
        self.frame = CGRectMake(0, parent.paddingTop, self.frame.size.width, textSize.size.height);
        if(self.numberOfLines == 2)
            NSLog(@"a");
        CGRect superFrame = parent.frame;
        parent.frame = CGRectMake(superFrame.origin.x, superFrame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    else
    {
        if(self.max_height == -1)
            self.max_height = self.frame.size.height;
        
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
                CGRect textSize = [WildCardUtil getTextSize:self.text font:self.font
                                                    maxWidth:self.frame.size.width
                                                   maxHeight:self.max_height];
                self.frame = CGRectMake(0, parent.paddingTop, self.frame.size.width, textSize.size.height);
            }
        }
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
