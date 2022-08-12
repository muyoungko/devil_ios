//
//  MarketComponent.h
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/12.
//

#import <Foundation/Foundation.h>
#import "WildCardMeta.h"

NS_ASSUME_NONNULL_BEGIN

@interface MarketComponent : NSObject

@property (nonatomic, retain) WildCardUIView* vv;
@property (nonatomic, retain) WildCardMeta* meta;
@property (nonatomic, retain) id marketJson;

-(id)initWithLayer:(id)market meta:(id)meta;

-(void)initialized;
-(void)created;
-(void)update:(id)opt;
-(void)pause;
-(void)resume;
-(void)destroy;
-(void)keypad:(BOOL)up :(CGRect)keyboardRect;

@end

NS_ASSUME_NONNULL_END
