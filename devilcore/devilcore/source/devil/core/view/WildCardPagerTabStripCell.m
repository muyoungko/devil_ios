//
//  WildCardPagerTabStripCell.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/23.
//

#import "WildCardPagerTabStripCell.h"

@interface WildCardPagerTabStripCell()

@property UIImageView * imageView;
@property UILabel * label;
@property UIButton * button;

@end

@implementation WildCardPagerTabStripCell

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (!self.label.superview){
        // If label wasn't configured in a XIB or storyboard then it won't have
        // been added to the view so we need to do it programmatically.
        [self.contentView addSubview:self.label];
    }
}

- (UILabel *)label
{
    if (_label) return _label;
    // If _label is nil then it wasn't configured in a XIB or storyboard so this
    // class is being used programmatically. We need to initialise the label,
    // setup some sensible defaults and set an appropriate frame.
    // The label gets added to to the view in willMoveToSuperview:
    _label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
    [self addSubview:_label];
    return _label;
}

- (UIButton *)button
{
    if (_button) return _button;
    _button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_button];
    return _button;
}

@end
