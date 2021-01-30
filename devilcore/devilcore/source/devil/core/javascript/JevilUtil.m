//
//  JevilUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/30.
//

#import "JevilUtil.h"

@implementation JevilUtil
+(void)sync:(NSMutableDictionary*)src :(NSMutableDictionary*)dest {
    id srcKs = [src allKeys];
    for(id srcK in srcKs){
        if([[src class] isKindOfClass: [NSDictionary class]] || [[src class] isSubclassOfClass:[NSArray class]]){
            if(dest[srcK] == nil)
                dest[srcK] = [@{} mutableCopy];
            [JevilUtil sync:src[srcK] :dest[srcK]];
        } else if([[src class] isKindOfClass:[NSArray class]] || [[src class] isSubclassOfClass:[NSArray class]]){
            if(dest[srcK] == nil)
                dest[srcK] = [@[] mutableCopy];
            [JevilUtil syncList:src[srcK] :dest[srcK]];
        } else {
            dest[srcK] = src[srcK];
        }
    }
}

+(void)syncList:(NSMutableArray*)src :(NSMutableArray*)dest{
    NSUInteger srcLen = [src count];
    NSUInteger destLen = [dest count];
    for(int i=0;i<srcLen && i<destLen;i++){
        [JevilUtil sync:src[i] :dest[i]];
    }
    
    if(srcLen > destLen){
        for(NSUInteger i=destLen;i<srcLen;i++)
            [dest addObject:src[i]];
    } else if(srcLen < destLen){
        for(NSUInteger i=srcLen;i<destLen;i++)
            [dest removeObjectAtIndex:srcLen];
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
