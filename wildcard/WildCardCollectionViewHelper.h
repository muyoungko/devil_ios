//
//  WildCardCollectionViewHelper.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 10..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WildCardUIView;

@interface WildCardCollectionViewHelper : NSObject

@property (nonatomic, retain) NSMutableDictionary* cachedView;
@property (nonatomic, retain) NSMutableDictionary* cachedHeight;

@property (nonatomic, retain) UITableView* tableView;

-(instancetype)initWithTableView:(UITableView*)view;

-(float)getHeight:(NSString*)key cloudJson:(NSDictionary*)cloudJson indexPath:(NSIndexPath *)indexPath data:(NSMutableDictionary*)data;

-(WildCardUIView*)construct:(NSString*)key cloudJson:(NSDictionary*)cloudJson indexPath:(NSIndexPath *)indexPath;

-(void)applyRule:(UIView*)v indexPath:(NSIndexPath *)indexPath data:(NSDictionary*)data;


@end

NS_ASSUME_NONNULL_END
