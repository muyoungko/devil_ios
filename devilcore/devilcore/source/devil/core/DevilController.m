//
//  DevilController.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilController.h"
#import "devilcore.h"
#import "JevilCtx.h"
#import "DevilExceptionHandler.h"

@interface DevilController ()

@property (nonatomic, retain) DevilHeader* header;
@property (nonatomic, retain) JevilCtx* jevil;

@end

@implementation DevilController

- (void)viewDidLoad{   
    [super viewDidLoad];
    
    self.jevil = [[JevilCtx alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    _viewMain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
    _viewMain.userInteractionEnabled = YES;
    [self.view addSubview:_viewMain];
    
    self.data = [@{} mutableCopy];
    self.offsetY = self.navigationController.navigationBar.frame.size.height 
        + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.viewHeight = screenHeight - self.offsetY;
    self.viewMain.frame = CGRectMake(0, self.offsetY, screenWidth, _viewHeight);
    
    
    id screen = [[WildCardConstructor sharedInstance] getScreen:self.screenId];
    if(screen[@"javascript_on_create"]){
        NSString* code = screen[@"javascript_on_create"];
        [self.jevil code:code viewController:self data:self.data meta:nil];
    }

    if([[WildCardConstructor sharedInstance] getHeaderCloudJson:self.screenId]){
        id headerCloudJson = [[WildCardConstructor sharedInstance] getHeaderCloudJson:self.screenId]; 
        self.header = [[DevilHeader alloc] initWithViewController:self layer:headerCloudJson withData:self.data instanceDelegate:self];
    } else
        [self hideNavigationBar];

    [self createWildCardScreenListView:self.screenId];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkHeader];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkHeader];
}

- (void)checkHeader{
    if([[WildCardConstructor sharedInstance] getHeaderCloudJson:self.screenId])
        [self showNavigationBar];
    else
        [self hideNavigationBar];
}

- (void)showNavigationBar{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.offsetY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.viewHeight = screenHeight - self.offsetY;
    self.viewMain.frame = CGRectMake(0, self.offsetY, screenWidth, _viewHeight);
}

- (void)hideNavigationBar{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.offsetY = 0;
    self.viewHeight = screenHeight - self.offsetY;
    self.viewMain.frame = CGRectMake(0, self.offsetY, screenWidth, _viewHeight);
}

- (void)constructBlockUnder:(NSString*)block{
    NSMutableDictionary* cj = [[WildCardConstructor sharedInstance] getBlockJson:block];
    self.mainWc = [WildCardConstructor constructLayer:self.viewMain withLayer:cj instanceDelegate:self];
    [WildCardConstructor applyRule:self.mainWc withData:_data];
}

- (void)constructBlockUnderScrollView:(NSString*)block{
    NSMutableDictionary* cj = [[WildCardConstructor sharedInstance] getBlockJson:block];
    self.mainWc = [WildCardConstructor constructLayer:self.scrollView withLayer:cj instanceDelegate:self];
    [WildCardConstructor applyRule:self.mainWc withData:_data];
    self.scrollView.contentSize = CGSizeMake(screenWidth, self.mainWc.frame.size.height);
}

- (void)createWildCardScreenListView:(NSString*)screenId{
    [[WildCardConstructor sharedInstance] firstBlockFitScreenIfTrue:screenId sketch_height_more:0];
    self.tv = [[WildCardScreenTableView alloc] initWithScreenId:screenId];
    self.tv.data = self.data;
    self.tv.wildCardConstructorInstanceDelegate = self;
    self.tv.tableViewDelegate = self;
    self.tv.frame =  CGRectMake(0, 0, self.viewMain.frame.size.width, self.viewMain.frame.size.height);
    [self.viewMain addSubview:self.tv];
}

- (void)cellUpdated:(int)index view:(WildCardUIView *)v{
    
}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node{
    @try{
        if([functionName isEqualToString:@"script"]){
            NSString* code = args[0];
            [self.jevil code:code viewController:self data:self.data meta:nil];
            return YES;
        } else if([functionName hasPrefix:@"Jevil"]) {
            [JevilAction act:functionName args:args viewController:self meta:meta];
            return YES;
        }
    } @catch (NSException* e){
        [DevilExceptionHandler handle:self data:self.data e:e];
        NSLog(@"%@",e);
    }
     
    return NO;
}
@end
