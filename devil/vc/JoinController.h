//
//  JoinController.h
//  devil
//
//  Created by Mu Young Ko on 2020/11/20.
//  Copyright © 2020 Mu Young Ko. All rights reserved.
//

#import "SubController.h"

NS_ASSUME_NONNULL_BEGIN

@interface JoinController : SubController

@property(nonatomic, retain) NSString* type;
@property(nonatomic, retain) NSString* email;
@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) NSString* identifier;
@property(nonatomic, retain) NSString* token;
@property(nonatomic, retain) NSString* sex;
@property(nonatomic, retain) NSString* age;
@property(nonatomic, retain) NSString* profile;

@end

NS_ASSUME_NONNULL_END
