//
//  ScriptViewer.h
//  devil
//
//  Created by Mu Young Ko on 2026/01/14.
//  Copyright © 2026 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScriptViewer : UIView

+ (instancetype)createView;
- (void)updateView:(NSString *)script;

@end

NS_ASSUME_NONNULL_END
