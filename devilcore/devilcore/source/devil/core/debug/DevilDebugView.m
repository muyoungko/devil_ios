//
//  DevilDebugView.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/01/14.
//

#import "DevilDebugView.h"
#import "WildCardConstructor.h"
#import "DevilController.h"

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
        
    }
    return self;
}

-(void)onClickListener:(UITapGestureRecognizer *)recognizer{
    [[WildCardConstructor sharedInstance] initWithOnlineOnComplete:^(BOOL success) {
        DevilController* d = [[DevilController alloc] init];
        d.startData = ((DevilController*)self.vc.navigationController.topViewController).startData;
        d.screenId = ((DevilController*)self.vc.navigationController.topViewController).screenId;
        
        [self.vc.navigationController popViewControllerAnimated:YES];
        [self.vc.navigationController pushViewController:d animated:YES];
    }];
}

-(void)onLongClickListener:(UITapGestureRecognizer *)recognizer{
    //TODO log
}

@end
