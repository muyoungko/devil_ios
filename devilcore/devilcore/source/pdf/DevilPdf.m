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

+(void)pdfToImage:(NSString*)url :(id)param callback:(void (^)(id res))callback {
    NSURL *pdfUrl = [NSURL fileURLWithPath:url];
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)pdfUrl);
    CGFloat width = 600.0;

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

        CGRect pageRect = CGPDFPageGetBoxRect(myPageRef, kCGPDFMediaBox);
        CGFloat pdfScale = width/pageRect.size.width;
        pageRect.size = CGSizeMake(pageRect.size.width*pdfScale, pageRect.size.height*pdfScale);
        pageRect.origin = CGPointZero;

        UIGraphicsBeginImageContext(pageRect.size);

        CGContextRef context = UIGraphicsGetCurrentContext();

        // White BG
        CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
        CGContextFillRect(context,pageRect);

        CGContextSaveGState(context);

        // ***********
        // Next 3 lines makes the rotations so that the page look in the right direction
        // ***********
        CGContextTranslateCTM(context, 0.0, pageRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(myPageRef, kCGPDFMediaBox, pageRect, 0, true));

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
    
    callback(r);
}

@end
