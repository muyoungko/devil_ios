//
//  DevilPdf.h
//  devilcore
//
//  Created by Mu Young Ko on 2023/09/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilPdf : NSObject

+(void)pdfInfo:(NSString*)url callback:(void (^)(id res))callback;
+(void)pdfToImage:(NSString*)url :(id)param callback:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
