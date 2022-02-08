//
//  ReplaceRuleQrcode.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/07/20.
//

#import "ReplaceRuleQrcode.h"
#import "MappingSyntaxInterpreter.h"

@interface ReplaceRuleQrcode()
@property (nonatomic, retain) NSString* lastCode;
@property (nonatomic, retain) NSString* type;
@end

@implementation ReplaceRuleQrcode

- (void)constructRule:(WildCardMeta *)wcMeta parent:(UIView *)parent vv:(WildCardUIView *)vv layer:(id)layer depth:(int)depth result:(id)result{
    UIView* iv = [[UIImageView alloc] init];
    self.replaceView = iv;
    self.replaceJsonKey = layer[@"qrcode"][@"code"];
    self.type = layer[@"qrcode"][@"type"];
    
    iv.contentMode = UIViewContentModeScaleAspectFill;
    [vv addSubview:iv];
    [WildCardConstructor followSizeFromFather:vv child:iv];
}

- (void)updateRule:(WildCardMeta *)meta data:(id)opt{
    NSString* code = [MappingSyntaxInterpreter interpret:self.replaceJsonKey:opt];
    if(code != nil && ![code isEqualToString:self.lastCode]){
        self.lastCode = code;
        UIImage* qrImage = [self createQR:code];
        [((UIImageView*)self.replaceView) setImage:qrImage];
    }
}


- (UIImage *)createQR:(NSString*)code {
    
    CIFilter *filter = nil;
    if([@"bar" isEqualToString:self.type]) {
        filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    } else
        filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    
    NSData *data = [code dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *image = [filter valueForKey:@"outputImage"];
    
    // Calculate the size of the generated image and the scale for the desired image size
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = 5.0f;//MIN(size.width / CGRectGetWidth(extent), size.height / CGRectGetHeight(extent));
    
    // Since CoreImage nicely interpolates, we need to create a bitmap image that we'll draw into
    // a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
#if TARGET_OS_IPHONE
    CIContext *context = [CIContext contextWithOptions:nil];
#else
    CIContext *context = [CIContext contextWithCGContext:bitmapRef options:nil];
#endif
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    CIImage *input = [CIImage imageWithCGImage:scaledImage];
    return [[UIImage alloc] initWithCIImage:input];
    
    
}


@end
