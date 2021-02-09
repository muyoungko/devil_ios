//
//  DevilController.m
//  devilcore
//
//  Created by Mu Young Ko on 2020/12/04.
//

#import "DevilController.h"
#import "devilcore.h"
#import "JevilCtx.h"
#import "JevilInstance.h"
#import "DevilExceptionHandler.h"
#import "DevilDebugView.h"
#import "Lottie.h"

@interface DevilController ()

@property (nonatomic, retain) DevilHeader* header;
@property (nonatomic, retain) WildCardUIView* footer;
@property (nonatomic, retain) JevilCtx* jevil;

@end

@implementation DevilController

- (void)viewDidLoad{   
    [super viewDidLoad];
    
    self.jevil = [[JevilCtx alloc] init];
    
    _viewMain = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth, screenHeight)];
    _viewMain.userInteractionEnabled = YES;
    [self.view addSubview:_viewMain];
    
    if(self.startData) {
        self.data = self.startData;
    } else
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
        
    if([[WildCardConstructor sharedInstance] getFooterCloudJson:self.screenId]){
        id footerCloudJson = [[WildCardConstructor sharedInstance] getFooterCloudJson:self.screenId]; 
        self.footer = [WildCardConstructor constructLayer:nil withLayer:footerCloudJson instanceDelegate:self];
        [WildCardConstructor applyRule:self.footer withData:self.data];
        
        self.footer.frame = CGRectMake(0, screenHeight - self.footer.frame.size.height -30, self.footer.frame.size.width, self.footer.frame.size.height);
        [self.view addSubview:self.footer];
    }

    [self createWildCardScreenListView:self.screenId];
    
    [JevilInstance globalInstance].callbackData = nil;
    [JevilInstance globalInstance].callbackFunction = nil;
    [DevilDebugView constructDebugViewIf:self];
}

-(void)tab:(NSString*)screenId {
    [self.tv removeFromSuperview];
    
    if(self.startData) {
        self.data = self.startData;
    } else
        self.data = [@{} mutableCopy];
    self.screenId = screenId;
    id screen = [[WildCardConstructor sharedInstance] getScreen:self.screenId];
    if(screen[@"javascript_on_create"]){
        NSString* code = screen[@"javascript_on_create"];
        [self.jevil code:code viewController:self data:self.data meta:nil];
    }

    [WildCardConstructor applyRule:self.footer withData:self.data];

    [self createWildCardScreenListView:self.screenId];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self checkHeader];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self checkHeader];
    
    [WildCardConstructor sharedInstance].loadingDelegate = self;
    
    if([JevilInstance globalInstance].callbackData){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[JevilInstance globalInstance].callbackData
                                                           options:nil
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [JevilInstance globalInstance].callbackData = nil;
        [self.jevil code:[NSString stringWithFormat:@"callback(%@)", jsonString] viewController:self data:self.data meta:nil];
    } else if([JevilInstance globalInstance].callbackFunction){
        JSValue* c = [JevilInstance globalInstance].callbackFunction;
        [JevilInstance globalInstance].callbackFunction = nil;
        NSString* acode = [NSString stringWithFormat:@"var a = %@()", c];
        [self.jevil code:acode viewController:self data:self.data meta:nil];
    }
}

- (void)startLoading{
    [self showIndicator];
}
- (void)stopLoading{
    [self hideIndicator];
}

- (void)checkHeader{
    if([[WildCardConstructor sharedInstance] getHeaderCloudJson:self.screenId]){
        [self showNavigationBar];
    }else
        [self hideNavigationBar];
}

- (void)showNavigationBar{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.offsetY = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.viewHeight = screenHeight - self.offsetY;
    self.viewMain.frame = CGRectMake(0, self.offsetY, screenWidth, _viewHeight);
}

- (void)hideNavigationBar{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    int sketch_height_more = 0;
    if([[WildCardConstructor sharedInstance] getHeaderCloudJson:self.screenId]){
        sketch_height_more = 80;
    }
    [[WildCardConstructor sharedInstance] firstBlockFitScreenIfTrue:screenId sketch_height_more:sketch_height_more];
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
        if([functionName isEqualToString:@"Jevil.script"]){
            NSString* code = args[0];
            code = [code substringFromIndex:1];
            code = [code substringToIndex:[code length]-1];
            [self.jevil code:code viewController:self data:self.data meta:meta];
            return YES;
        } else if([functionName isEqualToString:@"script"]){
            NSString* code = args[0];
            [self.jevil code:code viewController:self data:self.data meta:meta];
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


-(void)updateMeta {
    [self.tv reloadData];
    [WildCardConstructor applyRule:self.footer withData:self.data];
}

-(void)popup:(NSString*)screenId{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    //TODO : 팝업을 block으로 생성하도록 변경
    CGFloat margin = 8.0F;
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 100.0F)];
    customView.backgroundColor = [UIColor greenColor];
    [alertController.view addSubview:customView];

    UIAlertAction *somethingAction = [UIAlertAction actionWithTitle:@"Something" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [alertController addAction:somethingAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}


@end
