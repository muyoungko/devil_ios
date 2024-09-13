//
//  ZipUtil.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/09/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZipUtil : NSObject

+ (NSData *)compress:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
