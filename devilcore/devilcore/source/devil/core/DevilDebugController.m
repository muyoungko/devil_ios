//
//  DevilDebugController.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/02/03.
//

#import "DevilDebugController.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface DevilDebugController()
@property (nonatomic) UITableView *tv;
@property (nonatomic, retain) id list;
@end

@implementation DevilDebugController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    int sw = screenRect.size.width;
    int sh = screenRect.size.height;
    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, sw, sh) style:UITableViewStylePlain];
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary* item = [_list objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}
        

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int index = (int)[indexPath row];
    
    
}

@end
