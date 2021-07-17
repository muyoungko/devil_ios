//
//  WildCardScreenTableView.h
//  cjiot
//
//  Created by Mu Young Ko on 2018. 11. 17..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WildCardMeta.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WildCardScreenTableViewDelegate<NSObject>
@optional
-(void)cellUpdated:(int)index view:(WildCardUIView*)v;
-(void)dragDrop:(int)fromIndex to: (int)toIndex;

@end

@interface WildCardScreenTableView : UITableView<UITableViewDelegate, UITableViewDataSource,UITableViewDragDelegate, UITableViewDropDelegate,  WildCardConstructorInstanceDelegate, UIScrollViewDelegate>


-(id)initWithScreenId:(NSString*)screenKey;
-(void)dragEnable:(BOOL)enable;
-(void)reloadData;
-(void)asyncScrollTo:(int)index;

@property (nonatomic, weak, nullable) id <WildCardConstructorInstanceDelegate> wildCardConstructorInstanceDelegate;
@property (nonatomic, weak, nullable) id <WildCardScreenTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSString* screenKey;
@property (nonatomic, retain) NSMutableDictionary* data;
@property (nonatomic, retain) NSMutableArray* list;
@property (nonatomic, retain) NSMutableArray* listData;
@property (nonatomic, retain) NSArray* ifList;
@property void (^lastItemCallback)(id res);
@property void (^draggedCallback)(id res);

@end

NS_ASSUME_NONNULL_END
