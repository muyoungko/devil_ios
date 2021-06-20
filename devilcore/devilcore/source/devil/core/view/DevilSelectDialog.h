//
//  DevilSelectDialog.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/08.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilSelectDialog : NSObject<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UIViewController* vc;

-(id)initWithViewController:(UIViewController*)vc;
-(void)popupSelect:(id)array selectedKey:(id)selectedKey title:(NSString*)title yes:(NSString*)yes show:(NSString*)show onselect:(void (^)(id res))callback;
-(void)popupSelect:(id)array param:param onselect:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
