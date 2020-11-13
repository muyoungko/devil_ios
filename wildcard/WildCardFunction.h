//
//  WildCardFunction.h
//  CloudJsonViewer
//
//  Created by Mu Young Ko on 2018. 9. 21..
//  Copyright © 2018년 Mu Young Ko. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WC_SELECTED @"WC_SELECTED"
#define WC_INDEX @"WC_INDEX"
#define WC_LENGTH @"WC_LENGTH"
@interface WildCardFunctionManager : NSObject

+ (id)sharedInstance;
- (NSString*)getValueWithFunction:(NSString*)functionString data: (NSDictionary*)data;

- (BOOL)getBoolWithFunction:(NSString*)functionString data: (NSDictionary*)data defaultValue:(BOOL)defaultValue;

@property (retain, nonatomic) NSMutableDictionary* functions;
@property (retain, nonatomic) NSMutableDictionary* boolFunctions;

@end


