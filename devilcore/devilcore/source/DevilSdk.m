//
//  DevilSdk.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/11/22.
//

#import "DevilSdk.h"
#import "devilcore.h"
#import "DevilController.h"

@interface DevilSdk()

@property (nonatomic, retain) id sharedCustomJevilList;

@end

@implementation DevilSdk

+(DevilSdk*)sharedInstance{
    static DevilSdk *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DevilSdk alloc] init];
    });
    return sharedInstance;
}

+(void)start:(NSString*)project_id viewController:(UIViewController*)vc complete:(void (^)(BOOL res))callback{
    [[WildCardConstructor sharedInstance:project_id] initWithOnlineOnComplete:^(BOOL success) {
        [[NSUserDefaults standardUserDefaults] setObject:project_id forKey:@"PROJECT_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DevilController* d = [[DevilController alloc] init];
        NSString* firstScreenId = [[WildCardConstructor sharedInstance] getFirstScreenId];
        d.screenId = firstScreenId; 
        [vc.navigationController pushViewController:d animated:YES];
        callback(success);
    }];
}

-(id)getCustomJevil{
    if(self.sharedCustomJevilList == nil)
        self.sharedCustomJevilList = [@[] mutableCopy];
    return self.sharedCustomJevilList;
}

-(void)addCustomJevil:(Class)a{
    if(self.sharedCustomJevilList == nil)
        self.sharedCustomJevilList = [@[] mutableCopy];
    [self.sharedCustomJevilList addObject:a];
}

-(void)registScreenController:(NSString*)screenName class:(Class)class {
    if(self.registeredClass == nil)
        self.registeredClass = [@{} mutableCopy];
    self.registeredClass[screenName] = class;
}

-(Class)getRegisteredScreenClassOrDevil:(NSString*)screenName {
    Class r = self.registeredClass[screenName];
    if(r != nil)
        return r;
    return [DevilController class];
}

@end
