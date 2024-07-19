//
//  DevilPdf.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/09/11.
//

#import "DevilPdf.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation DevilPdf

+(void)pdfInfo:(NSString*)url callback:(void (^)(id res))callback {
    
    NSURL *pdfUrl = [NSURL fileURLWithPath:url];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)pdfUrl);
        int size = (int)CGPDFDocumentGetNumberOfPages(document);
        id r = @{@"r":@TRUE,
                 @"file":url,
                 @"pageCount":[NSNumber numberWithInt:size]};
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(r);
        });
    });
}

+(void)pdfToImage:(NSString*)url :(id)param callback:(void (^)(id res))callback {
    NSURL *pdfUrl = [NSURL fileURLWithPath:url];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)pdfUrl);
        int preferredWidth = 0;
        if(param[@"width"])
            preferredWidth = [param[@"width"] intValue];
        
        id r = [@{@"r":@TRUE,
                  @"image_list" : [@[] mutableCopy],
                } mutableCopy];
        int size = (int)CGPDFDocumentGetNumberOfPages(document);
        for(int i=0;i<size;i++) {
            
            int page = i+1;
            
            // Get the page
            CGPDFPageRef myPageRef = CGPDFDocumentGetPage(document, page);
            // Changed this line for the line above which is a generic line
            //CGPDFPageRef page = [self getPage:page_number];
            
            CGRect imageRect = CGPDFPageGetBoxRect(myPageRef, kCGPDFMediaBox);
            imageRect.origin = CGPointZero;
            CGFloat width = imageRect.size.width;
            CGFloat height = imageRect.size.height;
            float scale = 1.0f;
            if(preferredWidth > 0) {
                scale = preferredWidth / width;
                height = (float)preferredWidth / width * height;
                width = preferredWidth;
            }

            UIGraphicsBeginImageContext(CGSizeMake(width, height));

            CGContextRef context = UIGraphicsGetCurrentContext();

            // White BG
            CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
            CGContextFillRect(context, CGRectMake(0,0,width, height));

            CGContextSaveGState(context);

            CGContextTranslateCTM(context, 0.0, height);
            CGContextScaleCTM(context, scale, -scale);
            CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(myPageRef, kCGPDFMediaBox, imageRect, 0, true));

            CGContextDrawPDFPage(context, myPageRef);
            CGContextRestoreGState(context);

            UIImage *thm = UIGraphicsGetImageFromCurrentImageContext();
            
            NSData *imageData = UIImageJPEGRepresentation(thm, 1.0f);
            NSString* fileName = [NSString stringWithFormat:@"pdfpage%d.jpg", page];
            NSString* filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            [imageData writeToFile:filePath atomically:YES];
            [r[@"image_list"] addObject:@{
                @"image":filePath,
            }];
            
            UIGraphicsEndImageContext();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(r);
        });
    });
}

@end
