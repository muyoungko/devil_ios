//
//  DevilPaintMarketComponent.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/02/07.
//

#import "DevilPaintMarketComponent.h"
#import "DevilPaintView.h"

@interface DevilPaintMarketComponent()

@property (nonatomic, retain) DevilPaintView* devilPaintView;
@end

@implementation DevilPaintMarketComponent

- (void)created {
    [super created];
    
    self.devilPaintView = [[DevilPaintView alloc] init];
    self.devilPaintView.bgColor = self.vv.backgroundColor;
    [self.vv addSubview:self.devilPaintView];
    self.devilPaintView.userInteractionEnabled = YES;
    [WildCardConstructor followSizeFromFather:self.vv child:self.devilPaintView];
    [WildCardConstructor userInteractionEnableToParentPath:self.devilPaintView depth:5];
    //[self.devilPaintView clear];
}

-(void)saveImage:(void (^)(id res))callback{
    NSData *imageData = UIImageJPEGRepresentation(self.devilPaintView.image, 0.8f);
    NSString* outputFileName = [NSUUID UUID].UUIDString;
    NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"jpg"]];
    [imageData writeToFile:path atomically:YES];
    callback(@{
        @"r" : @TRUE,
        @"path" : path,
    });
}

-(BOOL)isEmpty {
    return ![self.devilPaintView isSigned];
}

-(void)clear {
    [self.devilPaintView clear];
}

@end
