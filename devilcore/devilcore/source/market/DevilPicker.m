//
//  DevilPicker.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/12/25.
//

#import "DevilPicker.h"
#import "WildCardUICollectionView.h"
#import "WildCardUILabel.h"
#import "WildCardUIView.h"
#import "WildCardCollectionViewAdapter.h"
#import "WildCardUtil.h"
#import "Jevil.h"

@interface DevilPicker ()

@property (nonatomic, retain) WildCardCollectionViewAdapter* picker_list_adapter;
@property (nonatomic, retain) WildCardUILabel* picker_selected_text;
@property (nonatomic, retain) NSString* watch_key;
@property (nonatomic, retain) NSString* json_key;
@property (nonatomic, retain) NSString* list_key;
@property (nonatomic, retain) NSString* json_value;
@property (nonatomic, retain) NSString* value_selected_script;
@end

@implementation DevilPicker


-(id)initWithLayer:(id)market meta:(id)meta{
    self = [super initWithLayer:market meta:meta];
    self.picker_list_adapter = nil;
    self.list_key = market[@"select2"];
    self.json_key = market[@"select3"];
    self.json_value = market[@"select4"];
    self.watch_key = market[@"select5"];
    self.value_selected_script = market[@"select6"];
    return self;
}

-(void)created{
    [super created];
    if(!self.picker_list_adapter) {
        WildCardUICollectionView* picker_list = [[self.meta getView:@"picker_list"] subviews][0];
        self.picker_list_adapter = (WildCardCollectionViewAdapter*)picker_list.delegate;
        self.picker_selected_text = (WildCardUILabel*)[self.meta getTextView:@"picker_selected_text"];
        self.picker_list_adapter.collectionView.hidden = YES;
        self.picker_list_adapter.scrolledCallback = ^(id res) {
            [self picker_shape];
        };
        
        self.picker_list_adapter.draggedCallback = ^(id res) {
            [[JevilInstance currentInstance] pushData];
            [self picker_shape];
            if(self.value_selected_script) {
                [[JevilInstance currentInstance].jevil code:self.value_selected_script
                                             viewController:[JevilInstance currentInstance].vc
                                                       data:self.meta.correspondData
                                                       meta:self.meta];
            }
        };
    }
}

-(void)update:(id)opt{
    [super update:opt];
    self.picker_list_adapter.collectionView.hidden = NO;
    
    [self picker_shape];
    NSLog(@"Select to %@", self.meta.correspondData[self.watch_key]);
    //NSLog(@"adapter.data cound %@", [self.picker_list_adapter.data count]);
    //NSLog(@"list.data count to %d", );
    if(self.meta.correspondData[self.watch_key]) {
        for(int i=0;i<[self.meta.correspondData[self.list_key] count]; i++) {
            id d = self.meta.correspondData[self.list_key][i];
            if([d[self.json_key] isEqual:self.meta.correspondData[self.watch_key]]) {
                [(WildCardUICollectionView*)self.picker_list_adapter.collectionView asyncScrollTo:i : YES];
                [self performSelector:@selector(picker_shape) withObject:nil afterDelay:0.0f];
                break;
            }
        }
    }
}

-(void)picker_shape {
    CGPoint picker_center = [[self.picker_list_adapter.collectionView superview] convertPoint:self.picker_list_adapter.collectionView.center toView:nil];
    CGRect picker_rect = [[self.picker_list_adapter.collectionView superview] convertRect:self.picker_list_adapter.collectionView.frame toView:nil];
    
//    int selected_data_index = 0;
//    if(self.meta.correspondData[self.watch_key]) {
//        for(int i=0;i<[self.meta.correspondData[self.list_key] count]; i++) {
//            id d = self.meta.correspondData[self.list_key][i];
//            if([d[self.json_key] isEqual:self.meta.correspondData[self.watch_key]]) {
//                selected_data_index = i;
//                break;
//            }
//        }
//    }
//
//    id cells = [self.picker_list_adapter.collectionView subviews];
//    for(int i=0;i<[cells count];i++){
//        UIView* c = cells[i];
//        int index = (int)c.tag;
//
//        c.alpha = 1.0f - (fabs(selected_data_index - index) / 10);
//
//        WildCardUIView* v = [c viewWithTag:CELL_UNDER_WILDCARD];
//        UILabel* cell_text = [v.meta getTextView:@"picker_cell_text"];
//        if(index < selected_data_index) {
//            cell_text.textColor = self.up_color;
//        } else {
//            cell_text.textColor = self.bottom_color;
//        }
//        NSLog(@"cell_index = %d", index);
//    }
    

    float picker_harf = picker_rect.size.height/2.0f;
    id cells = [self.picker_list_adapter.collectionView subviews];
    int center_index = 0;
    float center_y = 0;
    for(int i=0;i<[cells count];i++){
        UIView* c = cells[i];
        CGRect crect = [self.picker_list_adapter.collectionView convertRect:c.frame toView:nil];
        int index = (int)c.tag;
        id cdata = self.picker_list_adapter.data[index];
        if(CGRectContainsPoint(crect, picker_center)) {
            //NSLog(@"center data = %@", self.picker_list_adapter.data[index]);
            self.picker_selected_text.text = [NSString stringWithFormat:@"%@", cdata[self.json_value]];
            self.meta.correspondData[self.watch_key] = cdata[self.json_key];
            center_index = i;
            center_y = c.frame.origin.y;
        }

        float crect_y = crect.origin.y + crect.size.height/2.0f;
        //NSLog(@"crect.origin.y = %f picker_center = %f", crect.origin.y, picker_center.y);
        //NSLog(@"cdata %@", cdata);
        c.alpha = (1.0f - (fabs(picker_center.y - crect_y) / picker_harf)) * 0.8f + 0.2f;
    }
    
    // 1. 진입시
    // 2. 상하단 여백 줘서 0 index 선택가능하게하기
    //NSLog(@"picker_shape center_index = %d [cells count] = %d", center_index, [cells count]);
}


-(void)pause{
    [super pause];
}
-(void)resume{
    [super resume];
}
-(void)destory {
    [super destory];
}

@end
