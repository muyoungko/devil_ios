//
//  DeepLink.m
//  bnbhost
//
//  Created by Mu Young Ko on 2020/06/27.
//  Copyright © 2020 july. All rights reserved.
//

#import "DeepLink.h"
#import "JulyUtil.h"

@interface DeepLink()

@property (nonatomic, retain) NSString* url;

@end

@implementation DeepLink

+(DeepLink*)sharedInstance{
    static DeepLink *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DeepLink alloc] init];
    });
    return sharedInstance;
}

-(void)reserveDeepLink:(NSString*)url{
    self.url = url;
}

-(void)consumeDeepLink{
    if(self.url != nil){
        NSURL *url = [NSURL URLWithString:self.url];
    
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [url.query componentsSeparatedByString:@"&"]) {
          NSArray *elts = [param componentsSeparatedByString:@"="];
          if([elts count] < 2) continue;
          
          NSString* value = [[elts lastObject] stringByReplacingOccurrencesOfString:@"+" withString:@" "];
          value = urldecode(value); 
          [params setObject:value forKey:[elts firstObject]];
        }
        
        if([url.path isEqualToString:@"/share"]){
            
        }
    }
}

@end
