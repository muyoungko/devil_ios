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

@implementation WildCardMeta
- (id) init
{
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
    }
    return self;
}

-(void)addNextChain:(UIView*)prev next:(UIView*)next margin:(int)margin horizontal:(BOOL)horizontal depth:(int)depth
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
    node.horizontal = horizontal;
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

-(void) requestLayout
{
    double s = [[NSDate date] timeIntervalSince1970];
    if(_layoutPath == nil)
    {
        [self createLayoutPath];
    }
    
    for(int i=0;i<[_layoutPath count];i++)
    {
        WildCardLayoutPathUnit *unit = [_layoutPath objectAtIndex:i];
        if(unit.type == WC_LAYOUT_TYPE_WRAP_CONTENT)
        {
            WildCardUIView* headerView = [_wrapContentNodes objectForKey:unit.viewKey];
            [self wrapContent:headerView];
            //NSLog(@"path(%d) wrapContent - %@ (%f,%f) (%f-%f)" ,unit.depth, headerView.name, headerView.frame.origin.x, headerView.frame.origin.y, headerView.frame.size.width, headerView.frame.size.height);
        }
        else if(unit.type == WC_LAYOUT_TYPE_NEXT_VIEW)
        {
            WildCardUIView* headerView = [_nextChainHeaderNodes objectForKey:unit.viewKey];
            CGSize size = CGSizeMake(0, 0);
            //NSLog(@"path(%d) nextView - %@",unit.depth, headerView.name);
            [self fireOnLayout:headerView offsetX:headerView.frame.origin.x offsetY:headerView.frame.origin.y outSize:size];
        }
        else if(unit.type == WC_LAYOUT_TYPE_GRAVITY)
        {
            WildCardUIView* headerView = [_gravityNodes objectForKey:unit.viewKey];
            //NSLog(@"path(%d) gravity - %@", unit.depth,headerView.name);
            [self gravityView:headerView];
        }
    }
    
    double e = [[NSDate date] timeIntervalSince1970];
    //NSLog(@"RequestLayout time - %f", (e-s));
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

-(void) gravityView:(WildCardUIView*)view
{
    WildCardUIView* parent = (WildCardUIView*)[view superview];
    
    //NSLog(@"gravity - %@",view.name);
    
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
    
    view.frame = CGRectMake(newX, newY, view.frame.size.width, view.frame.size.height);
}

-(void) wrapContent:(WildCardUIView*)parent
{
    NSArray* childs = [parent subviews];
    int maxW = 0;
    int maxH = 0;
    for(int i=0;i<[childs count];i++)
    {
        UIView *child = [childs objectAtIndex:i];
        //TODO check childs aligment is right or bottom
        if(!child.hidden)
        {
            int childW = child.frame.origin.x + child.frame.size.width;
            int childH = child.frame.origin.y + child.frame.size.height;
            if(maxW < childW)
                maxW = childW;
            if(maxH < childH)
                maxH = childH;
        }
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
    
    NSString* parentKey = [NSString stringWithFormat:@"%lx", (long)parent];
    //NSLog(@"wrapContent - %@ (%f, %f)" , parent.name, parent.frame.size.width, parent.frame.size.height);
}

-(void) fireOnLayout:(WildCardUIView*)prevView offsetX:(float)offsetX offsetY:(float)offsetY outSize:(CGSize)size
{
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
        BOOL horizontal = nextNode.horizontal;
        float newOffset = 0;
        if(horizontal) {
            if (prevView.hidden == YES)
                newOffset = offsetX + fHNextToMargin;
            else
                newOffset = offsetX + prevView.frame.size.width + prevView.rightMargin + fHNextToMargin;
        }
        else {
            //NSLog(@"%@ %f %f", prevView.name, prevView.frame.size.width, prevView.frame.size.height);
            if (prevView.hidden == YES)
                newOffset = offsetY + fHNextToMargin;
            else
                newOffset = offsetY + prevView.frame.size.height + prevView.bottomMargin +fHNextToMargin;
        }
        if(horizontal) {
            //NSLog(@"%@ %f %f", nextView.name, newOffset, nextView.frame.origin.y);
            nextView.frame = CGRectMake(newOffset, nextView.frame.origin.y, nextView.frame.size.width, nextView.frame.size.height);
            [self fireOnLayout:nextView offsetX:newOffset offsetY:offsetY outSize:size];
        }
        else
        {
            //NSLog(@"%@ y=%f parentH=%f", nextView.name, newOffset, [nextView superview].frame.size.height);
            //[nextView superview].backgroundColor = [UIColor redColor];
            nextView.frame = CGRectMake(nextView.frame.origin.x, newOffset, nextView.frame.size.width, nextView.frame.size.height);
            [self fireOnLayout:nextView offsetX:offsetX offsetY:newOffset outSize:size];
        }
    }
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
            [temp addObject:[[WildCardLayoutPathUnit alloc] initWithType:WC_LAYOUT_TYPE_GRAVITY depth:headerView.depth viewKey:headerViewKey viewName:headerView.name]];
        }
    }
    
    _layoutPath = [temp sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        WildCardLayoutPathUnit* aa = (WildCardLayoutPathUnit*)a;
        WildCardLayoutPathUnit* bb = (WildCardLayoutPathUnit*)b;
        
        if(aa.type == WC_LAYOUT_TYPE_GRAVITY)
            return true;
        if(bb.type == WC_LAYOUT_TYPE_GRAVITY)
            return false;
        
        if(aa.depth < bb.depth)
            return true;
        else if(aa.depth > bb.depth)
            return false;
        else
        {
            if(aa.type == bb.type)
                return false;
            else{
                if(bb.type == WC_LAYOUT_TYPE_WRAP_CONTENT)
                    return true;
                if(bb.type == WC_LAYOUT_TYPE_NEXT_VIEW)
                    return true;
                
                return false;
            }
        }
    }];
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
    return [self.generatedViews[name] subviews][0];
}

-(UIImageView*)getImageView:(NSString*)name{
    return [self.generatedViews[name] subviews][0];
}

-(UIView*)getView:(NSString*)name{
    return self.generatedViews[name];
}

-(UITextField*)getInput:(NSString*)name{
    return [self.generatedViews[name] subviews][0];
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
@end
