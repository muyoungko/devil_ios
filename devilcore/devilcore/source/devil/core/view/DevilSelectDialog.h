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

-(id)initWithViewController:(UIViewController*)vc;
@property (nonatomic, retain) UIViewController* vc;

-(void)popupSelect:(id)array selectedKey:(id)selectedKey title:(NSString*)title yes:(NSString*)yes show:(NSString*)show onselect:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
