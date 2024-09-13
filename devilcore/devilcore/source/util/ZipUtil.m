//
//  ZipUtil.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/09/12.
//

#import "ZipUtil.h"
#import <zlib.h>

@implementation ZipUtil


+ (NSData *)compress:(NSData *)data {
    if (!data || [data length] == 0) {
        return nil;
    }
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:16384];
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uInt)[data length];
    stream.next_in = (Bytef *)[data bytes];
    stream.total_out = 0;
    stream.avail_out = 0;
    
    if (deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) {
        return nil;
    }
    
    while (stream.avail_out == 0) {
        if (stream.total_out >= [compressedData length]) {
            [compressedData increaseLengthBy:16384];
        }
        stream.next_out = [compressedData mutableBytes] + stream.total_out;
        stream.avail_out = (uInt)([compressedData length] - stream.total_out);
        
        deflate(&stream, Z_FINISH);
    }
    
    deflateEnd(&stream);
    
    [compressedData setLength:stream.total_out];
    
    return compressedData;
}

@end
