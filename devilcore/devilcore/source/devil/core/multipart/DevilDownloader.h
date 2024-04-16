//
//  DevilDownloader.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/04/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilDownloader : NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate>

-(void)download:(BOOL)showProgress url:(NSString*)urlString header:(id)header filePath:(NSString*)filePath progress:(void (^)(id res))progress_callback complete:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
