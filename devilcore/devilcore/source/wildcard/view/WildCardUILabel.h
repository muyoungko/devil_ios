//
//  WildCardUILabel.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 6. 18..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WildCardUILabel : UILabel

@property BOOL stroke;
@property int alignment;
@property BOOL wrap_width;
@property BOOL wrap_height;

@property CGRect strokeRect;

@end
