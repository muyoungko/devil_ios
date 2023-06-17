//
//  DevilDebugController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/03.
//

#import "DevilDebugController.h"
#import "DevilDebugView.h"
#import "DevilJsonViewer.h"
#import "Jevil.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define TOP_HEIGHT 70

@interface DevilDebugController()

@property (nonatomic) UIView *top;
@property (nonatomic) UITableView *tv;

@end

@implementation DevilDebugController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int sw = screenRect.size.width;
    int sh = screenRect.size.height;
    
    self.top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, TOP_HEIGHT)];
    self.top.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.top];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(15, 5, 120, TOP_HEIGHT-10);
    [button setTitle:@"My Login Link" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(link:) forControlEvents:UIControlEventTouchUpInside];
    [self.top addSubview:button];
    
    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, self.top.frame.size.height, sw, sh-self.top.frame.size.height) style:UITableViewStylePlain];
    self.tv.allowsMultipleSelection = NO;
    self.tv.allowsSelection = YES;
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tv];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    int index = (int)[[DevilDebugView sharedInstance].logList count]-1;
    if(index >= 0)
        [self.tv scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (void)showNavigationBar{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    int offsetY = 0;
    int viewHeight = screenHeight - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
    self.top.frame = CGRectMake(0, offsetY , screenWidth, self.top.frame .size.height);
    self.tv.frame = CGRectMake(0, offsetY + self.top.frame.size.height, screenWidth, viewHeight - self.top.frame .size.height);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[DevilDebugView sharedInstance].logList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id list = [DevilDebugView sharedInstance].logList;
    NSMutableDictionary* item = [list objectAtIndex:[indexPath row]];
    if(item[@"expand"] == @TRUE){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        int sw = screenRect.size.width;
        DevilJSONViewer* j = [[DevilJSONViewer alloc] initWithData:item[@"log"]];
        [j performLayoutWithWidth:sw-30];
        return 70 + j.frame.size.height;
    } else
        return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id list = [DevilDebugView sharedInstance].logList;
    int index = (int)[indexPath row];
    NSMutableDictionary* item = [list objectAtIndex:index];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int sw = screenRect.size.width;
    
    if(![cell viewWithTag:2123]) {
        
        UILabel* type = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, sw-30, 20)];
        type.tag = 2124;
        [cell addSubview:type];
        
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(15, 22, sw-30, 60)];
        title.tag = 2123;
        title.numberOfLines = 3;
        [cell addSubview:title];
        
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(click:)]];
    }
    
    if([cell viewWithTag:3321]) {
        [[cell viewWithTag:3321] removeFromSuperview];
    }
    
    if(item[@"expand"] == @TRUE && item[@"log"]){
        DevilJSONViewer* j = [[DevilJSONViewer alloc] initWithData:item[@"log"]];
        [j performLayoutWithWidth:sw-30];
        [j setFrame:CGRectMake(15, 70, j.frame.size.width, j.frame.size.height)];
        j.tag = 3321;
        [cell addSubview:j];
    }
    
    cell.tag = index;
    ((UILabel*)[cell viewWithTag:2124]).text = [NSString stringWithFormat:@"%@ - %@", item[@"type"], item[@"reg_date"]];
    UILabel* title = ((UILabel*)[cell viewWithTag:2123]);
    title.text = item[@"title"];
    [title sizeThatFits:CGSizeMake(title.frame.size.width, 0)];
    return cell;
}

- (void)click:(UITapGestureRecognizer*)recognizer {
    int index = (int)recognizer.view.tag;
    id list = [DevilDebugView sharedInstance].logList;
    id item = list[index];
    if(item[@"expand"] == @TRUE)
        item[@"expand"] = @FALSE;
    else
        item[@"expand"] = @TRUE;
    [self.tv reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)[indexPath row];
    id list = [DevilDebugView sharedInstance].logList;
    id item = list[index];
    if(item[@"expand"])
        item[@"expand"] = @FALSE;
    else
        item[@"expand"] = @TRUE;
    [self.tv reloadData];
}

- (void)link:(id)sender {
    NSString *token = [Jevil get:@"x-access-token"];
    NSString* link = [NSString stringWithFormat:@"devil-app-builder://project/login/%@/%@",
                      [WildCardConstructor sharedInstance].project_id,
                      token
                      ];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = link;
    
    [Jevil toast:@"My Login Link Copied at clipboard"];
}
@end
