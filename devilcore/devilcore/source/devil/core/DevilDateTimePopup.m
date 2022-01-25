//
//  DevilDateTimePopup.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/06/20.
//

#import "DevilDateTimePopup.h"
#import "DevilBlockDialog.h"
#import "DevilUtil.h"

#define BUTTON_YES 1242
#define BUTTON_NO 1243

@interface DevilDateTimePopup ()
@property void (^callback)(id res);
@property (nonatomic, retain) DevilBlockDialog *popup;
@property (nonatomic, retain) UIDatePicker* datepicker;
@property (nonatomic, retain) NSString* date;
@end

@implementation DevilDateTimePopup

-(id)initWithViewController:(UIViewController*)vc {
    self = [super init];
    self.vc = vc;
    return self;
}


-(void)popup:param isDate:(BOOL)isDate onselect:(void (^)(id res))callback{
    
    NSString* selectedKey = param[@"selectedKey"];
    NSString* titleText = param[@"title"];
    
    self.callback = callback;
    DevilBlockDialog *popup = [[DevilBlockDialog alloc] init];
    self.popup = popup;
    
    popup.callback = ^(BOOL yes, id  _Nonnull res) {
        [self.popup dismiss];
    };
    
    int w = [UIScreen mainScreen].bounds.size.width * 0.8f, h = 200;
    
    int offsetY = 10;
    NSString* yes = @"확인";
    NSString* no = @"취소";
    int titleHeight = 0;
    if(titleText)
        titleHeight = 50;
        
    int buttonHeight = 10;
    if(yes){
        buttonHeight = 50;
    }
    
    float buttonWidth = w/2;
    UIView* b = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  w, offsetY + titleHeight + h + buttonHeight)];
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
    
    if(no){
        CGRect rect = CGRectMake(0, titleHeight + h,
                                 buttonWidth, buttonHeight);
        UIButton* button = [DevilBlockDialog getButton:rect :no];
        [button setTag:BUTTON_NO];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [b addSubview:button];
    }
    
    if(yes){
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, titleHeight+h, w, 1)];
        line.backgroundColor =UIColorFromRGB(0xefefef);
        [b addSubview:line];
        
        CGRect rect = CGRectMake(no?buttonWidth:0, titleHeight + h,
                                 buttonWidth, buttonHeight);
        UIButton* button = [DevilBlockDialog getButton:rect :yes];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:BUTTON_YES];
        [b addSubview:button];
    }
    
    UIDatePicker* datepicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, titleHeight, w, h)];
    if(selectedKey) {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyyMMdd"];
        datepicker.date = [df dateFromString:selectedKey];
        self.date = selectedKey;
    } else
        datepicker.date = [NSDate date];
    
    if([param[@"future"] boolValue])
        datepicker.minimumDate = [NSDate date];
        
    if (@available(iOS 13.4, *)) {
        [datepicker setPreferredDatePickerStyle:UIDatePickerStyleWheels];
    }
    
    datepicker.locale = [NSLocale localeWithLocaleIdentifier:[[NSLocale preferredLanguages] firstObject]];
    
    if(isDate)
        datepicker.datePickerMode = UIDatePickerModeDate;
    else
        datepicker.datePickerMode = UIDatePickerModeTime;
    
    datepicker.hidden = NO;
    
    [datepicker addTarget:self action:@selector(LabelChange:) forControlEvents:UIControlEventValueChanged];
    [b addSubview:datepicker];
    self.datepicker = datepicker;
    
    popup.contentView = b;
    popup.showType = DevilBlockDialogShowType_GrowIn;
    popup.dismissType = DevilBlockDialogDismissType_GrowOut;
    popup.shouldDismissOnBackgroundTouch = YES;
    DevilBlockDialogLayout layout = DevilBlockDialogLayoutMake(DevilBlockDialogHorizontalLayout_Center, DevilBlockDialogVerticalLayout_Center);
    [popup showWithLayout:layout];
}

-(void)LabelChange:(id)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMdd"];
    self.date = [df stringFromDate:self.datepicker.date];
    NSLog(@"%@", self.date);
}

- (void)buttonClick:(UIView*)sender {
    if(sender.tag == BUTTON_YES){
        self.callback(self.date);
        [self.popup dismiss];
    } if(sender.tag == BUTTON_NO){
        self.callback(nil);
        [self.popup dismiss];
    }
    self.callback = nil;
}


@end
