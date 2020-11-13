//
//  WildCardCollectionViewHelper.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 10. 10..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardCollectionViewHelper.h"
#import "WildCardConstructor.h"

@implementation WildCardCollectionViewHelper

-(instancetype)initWithTableView:(UITableView*)view
{
    self = [super init];
    self.tableView = view;
    self.cachedView = [[NSMutableDictionary alloc] init];
    self.cachedHeight = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(float)getHeight:(NSString*)key cloudJson:(NSDictionary*)cloudJson indexPath:(NSIndexPath *)indexPath data:(NSMutableDictionary*)data;
{
    NSString* rowKey = [NSString stringWithFormat:@"%ld", indexPath.row];
    
    NSNumber* n = [_cachedHeight objectForKey:rowKey];
    if(n == nil)
    {
        UIView* v = [_cachedView objectForKey:key];
        if(v == nil)
        {
            v = [WildCardConstructor constructLayer:nil withLayer:cloudJson];
            [_cachedView setObject:v forKey:rowKey];
        }
        
        [WildCardConstructor applyRule:(WildCardUIView*)v withData:data];
        n = [NSNumber numberWithFloat:v.frame.size.height];
        [_cachedHeight setObject:n forKey:rowKey];
    }

    return [n floatValue];
}

-(WildCardUIView*)construct:(NSString*)key cloudJson:(NSDictionary*)cloudJson indexPath:(NSIndexPath *)indexPath;
{
    NSString* rowKey = [NSString stringWithFormat:@"%ld", indexPath.row];
    return [_cachedView objectForKey:rowKey];
}

-(void)applyRule:(UIView*)v indexPath:(NSIndexPath *)indexPath data:(NSDictionary*)data
{
    [WildCardConstructor applyRule:v withData:data];
}

@end
