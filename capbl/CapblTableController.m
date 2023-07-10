//
//  TableController.m
//  capblapp
//
//  Created by Mu Young Ko on 2023/05/18.
//

#import "CapblTableController.h"
#import "SecureView.h"

@interface CapblTableController ()

@property SecureView *sv;
@property (retain, nonatomic) UITableView *tv;

@end

@implementation CapblTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    __block float sw = [UIScreen mainScreen].bounds.size.width;
    __block float sh = [UIScreen mainScreen].bounds.size.height;
    
    _tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _tv.delegate = self;
    _tv.dataSource = self;
    _tv.hidden = YES;
    self.sv = [[SecureView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_sv];
    [_sv addSubview:_tv];
    
    [self.sv makeSecure];
    
    //일부러 시간차를 두고 뷰의 사이즈와 hidden을 조정함
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        _tv.hidden = NO;
        _tv.frame = CGRectMake(0, 0, sw, sh);
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"seleted");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = cell = [_tv dequeueReusableCellWithIdentifier:@"cell"];

    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    NSString *textLabelTitle = @"text1";
    NSString *textLabelDetail = @"text2";
    cell.textLabel.text = textLabelTitle;
    cell.detailTextLabel.text = textLabelDetail;

    return cell;
}

@end
