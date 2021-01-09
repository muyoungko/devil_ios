//
//  DevilSelectDialog.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/08.
//

#import "DevilSelectDialog.h"
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
@property void (^callback)(id res);
@end

@implementation DevilSelectDialog

-(id)initWithViewController:(UIViewController*)vc {
    self = [super init];
    self.vc = vc;
    return self;
}

-(void)popupSelect:(id)array selectedKey:(id)selectedKey onselect:(void (^)(id res))callback{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    self.list = array;
    self.selectedKey = selectedKey;
    self.keyString = @"key";
    self.valueString = @"value";
    self.callback = callback;
    
    int w = 300;
    int h = 300;
    self.tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, w, h) style:UITableViewStylePlain];
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.tv registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIViewController* content = [[UIViewController alloc] init];
    content.view = self.tv;
    content.preferredContentSize = CGSizeMake(w, h);

    [alertController setValue:content forKey:@"contentViewController"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alertController addAction:cancelAction];
    [self.vc presentViewController:alertController animated:YES completion:^{
        alertController.view.superview.userInteractionEnabled = YES;
        [alertController.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(alertControllerBackgroundTapped)]];
 
    }];
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
    [self.vc dismissViewControllerAnimated:YES completion:^{
        self.callback(key);
    }];
}

@end
