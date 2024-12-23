//
//  DevilSelectDialog.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/08.
//

#import "DevilSelectDialog.h"
#import "DevilBlockDialog.h"
#import "WildCardConstructor.h"
#import "WildCardUtil.h"
#import "DevilController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface DevilSelectDialog()

@property (nonatomic) UITableView *tv;
@property (nonatomic) id list;
@property (nonatomic) NSString* selectedKey;

@property (nonatomic) NSString* keyString;
@property (nonatomic) NSString* valueString;
@property (nonatomic) DevilBlockDialog *popup;
@property void (^callback)(id res);

@property (nonatomic) UIColor* textColorSelected;
@property (nonatomic) UIColor* textColorNormal;
@property (nonatomic) UIColor* yesButtonTextColor;
@property (nonatomic) NSString *showType;
@property (nonatomic) float width;
@property (nonatomic) float height;

@end

@implementation DevilSelectDialog

-(id)initWithViewController:(UIViewController*)vc {
    self = [super init];
    self.vc = vc; 
    return self;
}

-(void)popupSelect:(id)array selectedKey:(id)selectedKey title:(NSString*)titleText yes:(NSString*)yes show:(NSString*)show onselect:(void (^)(id res))callback{
}

-(void)popupSelect:(id)array param:param onselect:(void (^)(id res))callback{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    NSString* ws = param[@"w"];
    NSString* hs = param[@"h"];
    
    self.list = array;
    self.selectedKey = param[@"selectedKey"];
    if(self.selectedKey == [NSNull null])
        self.selectedKey = nil;
    
    if(param[@"key"])
        self.keyString = param[@"key"];
    else
        self.keyString = @"key";
    
    if(param[@"value"])
        self.valueString = param[@"value"];
    else
        self.valueString = @"value";
    NSString* titleText = param[@"title"];
    NSString* yes = param[@"yes"];
    
    NSString* show = @"center";
    if(param[@"show"])
        show = param[@"show"];
    
    self.textColorSelected = UIColorFromRGB(0x5596E0);
    self.textColorNormal = UIColorFromRGB(0x000000);
    self.yesButtonTextColor = UIColorFromRGB(0x5596E0);
    if(param[@"textColorSelected"])
        self.textColorSelected = [WildCardUtil colorWithHexString:param[@"textColorSelected"]];
    if(param[@"textColorNormal"])
        self.textColorNormal = [WildCardUtil colorWithHexString:param[@"textColorNormal"]];
    if(param[@"yesButtonTextColor"])
        self.yesButtonTextColor = [WildCardUtil colorWithHexString:param[@"yesButtonTextColor"]];
    
    
    self.callback = callback;
    
    DevilBlockDialog *popup = [[DevilBlockDialog alloc] init];
    self.popup = popup;
    
    popup.callback = ^(BOOL yes, id  _Nonnull res) {
        [self.popup dismiss];
    };
    
    self.popup.willStartDismissingBlock = ^{
        if([self.vc isKindOfClass:[DevilController class]]) {
            ((DevilController*)self.vc).devilSelectDialog = nil;
        }
    };
    
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    float sh = [UIScreen mainScreen].bounds.size.height;
    
    int w = sw * 0.7f, h= 300;
    //check landscape
    if(sw > sh)
        w = sw * 0.3f;
    
    if(ws)
        self.width = w = [WildCardConstructor convertSketchToPixel:[ws intValue]];
    if(hs)
        self.height = h = [WildCardConstructor convertSketchToPixel:[hs intValue]];
    
    if([@"top" isEqualToString:show] || [@"bottom" isEqualToString:show]){
        w = [UIScreen mainScreen].bounds.size.width;
        if([array count]*55 < h)
            h = (int)[array count]*55;
    } else if([@"point" isEqualToString:show]){
        w = [WildCardConstructor convertSketchToPixel:140];
        if(ws)
            w = [WildCardConstructor convertSketchToPixel:[ws intValue]];
        h = (int)[array count]*55;
        if(hs) {
            h = [WildCardConstructor convertSketchToPixel:[hs intValue]];
        }
    } else if([@"center" isEqualToString:show] && [array count] < 5){
        h = (int)[array count]*55;
    }
    
    int offsetY = 10;
    if([@"top" isEqualToString:show])
        offsetY = 60;
    
    int titleHeight = 0;
    if(titleText != nil)
        titleHeight = 50;
    
    int buttonHeight = 10;
    if(yes){
        buttonHeight = 50;
    }
    
    int extraBottom = 0;
    if([@"bottom" isEqualToString:show])
        extraBottom += 20;
    
    float buttonWidth = w;
    UIView* b = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  w, offsetY + titleHeight + h + buttonHeight + extraBottom)];
    b.backgroundColor = [UIColor whiteColor];
    b.layer.cornerRadius = 10;
    
    if(titleText != nil){
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(20, offsetY, w-20, titleHeight-10)];
        title.text = titleText;
        title.textColor = UIColorFromRGB(0x333333);
        title.textAlignment = UITextAlignmentLeft;
        title.font = [UIFont systemFontOfSize:19.0f];
        [b addSubview:title];
        
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY + titleHeight-1, w, 1)];
        line.backgroundColor =UIColorFromRGB(0xefefef);
        [b addSubview:line];
    }

    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, offsetY + titleHeight, w, h) style:UITableViewStylePlain];
    [self.tv setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tv setSeparatorColor:[UIColor clearColor]];
    self.tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tv.frame.size.width, 1)];
    
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [b addSubview:self.tv];
    
    if(yes){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY + titleHeight + h, w, 1)];
        line.backgroundColor =UIColorFromRGB(0xefefef);
        [b addSubview:line];
        
        CGRect rect = CGRectMake(0, offsetY + titleHeight + h,buttonWidth, buttonHeight);
        UIButton* button = [DevilBlockDialog getButton:rect :yes];
        [button setTitleColor:self.yesButtonTextColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [b addSubview:button];
    }
    
    popup.contentView = b;
    popup.showType = DevilBlockDialogShowType_GrowIn;
    popup.dismissType = DevilBlockDialogDismissType_GrowOut;
    if([@"bottom" isEqualToString:show]){
        popup.showType = DevilBlockDialogShowType_SlideInFromBottom;
        popup.dismissType = DevilBlockDialogDismissType_SlideOutToBottom;
    } else if([@"top" isEqualToString:show]) {
        popup.showType = DevilBlockDialogShowType_SlideInFromTop;
        popup.dismissType = DevilBlockDialogDismissType_SlideOutToTop;
    } else if([@"point" isEqualToString:show]) {
        popup.showType = DevilBlockDialogShowType_GrowFromPoint;
        popup.dismissType = DevilBlockDialogDismissType_ShrinkToPoint;
        if(param[@"view"]){
            UIView* click = param[@"view"];
            CGRect f = [WildCardUtil getGlobalFrame:click];
            float x = f.origin.x + f.size.width / 2.0f;
            float y = f.origin.y + f.size.height / 2.0f;
            float sw = [UIScreen mainScreen].bounds.size.width;
            float sh = [UIScreen mainScreen].bounds.size.height;
            if(x > sw/2)
                x = x - w;
            if(y > sh/2)
                y = y - h;
            popup.px = x;
            popup.py = y;
        }
    }
    self.showType = show;
    
    popup.shouldDismissOnBackgroundTouch = YES;
    DevilBlockDialogLayout layout = DevilBlockDialogLayoutMake(DevilBlockDialogHorizontalLayout_Center, DevilBlockDialogVerticalLayout_Center);
    [popup showWithLayout:layout];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.tv);
}

- (void)buttonClick:(UIView*)sender {
    [self.popup dismiss];
    self.callback = nil;
}


- (void)close {
    [self.vc dismissViewControllerAnimated: YES completion: nil];
}

- (void)alertControllerBackgroundTapped
{
    [self close];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.showType isEqual:@"point"]) {
        if([_list count] == 1 && _height > 0) {
            return _height;
        }
        NSMutableDictionary* item = [_list objectAtIndex:[indexPath row]];
        NSString* n = item[_valueString];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
        CGRect textSize = [n boundingRectWithSize:CGSizeMake(self.width - 60, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return MAX(textSize.size.height, 55);
    }
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* item = [_list objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString* k = nil;
    NSString* n = nil;
    k = item[_keyString];
    n = item[_valueString];
    
    cell.textLabel.text = n;
    cell.textLabel.numberOfLines = 10;
    
    if([k isKindOfClass:[NSString class]] && [k isEqualToString:self.selectedKey])
        cell.textLabel.textColor = self.textColorSelected;
    else if([k isKindOfClass:[NSNumber class]] && k == self.selectedKey)
        cell.textLabel.textColor = self.textColorSelected;
    else
        cell.textLabel.textColor = self.textColorNormal;
    
    cell.tag = [indexPath row];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [cell addGestureRecognizer:singleFingerTap];
    
    return cell;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    int index = (int)recognizer.view.tag;
    NSString* key = _list[index][_keyString];
    [self.popup dismiss];
    self.callback(key);
}

        

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)[indexPath row];
    NSString* key = _list[index][_keyString];
    [self.popup dismiss];
    self.callback(key);
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
