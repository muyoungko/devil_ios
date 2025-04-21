//
//  WildCardMeta.m
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import "WildCardMeta.h"
#import "WildCardUIView.h"
#import "WildCardNextChain.h"
#import "WildCardLayoutPathUnit.h"
#import "WildCardTrigger.h"
#import "WildCardConstructor.h"
#import "WildCardCollectionViewAdapter.h"
#import "ReplaceRuleMarket.h"
#import "ReplaceRuleRepeat.h"

@interface WildCardMeta()
@end

@implementation WildCardMeta

- (id) init {
    self = [super init];
    if (self != nil) {
        self.replaceRules = [[NSMutableArray alloc] init];
        self.generatedViews = [[NSMutableDictionary alloc] init];
        self.triggersByName = [[NSMutableDictionary alloc] init];
        self.nextChain = nil;
        self.nextChainHeaderNodes = nil;
        self.nextChainChildNodes = nil;
        self.layoutPath = nil;
        self.gravityNodes = nil;
        self.parentMeta = nil;
        self.forRetain = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addNextChain:(UIView*)prev next:(UIView*)next margin:(int)margin nextType:(int)nextType depth:(int)depth
{
    //NSLog(@"addNextChain : %@ - %@", ((WildCardUIView*)prev).name, ((WildCardUIView*)next).name);
    [self initNextChainIfNeed];
    
    NSString* prevKey = [NSString stringWithFormat:@"%lx", (long)prev];
    NSString* nextKey = [NSString stringWithFormat:@"%lx", (long)next];
    
    NSMutableArray* chain = [_nextChain objectForKey: prevKey];
    if(chain == nil)
    {
        chain = [[NSMutableArray alloc] init];
        [_nextChain setObject:chain forKey:prevKey];
    }
    
    WildCardNextChain *node = [[WildCardNextChain alloc] init];
    node.view = next;
    node.margin = margin;
    node.nextType = nextType;
    [chain addObject:node];

    [_nextChainChildNodes setObject:next forKey:nextKey];
    [_nextChainHeaderNodes removeObjectForKey:nextKey];

    if([_nextChainChildNodes objectForKey:prevKey] == nil)
       [_nextChainHeaderNodes setObject:prev forKey:prevKey];
    
    /*
     if there is change on layout, it should be recreated whole layout path again when "requestLayout" function called
     */
    _layoutPath = nil;
}

-(void)initNextChainIfNeed
{
    if(_nextChain == nil)
    {
        _nextChain = [[NSMutableDictionary alloc] init];
        _nextChainHeaderNodes = [[NSMutableDictionary alloc] init];
        _nextChainChildNodes = [[NSMutableDictionary alloc] init];
    }
}

-(void) doAllActionOfTrigger:(NSString*)triggerType node:(NSString*)nodeName
{
    if(_triggersByName[nodeName] != nil)
    {
        NSMutableDictionary* a = _triggersByName[nodeName];
        if(a[triggerType] != nil)
        {
            WildCardTrigger* t = a[triggerType];
            [t doAllAction];
        }
    }
}

/**
 match_parent에 대한 구현
 child1~child Match Parent(이하child M) ~ child N
 스캐치 UI에서 child N이 최상단에 있으므로 child N부터 역순으로 그린다
 child N이 먼저 자리를 차지하고 남은 영역을 match_parent Node가 차지한다
 
 현재 상태 :
  headers, wrapContentNodes, gravityNodes 를보고 layout순서를 정한다.
  가장 먼저
 -
 */
-(void) requestLayout
{
    double s = [[NSDate date] timeIntervalSince1970];
    if(_layoutPath == nil)
    {
        [self createLayoutPath];
    }
    
//    NSLog(@"%@", self.correspondData[@"text"]);
//    NSLog(@"%@", _layoutPath);
          
    for(int i=0;i<[_layoutPath count];i++)
    {
        WildCardLayoutPathUnit *unit = [_layoutPath objectAtIndex:i];
        if(unit.type == WC_LAYOUT_TYPE_WRAP_CONTENT)
        {
            WildCardUIView* headerView = [_wrapContentNodes objectForKey:unit.viewKey];
            if(!headerView.frameUpdateAvoid)
                [self wrapContent:headerView];
            if(self.requestLayoutDebug) NSLog(@"path(%d) wrapContent - %@ (%f,%f) (%f-%f)" ,unit.depth, headerView.name, headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height);
            //NSLog(@"path(%d) wrapContent - %@" ,unit.depth, headerView.name);
        }
        else if(unit.type == WC_LAYOUT_TYPE_NEXT_VIEW)
        {
            WildCardUIView* headerView = [_nextChainHeaderNodes objectForKey:unit.viewKey];
            CGSize size = CGSizeMake(0, 0);
            if(self.requestLayoutDebug) NSLog(@"path(%d) nextView - %@",unit.depth, headerView.name);
            if(!headerView.frameUpdateAvoid)
                [self fireOnLayout:headerView offsetX:headerView.frame.origin.x offsetY:headerView.frame.origin.y outSize:size];
        }
        else if(unit.type == WC_LAYOUT_TYPE_GRAVITY_CENTER 
                || unit.type == WC_LAYOUT_TYPE_GRAVITY_VERTICAL_NOT_CENTER
                || unit.type == WC_LAYOUT_TYPE_GRAVITY_HORIZONTAL_NOT_CENTER
                )
        {
            WildCardUIView* headerView = [_gravityNodes objectForKey:unit.viewKey];
            if(self.requestLayoutDebug) NSLog(@"path(%d) gravity - %@", unit.depth, headerView.name);
            if(!headerView.frameUpdateAvoid)
                [self gravityView:headerView];
        } else if(unit.type == WC_LAYOUT_TYPE_MATCH_PARENT)
        {
            WildCardUIView* headerView = [_matchParentNodes objectForKey:unit.viewKey];
            if(self.requestLayoutDebug) NSLog(@"path(%d) match_parent - %@", unit.depth,headerView.name);
            if(!headerView.frameUpdateAvoid)
                [self matchParentView:headerView];
        } else if(unit.type == WC_LAYOUT_TYPE_FOLLOW_PARENT_WIDTH)
        {
            WildCardUIView* headerView = [_followParentWidthNodes objectForKey:unit.viewKey];
            if(self.requestLayoutDebug) NSLog(@"path(%d) follow_parent_width - %@", unit.depth,headerView.name);
            [self followParentWidth:headerView];
        } else if(unit.type == WC_LAYOUT_TYPE_FOLLOW_PARENT_HEIGHT)
        {
            WildCardUIView* headerView = [_followParentWidthNodes objectForKey:unit.viewKey];
            if(self.requestLayoutDebug) NSLog(@"path(%d) follow_parent_height - %@", unit.depth,headerView.name);
            [self followParentHeight:headerView];
        }
    }
    
    /**
     부모가 wrap_content인 gravity를 한번더 돌려야함
     그래야 부모의 wrap_content 후의 높이가 vcenter  혹은 vbottom에 반영됨
     */
    for(int i=0;i<[_layoutPath count];i++)
    {
        WildCardLayoutPathUnit *unit = [_layoutPath objectAtIndex:i];
        if(unit.type == WC_LAYOUT_TYPE_GRAVITY_CENTER
           || unit.type == WC_LAYOUT_TYPE_GRAVITY_VERTICAL_NOT_CENTER
           || unit.type == WC_LAYOUT_TYPE_GRAVITY_HORIZONTAL_NOT_CENTER
           )
        {
            WildCardUIView* headerView = [_gravityNodes objectForKey:unit.viewKey];
            if(((WildCardUIView*)[headerView superview]).wrap_height) {
                if(self.requestLayoutDebug) NSLog(@"path(%d) gravity - %@", unit.depth, headerView.name);
                if(!headerView.frameUpdateAvoid)
                    [self gravityView:headerView];
            }
        }
    }
}

-(void)initWrapContentIfNeed
{
    if(_wrapContentNodes == nil)
    {
        _wrapContentNodes = [[NSMutableDictionary alloc] init];
    }
}

-(void)addWrapContent:(UIView*)view depth:(int)depth
{
    [self initWrapContentIfNeed];
    NSString* viewKey = [NSString stringWithFormat:@"%lx", (long)view];
    [_wrapContentNodes setObject:view forKey:viewKey];
}

-(void)initMatchParentIfNeed
{
    if(_matchParentNodes == nil)
    {
        _matchParentNodes = [[NSMutableDictionary alloc] init];
    }
}

-(void)addMatchParent:(UIView*)view depth:(int)depth
{
    [self initMatchParentIfNeed];
    NSString* viewKey = [NSString stringWithFormat:@"%lx", (long)view];
    [_matchParentNodes setObject:view forKey:viewKey];
}


-(void)initGravityIfNeed
{
    if(_gravityNodes == nil)
    {
        _gravityNodes = [[NSMutableDictionary alloc] init];
    }
}

-(void)addGravity:(UIView*)view depth:(int)depth
{
    [self initGravityIfNeed];
    NSString* viewKey = [NSString stringWithFormat:@"%lx", (long)view];
    [_gravityNodes setObject:view forKey:viewKey];
}

-(void)addFollowParentWidth:(UIView*)view depth:(int)depth
{
    if(_followParentWidthNodes == nil)
        _followParentWidthNodes = [[NSMutableDictionary alloc] init];
    NSString* viewKey = [NSString stringWithFormat:@"%lx", (long)view];
    [_followParentWidthNodes setObject:view forKey:viewKey];
}

-(void)addFollowParentHeight:(UIView*)view depth:(int)depth
{
    if(_followParentHeightNodes == nil)
        _followParentHeightNodes = [[NSMutableDictionary alloc] init];
    NSString* viewKey = [NSString stringWithFormat:@"%lx", (long)view];
    [_followParentHeightNodes setObject:view forKey:viewKey];
}


-(void)gravityView:(WildCardUIView*)view
{
    WildCardUIView* parent = (WildCardUIView*)[view superview];
    
    int newX = view.frame.origin.x;
    int newY = view.frame.origin.y;
    switch(view.alignment)
    {
        case GRAVITY_RIGHT:
        case GRAVITY_RIGHT_BOTTOM:
        case GRAVITY_RIGHT_TOP:
        case GRAVITY_RIGHT_VCENTER:
            newX = parent.frame.size.width - view.frame.size.width - view.rightMargin;
            break;
            
        case GRAVITY_HORIZONTAL_CENTER:
        case GRAVITY_HCENTER_TOP:
        case GRAVITY_HCENTER_BOTTOM:
        case GRAVITY_CENTER:
            newX = parent.frame.size.width/2 - view.frame.size.width/2 - view.rightMargin/2;
            break;
    }
    
    switch(view.alignment)
    {
        case GRAVITY_BOTTOM:
        case GRAVITY_LEFT_BOTTOM:
        case GRAVITY_HCENTER_BOTTOM:
        case GRAVITY_RIGHT_BOTTOM:
            newY = parent.frame.size.height - view.frame.size.height - view.bottomMargin;
            break;
            
        case GRAVITY_VERTICAL_CENTER:
        case GRAVITY_LEFT_VCENTER:
        case GRAVITY_RIGHT_VCENTER:
        case GRAVITY_CENTER:
            newY = (parent.frame.size.height - view.frame.size.height - view.bottomMargin)/2;
            break;
    }
    
    //NSLog(@"gravity detail - newX, newY = %d %d in parent(%@) size (%d,%d)", (int)newX, (int)newY, parent.name,(int)parent.frame.size.width, (int)parent.frame.size.height);
    view.frame = CGRectMake(newX, newY, view.frame.size.width, view.frame.size.height);
}



-(void) wrapContent:(WildCardUIView*)parent
{
    NSArray* childs = [parent subviews];
    float maxW = 0;
    float maxH = 0;
    
    for(int i=0;i<[childs count];i++)
    { 
        UIView *child = [childs objectAtIndex:i];
        if(child.hidden)
            continue;
        
        BOOL hCenterOrRight = NO;
        BOOL vCenterOrBottom = NO;
        float rightMargin = 0, bottomMargin = 0;
        if([child isKindOfClass:[WildCardUIView class]]) {
            WildCardUIView* vchild = (WildCardUIView*)child;
            if(vchild.follow_width)
                continue;
            
            hCenterOrRight = [WildCardUtil isHCenterOrHRight:vchild.alignment];
            vCenterOrBottom = [WildCardUtil isVCenterOrVBottom:vchild.alignment];
            rightMargin = vchild.rightMargin;
            bottomMargin = vchild.bottomMargin;
        }
        
        float childW = child.frame.origin.x + child.frame.size.width + rightMargin;
        float childH = child.frame.origin.y + child.frame.size.height + bottomMargin;
        if(!hCenterOrRight && maxW < childW)
            maxW = childW;
        if(!vCenterOrBottom && maxH < childH)
            maxH = childH;
    }
    
    maxW += parent.paddingRight;
    maxH += parent.paddingBottom;
    
    if(parent.wrap_height && parent.wrap_width)
    {
        parent.frame = CGRectMake(parent.frame.origin.x, parent.frame.origin.y, maxW, maxH);
    }
    else if(parent.wrap_height)
    {
        parent.frame = CGRectMake(parent.frame.origin.x, parent.frame.origin.y, parent.frame.size.width, maxH);
    }
    else if(parent.wrap_width)
    {
        parent.frame = CGRectMake(parent.frame.origin.x, parent.frame.origin.y, maxW, parent.frame.size.height);
    }
    
    //NSString* parentKey = [NSString stringWithFormat:@"%lx", (long)parent];
    //NSLog(@"wrapContent - %@ (%f, %f)" , parent.name, parent.frame.size.width, parent.frame.size.height);
}

-(void) fireOnLayout:(WildCardUIView*)prevView offsetX:(float)offsetX offsetY:(float)offsetY outSize:(CGSize)size
{
    /**
        PREV여부에 따라 사이즈가 다르게 처리되어야한다.
     */
    if(prevView.hidden == YES)
    {
        if(size.width < offsetX)
            size.width = offsetX;
        if(size.height < offsetY)
            size.height = offsetY;
    }
    else
    {
        if(size.width < offsetX + prevView.frame.size.width)
            size.width = offsetX + prevView.frame.size.width;
        if(size.height < offsetY + prevView.frame.size.height)
            size.height = offsetY + prevView.frame.size.height;
    }
    
    NSString* prevKey = [NSString stringWithFormat:@"%lx", (long)prevView];
    
    NSArray* chain = [_nextChain objectForKey:prevKey];
    if(chain == nil)
        return;
    
    for(int i=0;i<[chain count];i++)
    {
        WildCardNextChain* nextNode = [chain objectAtIndex:i];
        
        WildCardUIView* nextView = (WildCardUIView*)nextNode.view;
        float fHNextToMargin = nextNode.margin;
        int nextType = nextNode.nextType;
        float newOffset = 0;
        
        if(nextType == WC_NEXT_TYPE_HORIZONTAL) {
            if (prevView.hidden == YES)
                newOffset = offsetX + (nextView.hidden?0:fHNextToMargin);
            else
                newOffset = offsetX + prevView.frame.size.width + prevView.rightMargin + (nextView.hidden?0:fHNextToMargin);
        }
        else if(nextType == WC_NEXT_TYPE_VERTICAL) {
            //NSLog(@"prev %@ y=%f h=%f", prevView.name, prevView.frame.origin.y, prevView.frame.size.height);
            /**
             2021/10/23 fHNextToMargin 적용여부는 preview hidden여부가 아니라 next hidden여부에 따라 적용 여부가 달라져야한다
             관련 케이스 https://console.deavil.com/#/block/37844916
            */
            if (prevView.hidden == YES)
                newOffset = offsetY + (nextView.hidden?0:fHNextToMargin);
            else
                newOffset = offsetY + prevView.frame.size.height + prevView.bottomMargin + (nextView.hidden?0:fHNextToMargin);
        } else if(nextType == WC_NEXT_TYPE_HORIZONTAL_PREV) {
            if (prevView.hidden == YES)
                newOffset = offsetX - fHNextToMargin - nextView.rightMargin;
            else 
                newOffset = offsetX - nextView.frame.size.width - fHNextToMargin - nextView.rightMargin;
        }
        
        if(nextType == WC_NEXT_TYPE_HORIZONTAL) {
            //NSLog(@"%@ %f %f", nextView.name, newOffset, nextView.frame.origin.y);
            nextView.frame = CGRectMake(newOffset, nextView.frame.origin.y, nextView.frame.size.width, nextView.frame.size.height);
            [self fireOnLayout:nextView offsetX:newOffset offsetY:offsetY outSize:size];
        }
        else if(nextType == WC_NEXT_TYPE_VERTICAL) {
            //NSLog(@"next %@ y=%f height=%f", nextView.name, newOffset, nextView.frame.size.height);
            //[nextView superview].backgroundColor = [UIColor redColor];
            nextView.frame = CGRectMake(nextView.frame.origin.x, newOffset, nextView.frame.size.width, nextView.frame.size.height);
            [self fireOnLayout:nextView offsetX:offsetX offsetY:newOffset outSize:size];
        } else if(nextType == WC_NEXT_TYPE_HORIZONTAL_PREV) {
            //NSLog(@"%@ %f %f", nextView.name, newOffset, nextView.frame.origin.y);
            nextView.frame = CGRectMake(newOffset, nextView.frame.origin.y, nextView.frame.size.width, nextView.frame.size.height);
            [self fireOnLayout:nextView offsetX:newOffset offsetY:offsetY outSize:size];
        }
    }
}

-(void)followParentWidth:(WildCardUIView*)view {
    UIView* parent = [view superview];
    NSLog(@"follow parent width %@ %f", ((WildCardUIView*)parent).name, parent.frame.size.width);
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, parent.frame.size.width, view.frame.size.height);
}

-(void)followParentHeight:(WildCardUIView*)view {
    UIView* parent = [view superview];
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, parent.frame.size.height);
}

-(void) matchParentView:(WildCardUIView*)view {
    UIView* parent = [view superview];
    id childs = [[view superview] subviews];
    int maxTopY = 0;
    int minBottomY = parent.frame.size.height;
    
    /**
     Sketch의 노드 순서는 위에서부터고 실제 add되는건 아래서부터다
     따라서 순차적으로 하단을 구하고 그다음에 상단을 구한다
     */
    BOOL bottom = true;
    for(UIView* c in childs) {
        if(c == view){
            bottom = false;
            continue;
        }
        if(bottom) {
            if(minBottomY > c.frame.origin.y )
                minBottomY = c.frame.origin.y;
        } else {
            if(maxTopY < c.frame.origin.y + c.frame.size.height )
                maxTopY = c.frame.origin.y + c.frame.size.height;
        }
    }
    
    view.frame = CGRectMake(view.frame.origin.x, maxTopY, view.frame.size.width, minBottomY-maxTopY);
}

-(void)createLayoutPath
{
    NSMutableArray* temp = [[NSMutableArray alloc] init];
    
    if(_nextChainHeaderNodes != nil)
    {
        NSArray* keys = [_nextChainHeaderNodes allKeys];
        for(int i=0;i<[keys count];i++)
        {
            WildCardUIView* headerView = (WildCardUIView*)[_nextChainHeaderNodes objectForKey:[keys objectAtIndex:i]];
            
            NSString* headerViewKey = [NSString stringWithFormat:@"%lx", (long)headerView];
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:WC_LAYOUT_TYPE_NEXT_VIEW depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    
    if(_wrapContentNodes != nil)
    {
        NSArray* keys = [_wrapContentNodes allKeys];
        for(int i=0;i<[keys count];i++)
        {
            WildCardUIView* headerView = (WildCardUIView*)[_wrapContentNodes objectForKey:[keys objectAtIndex:i]];
            
            NSString* headerViewKey = [NSString stringWithFormat:@"%lx", (long)headerView];
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:WC_LAYOUT_TYPE_WRAP_CONTENT depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    
    if(_gravityNodes != nil)
    {
        NSArray* keys = [_gravityNodes allKeys];
        for(int i=0;i<[keys count];i++)
        {
            WildCardUIView* headerView = (WildCardUIView*)[_gravityNodes objectForKey:[keys objectAtIndex:i]];
            
            NSString* headerViewKey = [NSString stringWithFormat:@"%lx", (long)headerView];
            int layout_type = WC_LAYOUT_TYPE_GRAVITY_CENTER;
            switch(headerView.alignment) {
                case GRAVITY_BOTTOM:
                case GRAVITY_LEFT_BOTTOM:
                    layout_type = WC_LAYOUT_TYPE_GRAVITY_VERTICAL_NOT_CENTER;
                    break;
                case GRAVITY_VERTICAL_CENTER:
                case GRAVITY_HORIZONTAL_CENTER:
                case GRAVITY_CENTER:
                case GRAVITY_LEFT_VCENTER:
                case GRAVITY_RIGHT_VCENTER:
                case GRAVITY_HCENTER_TOP:
                case GRAVITY_HCENTER_BOTTOM:
                    layout_type = WC_LAYOUT_TYPE_GRAVITY_CENTER;
                    break;
                case GRAVITY_RIGHT:
                case GRAVITY_RIGHT_TOP:
                case GRAVITY_RIGHT_BOTTOM:
                    layout_type = WC_LAYOUT_TYPE_GRAVITY_HORIZONTAL_NOT_CENTER;
                    break;
                default:
                    break;
            }
            
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:layout_type depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    
    if(_matchParentNodes != nil)
    {
        NSArray* keys = [_matchParentNodes allKeys];
        for(int i=0;i<[keys count];i++)
        {
            WildCardUIView* headerView = (WildCardUIView*)[_matchParentNodes objectForKey:[keys objectAtIndex:i]];
            
            NSString* headerViewKey = [NSString stringWithFormat:@"%lx", (long)headerView];
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:WC_LAYOUT_TYPE_MATCH_PARENT depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    
    if(_followParentWidthNodes != nil) {
        NSArray* keys = [_followParentWidthNodes allKeys];
        for(int i=0;i<[keys count];i++) {
            WildCardUIView* headerView = (WildCardUIView*)[_followParentWidthNodes objectForKey:[keys objectAtIndex:i]];
            
            NSString* headerViewKey = [NSString stringWithFormat:@"%lx", (long)headerView];
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:WC_LAYOUT_TYPE_FOLLOW_PARENT_WIDTH depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    if(_followParentHeightNodes != nil) {
        NSArray* keys = [_followParentHeightNodes allKeys];
        for(int i=0;i<[keys count];i++) {
            WildCardUIView* headerView = (WildCardUIView*)[_followParentHeightNodes objectForKey:[keys objectAtIndex:i]];
            
            NSString* headerViewKey = [NSString stringWithFormat:@"%lx", (long)headerView];
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:WC_LAYOUT_TYPE_FOLLOW_PARENT_HEIGHT depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    
    /**
     깊은 depth - wrap_content가 우선
     
     경우 1 - next_to가 결정된 후 prev가 gravity로 위치 이동해버린다 이경우 같은 depth라면 gravity를 먼저 하고 next를 해야한다 (채팅 메세지 right)
     "<WildCardLayoutPathUnit: 0x300fc28a0> type:WRAP_CONTENT depth:4 chat_text",
     "<WildCardLayoutPathUnit: 0x300fc2900> type:WRAP_CONTENT depth:3 chat_text_group_right",
     "<WildCardLayoutPathUnit: 0x300fc2840> type:NEXT_VIEW depth:3 chat_text_group_right",
     "<WildCardLayoutPathUnit: 0x300fc28c0> type:WRAP_CONTENT depth:2 chat_message_right",
     "<WildCardLayoutPathUnit: 0x300fc2940> type:GRAVITY depth:3 chat_text_group_right",
     "<WildCardLayoutPathUnit: 0x300fc28e0> type:GRAVITY depth:3 chat_message_info"
     이 때 WRAP_CONTENT depth:3 chat_text_group_right" 와 type:GRAVITY depth:3 chat_text_group_right"가 바껴야한다.
     원래 GRAVITY는 depth무관 최후순위인데 그 이유는 부모의 크기가 결정되어야만 center를 결정할 수 있기 때문이다
     하지만 이경우로 봤을때 GRAVITY가 right 혹은 left인경우만 부모 wrap_content보다 앞서야한다
     
     경우 2 - 부모가 wrap_height이고 자식이 valign bottom 혹은 valige center이면 부모의 크기가 먼저 결정된 다음 gravity가 적용되어야한다. 이경우 무조건적인 depth가 적용되선 안된다
     경우 4 - WrapContent Center 후에 우측에 화살표가 붙는 경우, 이경우 같은 depth gravity가 먼저 적용해야한다  https://console.deavil.com/#/block/56548847
     경우 5 - Gravity로 우측 할인가가 붙고 그 다음에 WrapContent된 오리지널 가격이 그 우측에 이어 붙는경우 https://console.deavil.com/#/block/56545468
     
     TODO 가로 세로 WRAP_CONTENT 와 상하 GRAVITY_NOT_CENTER 구분해서 각각에 정렬해야함
     */
    
    _layoutPath = [temp sortedArrayUsingComparator:^NSComparisonResult(WildCardLayoutPathUnit* a, WildCardLayoutPathUnit* b) {
        
        int r = 0;
        int av = [self typeToValue:a];
        int bv = [self typeToValue:b];
        r += (bv - av) * 10;
        r += (b.depth - a.depth) * 100;
        return r;
    }];
    
//    if([_layoutPath count] > 2)
//        NSLog(@"%@", _layoutPath);
}

-(int)typeToValue:(WildCardLayoutPathUnit*)a {
    if(a.type == WC_LAYOUT_TYPE_WRAP_CONTENT)
        return 5;
    else if(a.type == WC_LAYOUT_TYPE_FOLLOW_PARENT_WIDTH || a.type == WC_LAYOUT_TYPE_FOLLOW_PARENT_HEIGHT)
        return -100000;
    else if(a.type == WC_LAYOUT_TYPE_GRAVITY_CENTER || a.type == WC_LAYOUT_TYPE_GRAVITY_VERTICAL_NOT_CENTER)
        return -1000;
    else if(a.type == WC_LAYOUT_TYPE_GRAVITY_HORIZONTAL_NOT_CENTER)
        return 4;
    else if(a.type == WC_LAYOUT_TYPE_MATCH_PARENT)
        return 2;
    else if(a.type == WC_LAYOUT_TYPE_NEXT_VIEW)
        return 3;
    return 0;
}

-(void)addTriggerAction:(WildCardTrigger*)trigger
{
    NSMutableDictionary* triggers = _triggersByName[trigger.nodeName];
    if(triggers == nil)
    {
        triggers = [[NSMutableDictionary alloc] init];
        _triggersByName[trigger.nodeName] = triggers;
    }
    
    if(triggers[trigger.type] == nil)
    {
        triggers[trigger.type] = trigger;
    }
    else
    {
        [triggers[trigger.type] addActions:trigger.actions];
    }
}

-(UILabel*)getTextView:(NSString*)name{
    return [[self getView:name] subviews][0];
}

-(UIImageView*)getImageView:(NSString*)name{
    return [[self getView:name] subviews][0];
}

-(UIView*)getView:(NSString*)name{
    id r = self.generatedViews[name];
    if(!r) {
        for(WildCardMeta* childMeta in self.childMetas) {
            r = [childMeta getView:name];
            if(r)
                return r;
        }
    }
    return r;
}

-(UICollectionView*)getList:(NSString*)name{
    return [[self getView:name] subviews][0];
}

-(UITextField*)getInput:(NSString*)name{
    return [[self getView:name] subviews][0];
}

-(void)update {
    [WildCardConstructor applyRuleMeta:self withData:self.correspondData];
}

-(void)viewPagerMove:(NSString*)vp to:(int)distance{
    WildCardUIView* vv = self.generatedViews[vp];
    UICollectionView* c = [vv subviews][0];
    WildCardCollectionViewAdapter* adapter = (WildCardCollectionViewAdapter*)c.delegate;
    
    int count = [adapter getCount];
    int index = [adapter getIndex];
    index += distance;
    if(index >= count || index < 0)
        return;
   
    [adapter scrollToIndex:index view:c];
}

-(void)created{
    for(id rule in self.replaceRules) {
        if([rule isKindOfClass:[ReplaceRuleMarket class]]) {
            [((ReplaceRuleMarket*)rule).marketComponent created];
        }
    }
}

-(void)paused{
    for(id rule in self.replaceRules) {
        if([rule isKindOfClass:[ReplaceRuleMarket class]]) {
            [((ReplaceRuleMarket*)rule).marketComponent pause];
        }
    }
}

-(void)resumed{
    for(id rule in self.replaceRules) {
        if([rule isKindOfClass:[ReplaceRuleMarket class]]) {
            [((ReplaceRuleMarket*)rule).marketComponent resume];
        }
    }
}

-(void)destroy{
    for(id rule in self.replaceRules) {
        if([rule isKindOfClass:[ReplaceRuleMarket class]]) {
            [((ReplaceRuleMarket*)rule).marketComponent destroy];
        }
    }
}

-(void)keypad:(BOOL)up :(CGRect)keyboardRect{
    for(id rule in self.replaceRules) {
        if([rule isKindOfClass:[ReplaceRuleMarket class]]) {
            [((ReplaceRuleMarket*)rule).marketComponent keypad:up :keyboardRect];
        }
    }
}


@end
