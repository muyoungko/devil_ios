//
//  DebugLearningView.m
//  devil
//
//  Created by Mu Young Ko on 2022/01/10.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

#import "DebugLearningView.h"
#import "LearningController.h"
#import "Devil.h"

@interface DebugLearningView()
@property (nonatomic, retain) DevilController* vc;
@end

@implementation DebugLearningView

+ (void)constructDebugViewIf:(DevilController*)vc{
    DebugLearningView* debug = [[DebugLearningView alloc] initWithVc:vc];
    [vc.view addSubview:debug];
}


- (instancetype)initWithVc:(DevilController*)vc
{
    self = [super init];
    if (self) {
        self.vc = vc;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        int screenWidth = screenRect.size.width;
        int screenHeight = screenRect.size.height;
        int w = 50;
        
        /**
        TODO viewDidApear에서 해더 여부를 판단해야함
         */
        int headder_height = 0;
        if(!vc.navigationController.isNavigationBarHidden)
            headder_height = vc.navigationController.navigationBar.frame.size.height;
            
        self.frame = CGRectMake(screenWidth-w-30,
                                screenHeight-w-100 - headder_height,w,w);
        
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
        [self addSubview:iv];
        self.userInteractionEnabled = iv.userInteractionEnabled = YES;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UIImage *devil_icon = [UIImage imageNamed:@"devil_learning_icon.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [iv setImage:devil_icon];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickListener:)];
        [iv addGestureRecognizer:singleFingerTap];
        
        iv.isAccessibilityElement = YES;
        iv.accessibilityTraits = UIAccessibilityTraitButton;
        iv.accessibilityLabel = @"Devil App Builder Learning Icon";
        
    }
    return self;
}

-(void)onClickListener:(UITapGestureRecognizer *)recognizer{
    
    UIViewController*vc = [JevilInstance currentInstance].vc;
    DevilSelectDialog* d = [[DevilSelectDialog alloc] initWithViewController:vc];
    id list = @[@{
        @"id":@"정답확인",
    },@{
        @"id":@"리로드"
    },];
    
    id param = @{
        @"key" : @"id",
        @"value" : @"id",
        @"view" : self,
        @"show" : @"point"
    };
    
    [d popupSelect:list param:param onselect:^(id  _Nonnull res) {
        if([res isEqualToString:@"정답확인"]) {
            [self check];
        } else if([res isEqualToString:@"리로드"]) {
            [self reload];
        }
    }];
    
    self.vc.devilSelectDialog = d;
    
}

-(void)check {
    [self.vc startLoading];
    NSString* path = [NSString stringWithFormat:@"/api/step/screen_id/%@", self.vc.screenId];
    [[Devil sharedInstance] requestLearn:path postParam:nil complete:^(id  _Nonnull res) {
        [self.vc stopLoading];
        @try{
            if(res) {
                NSString* goal_script = res[@"step"][@"goal_script"];
                [self.vc.jevil code:goal_script viewController:self.vc data:[JevilInstance currentInstance].meta.correspondData meta:[JevilInstance currentInstance].meta];
            }
        }@catch(NSException* e) {
            
        }
    }];
}

-(void)reload {
    UINavigationController* nc = self.vc.navigationController;
    [[WildCardConstructor sharedInstance] initWithOnlineOnComplete:^(BOOL success) {
        NSString* project_id = [WildCardConstructor sharedInstance].project_id;
        id startData = ((DevilController*)self.vc.navigationController.topViewController).startData;
        id screenId = ((DevilController*)self.vc.navigationController.topViewController).screenId;
        [self.vc.navigationController popViewControllerAnimated:YES];

        NSString* hostKey = [NSString stringWithFormat:@"%@_HOST", project_id];
        NSString* webHostKey = [NSString stringWithFormat:@"%@_WEB_HOST", project_id];
        NSString *savedHost = [[NSUserDefaults standardUserDefaults] objectForKey:hostKey];
        NSString *savedWebHost = [[NSUserDefaults standardUserDefaults] objectForKey:webHostKey];
        if(savedHost)
            [WildCardConstructor sharedInstance:project_id].project[@"host"] = savedHost;
        if(savedWebHost)
            [WildCardConstructor sharedInstance:project_id].project[@"web_host"] = savedWebHost;
        
        LearningController* d = [[LearningController alloc] init];
        d.startData = startData;
        d.screenId = screenId;
        d.projectId = project_id;
        [nc pushViewController:d animated:YES];
    }];
}

@end
