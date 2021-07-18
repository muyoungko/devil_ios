//
//  DevilDebugView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

#import "DevilDebugView.h"
#import "WildCardConstructor.h"
#import "DevilController.h"
#import "DevilDebugController.h"

@interface DevilDebugView()
@property (nonatomic, retain) DevilController* vc;
@end

@implementation DevilDebugView

+ (void)constructDebugViewIf:(DevilController*)vc{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if([bundleIdentifier isEqualToString:@"kr.co.july.CloudJsonViewer"]){
        DevilDebugView* debug = [[DevilDebugView alloc]initWithVc:vc];
        [vc.view addSubview:debug];
    }
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
        
        self.frame = CGRectMake(screenWidth-w-30,
                                screenHeight-w-100,w,w);
        
        UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, w)];
        [self addSubview:iv];
        self.userInteractionEnabled = iv.userInteractionEnabled = YES;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UIImage *devil_icon = [UIImage imageNamed:@"devil_icon.png" inBundle:bundle compatibleWithTraitCollection:nil];
        [iv setImage:devil_icon];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickListener:)];
        [iv addGestureRecognizer:singleFingerTap];
        
        UILongPressGestureRecognizer *longClick = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongClickListener:)];
        [iv addGestureRecognizer:longClick];
        
        iv.isAccessibilityElement = YES;
        iv.accessibilityTraits = UIAccessibilityTraitButton;
        iv.accessibilityLabel = @"Devil App Builder Icon";
        
    }
    return self;
}

-(void)onClickListener:(UITapGestureRecognizer *)recognizer{
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
        
        DevilController* d = [[DevilController alloc] init];
        d.startData = startData;
        d.screenId = screenId;
        d.projectId = project_id;
        [nc pushViewController:d animated:YES];
    }];
}

-(void)onLongClickListener:(UITapGestureRecognizer *)recognizer{
    if(![[self.vc.navigationController.topViewController class] isEqual:
       [DevilDebugController class]]){
        DevilDebugController*vc = [[DevilDebugController alloc] init];
        [self.vc.navigationController pushViewController:vc animated:YES];
    }
}


+(DevilDebugView*)sharedInstance{
    static DevilDebugView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DevilDebugView alloc] init];
        sharedInstance.logList = [@[] mutableCopy];
    });
    return sharedInstance;
}

- (void)log:(NSString*)type title:(NSString*)title log:(id)log {
    id item = [@{
        @"type":type,
        @"title":title,
    } mutableCopy];
    if(log)
        item[@"log"] = log;
    [self.logList addObject:item];
    
    if([self.logList count] > 100){
        [self.logList removeObjectAtIndex:0];
    }
}

- (void)clearLog{
    [self.logList removeAllObjects];
}

@end
