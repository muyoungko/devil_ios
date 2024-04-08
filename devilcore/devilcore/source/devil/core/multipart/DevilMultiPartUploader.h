//
//  DevilMultiPartUploader.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/04/08.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevilMultiPartUploader : NSObject<NSURLSessionTaskDelegate>

-(void)multiPartUpload:(BOOL)showProgress url:(NSString*)urlString header:(id)header name:(NSString*)name filename:(NSString*)filename filePath:(NSString*)filePath progress:(void (^)(id res))progress_callback complete:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
