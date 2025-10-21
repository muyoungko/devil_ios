//
//  DevilSdk.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/11/22.
//

#import "DevilSdk.h"
#import "devilcore.h"
#import "DevilController.h"
#import "DevilLang.h"

@interface DevilSdk()

@property (nonatomic, retain) id sharedCustomJevilList;

@end

@implementation DevilSdk

+(DevilSdk*)sharedInstance{
    static DevilSdk *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DevilSdk alloc] init];
        sharedInstance.currentOrientation = UIInterfaceOrientationMaskPortrait;
        sharedInstance.autoChangeOrientation = false;
    });
    return sharedInstance;
}

+(void)start:(NSString*)project_id viewController:(UIViewController*)vc complete:(void (^)(BOOL res))callback{
    [[WildCardConstructor sharedInstance:project_id] initWithOnlineOnComplete:^(BOOL success) {
        [WildCardConstructor sharedInstance:project_id];
        [[NSUserDefaults standardUserDefaults] setObject:project_id forKey:@"PROJECT_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DevilController* d = [[DevilController alloc] init];
        NSString* firstScreenId = [[WildCardConstructor sharedInstance] getFirstScreenId];
        if(firstScreenId) {
            
            [DevilSdk sharedInstance].currentOrientation = [[WildCardConstructor sharedInstance] supportedOrientation:firstScreenId :[Jevil get:@"ORIENTATION"]];
            d.landscape = [DevilUtil shouldLandscape];
            
            d.screenId = firstScreenId;
            [vc.navigationController pushViewController:d animated:YES];
            callback(success);
        } else {
            [Jevil alert:@"Set \"Start Screen\" in Devil console, please"];
            callback(false);
        }
    }];
}

+(void)start:(NSString*)project_id screenId:(NSString*)screen_id controller:(Class)controllerClass viewController:(UIViewController*)vc version:(NSString*)version complete:(void (^)(BOOL res))callback {
    
    void (^init)(BOOL res) = ^(BOOL success) {
        [WildCardConstructor sharedInstance:project_id];
        [[NSUserDefaults standardUserDefaults] setObject:project_id forKey:@"PROJECT_ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DevilController* d = [[controllerClass alloc] init];
        d.screenId = screen_id;
        [vc.navigationController pushViewController:d animated:YES];
        callback(success);
    };
    
    if(version)
        [[WildCardConstructor sharedInstance:project_id] initWithOnlineVersion:version onComplete:init];
    else
        [[WildCardConstructor sharedInstance:project_id] initWithOnlineOnComplete:init];
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

-(UIViewController*)getRegisteredScreenViewController:(NSString*)screenName {
    Class cls = self.registeredClass[screenName];
    if(cls != nil)
        return [[cls alloc] init];
    
    if(self.devilSdkScreenDelegate) {
        UIViewController *r = [self.devilSdkScreenDelegate getScreenViewController:screenName];
        if(r != nil)
            return r;
    }
    return [[DevilController alloc] init];
}

@end
