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
#import "JevilInstance.h"
#import "Jevil.h"
#import "JevilCtx.h"


@interface DevilDebugView()
@property (nonatomic, retain) DevilController* vc;
@end

@implementation DevilDebugView

+ (void)constructDebugViewIf:(DevilController*)vc{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    DevilController* dc = (DevilController*)[JevilInstance currentInstance].vc;
    UIDevice *device = [UIDevice currentDevice];
    NSString* udid = [[device identifierForVendor] UUIDString];
    if([bundleIdentifier isEqualToString:@"kr.co.july.CloudJsonViewer"]
       && (![@"1605234988599" isEqualToString:dc.projectId] ||
           [@"CD44C803-7AAE-420F-A1DE-276E81847FAE" isEqualToString:udid]
           )
       
       )
    {
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
    if(![[self.vc.navigationController.topViewController class] isEqual:[DevilDebugController class]]
       && self.vc.devilSelectDialog == nil
       ){
        __block id dev_menu_list = [WildCardConstructor sharedInstance].project[@"dev_menu_list"];
        
        if([dev_menu_list count] > 0) {
            UIViewController*vc = [JevilInstance currentInstance].vc;
            __block DevilSelectDialog* d = [[DevilSelectDialog alloc] initWithViewController:vc];
            id list = [@[@{
                @"id":@"디버그화면",
                @"text":@"디버그화면",
            },] mutableCopy];
            
            
            for(int i=0;i<[dev_menu_list count];i++) {
                id menu = dev_menu_list[i];
                NSString* _id = [NSString stringWithFormat:@"%d", i];
                NSString* text = menu[@"name"];
                NSString* script = menu[@"script"];
                [list addObject:[@{
                    @"id":_id,
                    @"text":text,
                    @"script":script,
                } mutableCopy]];
            }
            
            id param = @{
                @"key" : @"id",
                @"value" : @"text",
                @"view" : self,
                @"show" : @"point"
            };
            
            [d popupSelect:list param:param onselect:^(id  _Nonnull res) {
                if([res isEqualToString:@"디버그화면"]) {
                    DevilDebugController*vc = [[DevilDebugController alloc] init];
                    [self.vc.navigationController pushViewController:vc animated:YES];
                } else {
                    int index = [res intValue];
                    NSString* script = dev_menu_list[index][@"script"];
                    [self.vc.jevil code:script viewController:self.vc data:self.vc.mainWc.meta.correspondData meta:self.vc.mainWc.meta];
                }
            }];
            
            self.vc.devilSelectDialog = d;
        } else {
            DevilDebugController*vc = [[DevilDebugController alloc] init];
            [self.vc.navigationController pushViewController:vc animated:YES];
        }
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
