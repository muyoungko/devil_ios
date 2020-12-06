//
//  WildCardScreenTableView.m
//  cjiot
//
//  Created by Mu Young Ko on 2018. 11. 17..
//  Copyright © 2018년 sbs cnbc. All rights reserved.
//

#import "WildCardScreenTableView.h"
#import "WildCardConstructor.h"
#import "MappingSyntaxInterpreter.h"

@implementation WildCardScreenTableView

-(id)initWithScreenName:(NSString*)screenKey
{
    self = [super init];
    if(self)
    {
        self.screenKey = screenKey;
        self.dataSource = self;
        self.delegate = self;
        self.wildCardConstructorInstanceDelegate = nil;
        self.data = @{};
        self.bounces = NO;
        
        self.contentInset = UIEdgeInsetsZero;
        //        self.separatorColor = [UIColor redColor];
        //        self.separatorInset = UIEdgeInsetsMake(0, 0, 20, 414);
        
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.alwaysBounceVertical = NO;
        self.list = [[NSMutableArray alloc] init];
        self.listData = [[NSMutableArray alloc] init];
        
        self.ifList = [[WildCardConstructor sharedInstance] getScreenIfList:_screenKey];
        for(int i=0;i<[_ifList count];i++)
        {
            NSDictionary *ifListItem = [_ifList objectAtIndex:i];
            NSString *key = [[ifListItem objectForKey:@"block_id"] stringValue];
            NSString *type = [ifListItem objectForKey:@"type"];
            
            if([type isEqualToString:@"sketch"] || [type isEqualToString:@"list"]){
                [self registerClass:[UITableViewCell class] forCellReuseIdentifier:key];
            } else if([type isEqualToString:@"combinedList"]){
                NSString* key1 = ifListItem[@"key"];
                NSString* key2 = ifListItem[@"key2"];
                NSString* key3 = ifListItem[@"key3"];
                if(key1 != nil)
                    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:key];
                if(key2 != nil)
                    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:key2];
                if(key3 != nil)
                    [self registerClass:[UITableViewCell class] forCellReuseIdentifier:key3];
            }
        }
    }
    return self;
}

-(void)dragEnable:(BOOL)enable{
    if (@available(iOS 11.0, *)) {
        self.dragInteractionEnabled = enable;
        if(enable){
            self.dragDelegate = self;
            self.dropDelegate = self;
        }
    }
}

-(void)reloadData
{
    [_list removeAllObjects];
    [_listData removeAllObjects];
    for(int i=0;i<[_ifList count];i++)
    {
        NSDictionary *ifListItem = [_ifList objectAtIndex:i];
        NSString *key = [[ifListItem objectForKey:@"block_id"] stringValue];
        NSString *ifCondition = [ifListItem objectForKey:@"ifcondition"];
        NSString *type = [ifListItem objectForKey:@"type"];
        
        if([type isEqualToString:@"sketch"])
        {
            if(ifCondition == nil
               || [ifCondition isEqualToString:@""]
               || [MappingSyntaxInterpreter ifexpression:ifCondition data:_data])
            {
                [_list addObject:key];
                [_listData addObject:_data];
            }
        } else if([type isEqualToString:@"list"]) {
            NSString *targetArray = [ifListItem objectForKey:@"targetArray"];
            NSMutableArray* array = (NSMutableArray*) [MappingSyntaxInterpreter getJsonWithPath:_data :targetArray];
            for(int j=0;j<[array count];j++)
            {
                NSMutableDictionary* thisArray = array[j];
                if(ifCondition == nil
                   || [ifCondition isEqualToString:@""]
                   || [MappingSyntaxInterpreter ifexpression:ifCondition data:thisArray])
                {
                    [_list addObject:key];
                    [_listData addObject:thisArray];
                }
            }
        } else if([type isEqualToString:@"combinedList"]) {
            NSString *targetArray = [ifListItem objectForKey:@"targetArray"];
            NSMutableArray* array = (NSMutableArray*) [MappingSyntaxInterpreter getJsonWithPath:_data :targetArray];
            NSString* key1 = ifListItem[@"key"];
            NSString* key2 = ifListItem[@"key2"];
            NSString* key3 = ifListItem[@"key3"];
            NSString* ifCondition1 = ifListItem[@"ifcondition"];
            NSString* ifCondition2 = ifListItem[@"ifcondition2"];
            NSString* ifCondition3 = ifListItem[@"ifcondition3"];
            
            for(int j=0;j<[array count];j++)
            {
                NSMutableDictionary* thisArray = array[j];
                if(ifCondition1 == nil
                   || [ifCondition1 isEqualToString:@""]
                   || [MappingSyntaxInterpreter ifexpression:ifCondition1 data:thisArray])
                {
                    [_list addObject:key1];
                    [_listData addObject:thisArray];
                }
                else if(ifCondition2 == nil
                        || [ifCondition2 isEqualToString:@""]
                        || [MappingSyntaxInterpreter ifexpression:ifCondition2 data:thisArray])
                {
                    [_list addObject:key2];
                    [_listData addObject:thisArray];
                }
                else if(ifCondition3 == nil
                        || [ifCondition3 isEqualToString:@""]
                        || [MappingSyntaxInterpreter ifexpression:ifCondition3 data:thisArray])
                {
                    [_list addObject:key3];
                    [_listData addObject:thisArray];
                }
            }
        }
    }
    [super reloadData];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_list count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* key = [_list objectAtIndex:[indexPath row]];
    NSMutableDictionary* item = [_listData objectAtIndex:[indexPath row]];
    NSMutableDictionary* cj = [[WildCardConstructor sharedInstance] getBlockJson:key];
    float height = [WildCardConstructor mesureHeight:cj data:item];
    
    //NSLog(@"h %d %f", [indexPath row], height);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* key = [_list objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:key forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    //NSLog(@"c %d", [indexPath row]);
    
    @try{
        if([[[[cell subviews] objectAtIndex:0] subviews] count] == 0)
        {
            NSMutableDictionary* cj = [[WildCardConstructor sharedInstance] getBlockJson:key];
            WildCardUIView* core = [WildCardConstructor constructLayer:nil withLayer:cj];
            [[[cell subviews] objectAtIndex:0] addSubview:core];
            core.meta.wildCardConstructorInstanceDelegate = self;
        }
        
        
        WildCardUIView *v = [[[[cell subviews] objectAtIndex:0] subviews] objectAtIndex:0];
        [WildCardConstructor applyRule:v withData:[_listData objectAtIndex:[indexPath row]]];
        
        if(self.tableViewDelegate != nil)
            [self.tableViewDelegate cellUpdated:[indexPath row] view:v];
        
    }
    @catch(NSException * e){
        NSLog(@"%@",e);
    }
    
    
    return cell;
}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node
{
    if([@"reloadAll" isEqualToString:functionName])
    {
        [self reloadData];
        return true;
    }
    else if(_wildCardConstructorInstanceDelegate != nil)
    {
        BOOL consume = [_wildCardConstructorInstanceDelegate onInstanceCustomAction:meta function:functionName args:args view:node];
        
        if(consume)
            return true;
    }
    return false;
}







- (void)tableView:(UITableView *)tableView dragSessionWillBegin:(id<UIDragSession>)session API_AVAILABLE(ios(11.0)){
}

- (void)tableView:(UITableView *)tableView dragSessionDidEnd:(id<UIDragSession>)session API_AVAILABLE(ios(11.0)){
}
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)){
    NSMutableArray<UIDragItem *>* r = [[NSMutableArray alloc] init];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:[NSString stringWithFormat:@"%ld", (long)indexPath.row] ];
    UIDragItem* dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    dragItem.localObject = indexPath;
    [r addObject:dragItem];
    return r;
}

- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath API_AVAILABLE(ios(11.0)){
    if(tableView.hasActiveDrag)
        return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent: UITableViewDropIntentInsertAtDestinationIndexPath];
    else
        return [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden];
}

- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator API_AVAILABLE(ios(11.0)){
    
    UIDragItem* dragItem = coordinator.session.items[0];
    NSIndexPath* startIndex = dragItem.localObject;
    
    if(_tableViewDelegate != nil && [_tableViewDelegate respondsToSelector:@selector(dragDrop:to:)]){
        [_tableViewDelegate dragDrop:(int)startIndex.row to:(int)coordinator.destinationIndexPath.row];
    }
}









@end
