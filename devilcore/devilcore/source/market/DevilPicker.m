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
        
        picker_list.contentInset = UIEdgeInsetsMake(picker_list.frame.size.height/2.0f, 0, picker_list.frame.size.height/2.0f, 0);
        
        self.picker_list_adapter = (WildCardCollectionViewAdapter*)picker_list.delegate;
        
        self.picker_selected_text = (WildCardUILabel*)[self.meta getTextView:@"picker_selected_text"];
        self.picker_selected_text.text = @"";
        self.picker_list_adapter.collectionView.hidden = YES;
        self.picker_list_adapter.scrolledCallback = ^(id res) {
            [self picker_shape];
        };
        
        self.picker_list_adapter.draggedCallback = ^(id res) {
            int selectedIndex = [self picker_shape];
            id theThing = self.meta.correspondData[self.list_key][selectedIndex];
            
            //NSLog(@"draggedCallback data_index = %d key = %@", selectedIndex, theThing[self.json_key]);
            [(WildCardUICollectionView*)self.picker_list_adapter.collectionView asyncScrollTo:selectedIndex : YES];
            
            self.meta.correspondData[self.watch_key] = theThing[self.json_key];
            
            [[JevilInstance currentInstance] pushData];
            if(self.value_selected_script) {
                [[JevilInstance currentInstance].jevil code:self.value_selected_script
                                             viewController:[JevilInstance currentInstance].vc
                                                       data:self.meta.correspondData
                                                       meta:self.meta];
            }
        };
    }
}

-(void)update:(JSValue*)opt{
    [super update:opt];
    self.picker_list_adapter.collectionView.hidden = NO;
    
    [self picker_shape];
    //NSLog(@"update to %@", self.meta.correspondData[self.watch_key]);
    //NSLog(@"adapter.data cound %@", [self.picker_list_adapter.data count]);
    //NSLog(@"list.data count to %d", );
    if([self.meta.correspondData hasProperty:self.watch_key]) {
        for(int i=0;i<[self.meta.correspondData[self.list_key][@"length"] toInt32]; i++) {
            id d = self.meta.correspondData[self.list_key][i];
            if([d[self.json_key] isEqual:self.meta.correspondData[self.watch_key]]) {
                [(WildCardUICollectionView*)self.picker_list_adapter.collectionView asyncScrollTo:i : YES];
                break;
            }
        }
    }
}

-(int)picker_shape {
    CGPoint picker_center = [[self.picker_list_adapter.collectionView superview] convertPoint:self.picker_list_adapter.collectionView.center toView:nil];
    CGRect picker_rect = [[self.picker_list_adapter.collectionView superview] convertRect:self.picker_list_adapter.collectionView.frame toView:nil];

    float picker_harf = picker_rect.size.height/2.0f;
    id cells = [self.picker_list_adapter.collectionView subviews];
    int center_index = 0;
    float center_y = 0;
    float min = 1000000;
    int data_index = 0;
    for(int i=0;i<[cells count];i++){
        UIView* c = cells[i];
        CGRect crect = [self.picker_list_adapter.collectionView convertRect:c.frame toView:nil];
        CGPoint cpoint = [self.picker_list_adapter.collectionView convertPoint:c.center toView:nil];
        int index = (int)c.tag;
        
        float d = [self distanceBetween:picker_center and:cpoint];
        //NSLog(@"d = %f", d);
        if(d < min) {
            min = d;
            //NSLog(@"center data = %@", self.picker_list_adapter.data[index]);
            center_index = i;
            data_index = index;
            center_y = c.frame.origin.y;
            //NSLog(@"min change. center_index = %d  data_index=%d ", center_index, data_index);
        }

        float crect_y = crect.origin.y + crect.size.height/2.0f;
        //NSLog(@"crect.origin.y = %f picker_center = %f", crect.origin.y, picker_center.y);
        //NSLog(@"cdata %@", cdata);
        c.alpha = (1.0f - (fabs(picker_center.y - crect_y) / picker_harf)) * 0.8f + 0.2f;
    }
    
    id cdata = self.picker_list_adapter.data[data_index];
    if(cdata && cdata[self.json_value])
        self.picker_selected_text.text = [NSString stringWithFormat:@"%@", cdata[self.json_value]];
    else
        self.picker_selected_text.text = @"";
    //NSLog(@"picker_shape %@" , self.picker_selected_text.text);
    //NSLog(@"picker_shape center_index = %d   min = %f  data_index=%d  cell_count=%d", center_index, min, data_index, [cells count]);
    
    return data_index;
}

- (float)distanceBetween:(CGPoint)p1 and:(CGPoint)p2
{
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
}

@end
