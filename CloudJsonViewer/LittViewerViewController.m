//
//  LittViewerViewController.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 20..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "LittViewerViewController.h"

#import <AFNetworking/AFNetworking.h>
#import "WildCardConstructor.h"
#import "UIImageView+AFNetworking.h"

@interface LittViewerViewController ()

@end

#define CV_BOTTOM 4123123

@implementation LittViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bottomData = [[NSMutableArray alloc] init];
    
    _data = [[NSMutableArray alloc] init];
    _cloudJsonMeta = [[NSMutableDictionary alloc] init];
    
    
    
    _refreshControl = [[UIRefreshControl alloc]init];
    [_tv addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    
    
    
    int h = 82;
    int headerHeight = 40;
    int pannelHeight = h + headerHeight+2;
    UIView* bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight-pannelHeight-50, screenWidth, pannelHeight)];
    bottomView.backgroundColor = [UIColor colorWithDisplayP3Red:0.0 green:0.0 blue:0.0 alpha:0.6];
    [self.view addSubview:bottomView];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, screenWidth, headerHeight)];
    label.text = @"My Listing View";
    label.textColor = [UIColor whiteColor];
    [bottomView addSubview:label];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(100, 100);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.bottomSelectView = [[UICollectionView alloc] initWithFrame:CGRectMake(2, headerHeight, screenWidth-4, h) collectionViewLayout:flowLayout];
    [self.bottomSelectView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.bottomSelectView.backgroundColor = [UIColor clearColor];
    self.bottomSelectView.delegate = self;
    self.bottomSelectView.dataSource = self;
    self.bottomSelectView.tag = CV_BOTTOM;
    [bottomView addSubview:_bottomSelectView];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"http://www.sering.co.kr:3000/apiSampleJsonList"
      parameters:@{}
         success:^(AFHTTPRequestOperation *operation, id myList) {
             [_bottomData removeAllObjects];
             NSArray* list = (NSArray*)myList;
             for(int i=0;i<[list count];i++)
             {
                 [_bottomData addObject:[list objectAtIndex:i]];
             }
             [_bottomSelectView reloadData];
         }
     failure:nil];
}

- (void)refreshTable {
    [_refreshControl endRefreshing];
}

- (void)loadData:(NSString*)key
{
    NSString *url = @"http://www.sering.co.kr:3000/cloudJsonGroup";
    NSString *url2 = @"http://www.sering.co.kr:3000/apiSample";
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:url
      parameters:@{}
         success:^(AFHTTPRequestOperation *operation, id cloudJson) {
             
             [manager GET:url2
               parameters:@{}
                  success:^(AFHTTPRequestOperation *operation, id sampleData) {
                      
                      _data = sampleData;
                      _cloudJsonMeta = cloudJson;
                      
                      NSArray* keys=[_cloudJsonMeta allKeys];
                      for(int i=0;i<[keys count];i++)
                      {
                          [_tv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:[keys objectAtIndex:i]];
                      }
                      [_tv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Nothing"];
                      
                      [_tv reloadData];
                      
                  }
                  failure:nil];
         }
         failure:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView.tag == CV_BOTTOM)
        return [_bottomData count];
    else
        return [_data count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(collectionView.tag == CV_BOTTOM)
    {
        return CGSizeMake(80, 80);
    }
    else
    {
        int screenWidth = [[UIScreen mainScreen] bounds].size.width;
        
//        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"aaa" forIndexPath:indexPath];
//        if(cell == nil)
//        {
//
//        }
        
        return CGSizeMake(screenWidth, 400);
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.tag == CV_BOTTOM)
    {
        NSDictionary *item = [_bottomData objectAtIndex:[indexPath row]];
        NSString *key = [item objectForKey:@"key"];
        [self loadData:key];
    }
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView.tag == CV_BOTTOM)
    {
        NSDictionary *item = [_bottomData objectAtIndex:[indexPath row]];
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor grayColor];
        
        UIView* childUIView = [[cell subviews] objectAtIndex:0];
        if([[childUIView subviews] count] == 0)
        {
            UILabel *iv = [[UILabel alloc] initWithFrame:CGRectMake(0,0,80,80)];
            iv.tag = 445432;
            iv.textColor = [UIColor whiteColor];
            iv.textAlignment = NSTextAlignmentCenter;
            [childUIView addSubview:iv];
        }
        
        UILabel *iv = [childUIView viewWithTag:445432];
        iv.text = [item objectForKey:@"key"];
        
        return cell;
    }
    else
    {
        NSMutableDictionary *item = [_data objectAtIndex:[indexPath row]];
        NSString *type = [item objectForKey:@"groupName"];
        
        
        UICollectionViewCell *cell = nil;
        
        if([_cloudJsonMeta objectForKey:type] != nil)
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:type forIndexPath:indexPath];
            
            UIView* childUIView = [[cell subviews] objectAtIndex:0];
            if([[childUIView subviews] count] == 0)
            {
                NSDictionary* layer = [_cloudJsonMeta objectForKey:type];
                [WildCardConstructor constructLayer:childUIView withLayer:layer];
            }
            
            WildCardUIView *v = [[childUIView subviews] objectAtIndex:0];
            [WildCardConstructor applyRule:v withData:item];
        }
        else
        {
            int screenWidth = [[UIScreen mainScreen] bounds].size.width;
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Nothing" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor redColor];
            UIView* childUIView = [[cell subviews] objectAtIndex:0];
            if([[childUIView subviews] count] == 0)
            {
                UILabel *iv = [[UILabel alloc] initWithFrame:CGRectMake(0,0,screenWidth,80)];
                iv.tag = 445432;
                iv.textColor = [UIColor whiteColor];
                iv.textAlignment = NSTextAlignmentCenter;
                [childUIView addSubview:iv];
                iv.text = @"Unsupported Block";
            }
        }
        
        return cell;
    }
}





@end
