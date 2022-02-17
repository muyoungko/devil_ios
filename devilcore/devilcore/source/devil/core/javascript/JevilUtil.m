//
//  JevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/30.
//

#import "JevilUtil.h"
#import "JevilInstance.h"

@implementation JevilUtil

+(void)sync:(NSMutableDictionary*)src :(NSMutableDictionary*)dest {
    [self sync:src :dest :0 :0];
}

+(void)sync:(NSMutableDictionary*)src :(NSMutableDictionary*)dest :(int)depth :(int)subindex {
    id h = [@{} mutableCopy];
    id dstKs = [dest allKeys];
    for(id dstK in dstKs){
        h[dstK] = dstK;
    }
    
    id srcKs = [src allKeys];
    for(id srcK in srcKs){
        h[srcK] = srcK;
        [h removeObjectForKey:srcK];
        id srcValue = src[srcK];
        if([[srcValue class] isKindOfClass: [NSDictionary class]] || [[srcValue class] isSubclassOfClass:[NSDictionary class]]){
            //NSLog(@"%@srcK - %@ %d", [[NSString string] stringByPaddingToLength: depth withString: @" " startingAtIndex: 0], srcK , subindex);
            if(dest[srcK] == nil || dest[srcK] == [NSNull null])
                dest[srcK] = [@{} mutableCopy];
            [JevilUtil sync:srcValue :dest[srcK] :depth+1 :0];
        } else if([srcValue isKindOfClass:[NSArray class]] ){
            //NSLog(@"%@srcK - %@ %d", [[NSString string] stringByPaddingToLength: depth withString: @" " startingAtIndex: 0], srcK , subindex);
            if(dest[srcK] == nil || dest[srcK] == [NSNull null] || ![dest[srcK] isKindOfClass:[NSArray class]] )
                dest[srcK] = [@[] mutableCopy];
            [JevilUtil syncList:srcValue :dest[srcK] :depth :subindex];
        } else {
            //NSLog(@"%@srcK - %@ %d %@", [[NSString string] stringByPaddingToLength: depth withString: @" " startingAtIndex: 0], srcK , subindex, srcValue);
            dest[srcK] = srcValue;
        }
    }
    
    id hKs = [h allKeys];
    for(id hK in hKs){
        [dest removeObjectForKey:hK];
    }
}

+(void)syncList:(NSMutableArray*)src :(NSMutableArray*)dest :(int)depth :(int)subindex {
    NSUInteger srcLen = [src count];
    NSUInteger destLen = [dest count];
    
    if(srcLen > 0 && (
                      [src[0] isKindOfClass:[NSString class]] ||
                      [src[0] isKindOfClass:[NSNumber class]]
                      ) ){
        [dest removeAllObjects];
        [dest addObjectsFromArray:src];
    } else {
        for(int i=0;i<srcLen && i<destLen;i++){
            
//            id data = [JevilInstance currentInstance].data;
//            id list = [JevilInstance currentInstance].data[@"list"];
//            if(list && [list count] > 1 && list[1][@"category_list"] && i==1 && src[i][@"name"]) {
//                NSLog(@"before %@ / %@", list[1][@"category_list"][1][@"name"], data[@"category_item2"][@"category_list"][1][@"name"]);
//                [JevilUtil sync:src[i] :dest[i]: depth+1:i];
//                NSLog(@"after %@ / %@", list[1][@"category_list"][1][@"name"], data[@"category_item2"][@"category_list"][1][@"name"]);
//            } else
            {
                [JevilUtil sync:src[i] :dest[i]: depth+1:i];
            }
        }
        
        if(srcLen > destLen){
            for(NSUInteger i=destLen;i<srcLen;i++)
                [dest addObject:src[i]];
        } else if(srcLen < destLen){
            for(NSUInteger i=srcLen;i<destLen;i++)
                [dest removeObjectAtIndex:srcLen];
        }
    }
}

+(NSString*)find:(NSMutableDictionary*)data :(NSMutableDictionary*)thisData{
    id outList = [@[] mutableCopy];
    BOOL found = [JevilUtil findCore:data :thisData :outList];
    if(found){
        NSString* r = @"";
        for(NSString* s in outList){
            r = [r stringByAppendingString:s];
        }
        return r;
    }
    return nil;
}

+(BOOL)findCore:(id)node :(id)thisData :(id)outList{
    if(node == thisData){
        return true;
    } else if([[node class] isKindOfClass:[NSDictionary class]] || [[node class] isSubclassOfClass:[NSDictionary class]]){
        id ks = [node allKeys];
        for(id k in ks){
            BOOL r = [JevilUtil findCore:node[k] :thisData :outList];
            if(r){
                [outList insertObject:[NSString stringWithFormat:@".%@",k] atIndex:0];
                return true;
            }
        }
        return false;
    } else if([[node class] isSubclassOfClass:[NSArray class]] || [[node class] isKindOfClass:[NSArray class]]){
        int index = 0;
        for(id child in node){
            BOOL r = [JevilUtil findCore:child :thisData :outList];
            if(r){
                [outList insertObject:[NSString stringWithFormat:@"[%d]",index] atIndex:0];
                return true;
            }
            index++;
        }
    }
    return false;
}
@end
