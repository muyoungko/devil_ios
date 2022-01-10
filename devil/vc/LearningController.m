//
//  LearningController.m
//  devil
//
//  Created by Mu Young Ko on 2022/01/09.
//  Copyright © 2022 Mu Young Ko. All rights reserved.
//

#import "LearningController.h"
#import "DebugLearningView.h"

@interface LearningController ()

@end

@implementation LearningController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)debugView{
    [DebugLearningView constructDebugViewIf:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
