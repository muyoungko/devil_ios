//
//  LittViewerViewController.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 20..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LittViewerViewController : UIViewController<UICollectionViewDelegate , UICollectionViewDataSource,
    UICollectionViewDataSourcePrefetching,
    UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *tv;

@property (retain, nonatomic) NSMutableDictionary *cloudJsonMeta;
@property (retain, nonatomic) NSMutableArray *data;

@property (retain, nonatomic) UIRefreshControl *refreshControl;

@property (retain, nonatomic) NSMutableArray *bottomData;
@property (retain, nonatomic) UICollectionView *bottomSelectView;


@end
