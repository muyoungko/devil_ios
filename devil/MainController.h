//
//  MainController.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2020/11/13.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubController.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainController : SubController<CLLocationManagerDelegate>

-(void)startProject:(NSString*) project_id;

@end

NS_ASSUME_NONNULL_END
