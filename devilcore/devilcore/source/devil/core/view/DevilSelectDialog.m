//
//  DevilSelectDialog.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/08.
//

#import "DevilSelectDialog.h"
#import "DevilBlockDialog.h"

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
@end

@implementation DevilSelectDialog

-(id)initWithViewController:(UIViewController*)vc {
    self = [super init];
    self.vc = vc; 
    return self;
}

-(void)popupSelect:(id)array selectedKey:(id)selectedKey title:(NSString*)titleText yes:(NSString*)yes show:(NSString*)show onselect:(void (^)(id res))callback{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    self.list = array;
    self.selectedKey = selectedKey;
    self.keyString = @"key";
    self.valueString = @"value";
    self.callback = callback;
    
    DevilBlockDialog *popup = [[DevilBlockDialog alloc] init];
    self.popup = popup;
    
    popup.callback = ^(BOOL yes, id  _Nonnull res) {
        [self.popup dismiss];
    };
    
    int w = [UIScreen mainScreen].bounds.size.width * 0.7f, h= 300;
    if([@"top" isEqualToString:show] || [@"bottom" isEqualToString:show])
        w = [UIScreen mainScreen].bounds.size.width;
    
    if([array count]*55 < h)
        h = (int)[array count]*55;
    
    int titleHeight = 50;
    if(titleText == nil){
        if([@"top" isEqualToString:show])
            titleHeight = 50;
        else
            titleHeight = 10;
    }
    
    int buttonHeight = 10;
    if(yes){
        if([@"top" isEqualToString:show])
            buttonHeight = 110;
        else
            buttonHeight = 60;
    } else {
        if([@"bottom" isEqualToString:show])
            buttonHeight = 0;
    }

    float buttonWidth = w;
    
    UIView* b = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  w, titleHeight + h + buttonHeight)];
    b.backgroundColor = [UIColor whiteColor];
    b.layer.cornerRadius = 10;
    
    
    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, titleHeight, w, h) style:UITableViewStylePlain];
    [self.tv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [b addSubview:self.tv];
    
    if(titleText != nil){
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, w, titleHeight-10)];
        title.text = titleText;
        title.textColor = UIColorFromRGB(0x333333);
        title.textAlignment = UITextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:17.0f];
        [b addSubview:title];
    }
    
    if(yes){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, titleHeight+h, w, 1)];
        line.backgroundColor =UIColorFromRGB(0xefefef);
        [b addSubview:line];
        
        CGRect rect = CGRectMake(0, titleHeight + h,buttonWidth, buttonHeight);
        UIButton* button = [DevilBlockDialog getButton:rect :yes];
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
        ;//TODO
    }
    
    popup.shouldDismissOnBackgroundTouch = YES;
    DevilBlockDialogLayout layout = DevilBlockDialogLayoutMake(DevilBlockDialogHorizontalLayout_Center, DevilBlockDialogVerticalLayout_Center);
    [popup showWithLayout:layout];
}

- (void)buttonClick:(UIView*)sender {
    [self.popup dismiss];
    self.callback = nil;
}



- (void)alertControllerBackgroundTapped
{
    [self.vc dismissViewControllerAnimated: YES completion: nil];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    if([k isEqualToString:self.selectedKey])
        cell.textLabel.textColor = UIColorFromRGB(0x5596E0);
    else
        cell.textLabel.textColor = UIColorFromRGB(0x000000);
    
    return cell;
}
        

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)[indexPath row];
    NSString* key = _list[index][_keyString];
    [self.popup dismiss];
    self.callback(key);
}

@end
