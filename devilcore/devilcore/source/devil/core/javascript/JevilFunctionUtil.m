//
//  JevilFunctionUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/16.
//

#import "JevilFunctionUtil.h"
#import "JevilInstance.h"

@interface JevilFunctionUtil ()

@property (nonatomic, retain) NSMutableDictionary* fs;

@end

@implementation JevilFunctionUtil

+(JevilFunctionUtil*)sharedInstance{
    static JevilFunctionUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JevilFunctionUtil alloc] init];
        sharedInstance.fs = [@{} mutableCopy];
    });
    
    return sharedInstance;
}

-(void)registFunction:(JSValue*)function{
    NSString* vcKey = [NSString stringWithFormat:@"%ul", [JevilInstance currentInstance].vc];
    NSString* functionKey = [NSString stringWithFormat:@"%ul", function];
    
    if(self.fs[vcKey] == nil) {
        self.fs[vcKey] = [@{} mutableCopy];
    }
    
    self.fs[vcKey][functionKey] = @"fff";
}

-(void)callFunction:(JSValue*)function params:(id)params{
    NSString* vcKey = [NSString stringWithFormat:@"%ul", [JevilInstance currentInstance].vc];
    NSString* functionKey = [NSString stringWithFormat:@"%ul", function];
    
    if(self.fs[vcKey] && self.fs[vcKey][functionKey])
       [function callWithArguments:params];
}

-(void)clear {
    
}

@end
