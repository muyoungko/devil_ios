//
//  DevilDynamicAsset.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/12/26.
//
@import Foundation;
@import UIKit;
@import CoreText;

#import "DevilDynamicAsset.h"
#import "DevilDownloader.h"

@interface DevilDynamicAsset()
@property (nonatomic, retain) NSMutableDictionary* cache;
@property int downloadCount;
@property (nonatomic, retain) NSMutableArray* downloaderList;
@end

@implementation DevilDynamicAsset
+ (DevilDynamicAsset*)sharedInstance {
    static DevilDynamicAsset* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DevilDynamicAsset alloc] init];
        instance.cache = [@{} mutableCopy];
        instance.downloaderList = [@[] mutableCopy];
    });
    return instance;
}

- (void)download:(id)key_list callback:(void (^)(id res))callback {
    self.downloadCount= 0;
    if(!key_list || [key_list count] == 0) {
        callback(@{@"r":@TRUE});
        return;
    }
    
    for(int i=0;key_list && i<[key_list count];i++) {
        NSString* key = key_list[i];
        DevilDownloader* downloader = [[DevilDownloader alloc] init];
        [self.downloaderList addObject:downloader];
        NSString* url = [NSString stringWithFormat:@"https://img.deavil.com/%@", key];
        NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString* dest = [NSString stringWithFormat:@"%@/%@", documentsDirectory, key];
        
        [self createDirIfNot:key];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:dest]) {
            self.downloadCount ++;
            if(self.downloadCount == [key_list count])
                callback(@{@"r":@TRUE});
            continue;
        }
        
        [downloader download:false url:url header:@{} filePath:dest progress:^(id  _Nonnull res) {
            
        } complete:^(id  _Nonnull res) {
            self.downloadCount ++ ;
            if(self.downloadCount == [key_list count])
                callback(@{@"r":@TRUE});
        }];
    }
}

- (void)createDirIfNot:(NSString *)key {
    NSArray<NSString *> *pathComponents = [key componentsSeparatedByString:@"/"];
    NSString *basePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *currentPath = @"";

    for (NSInteger i = 0; i < pathComponents.count - 1; i++) {
        NSString *component = pathComponents[i];
        currentPath = [currentPath stringByAppendingPathComponent:component];
        NSString *fullPath = [basePath stringByAppendingPathComponent:currentPath];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:fullPath]) {
            NSError *error = nil;
            BOOL success = [fileManager createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];

            if (!success || error) {
                @throw [NSException exceptionWithName:@"DirectoryCreationException"
                                               reason:error.localizedDescription
                                             userInfo:nil];
            }
        }
    }
}

- (UIFont*)getFont:(NSString*)key fontSize:(float)size{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString* fontPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, key];
    
    if(!self.cache[key]) {
        self.cache[key] = [self registerFont:fontPath];
    }
    
    NSString* fontName = self.cache[key];
    if(fontName == nil)
        return nil;
    
    UIFont * font = [UIFont fontWithName:fontName size:size];
    return font;
}

- (NSString *)fontNameFromPath:(NSString *)fontPath {
    NSURL *fontURL = [NSURL fileURLWithPath:fontPath];
    NSArray *fontDescriptors = CFBridgingRelease(CTFontManagerCreateFontDescriptorsFromURL((__bridge CFURLRef)fontURL));
    
    if (fontDescriptors.count > 0) {
        CTFontDescriptorRef descriptor = (__bridge CTFontDescriptorRef)fontDescriptors.firstObject;
        NSString *fontName = CFBridgingRelease(CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute));
        return fontName;
    }
    return nil;
}

- (NSString*) registerFont:(NSString *)fontPath {
    NSURL *fontURL = [NSURL fileURLWithPath:fontPath];
    
    CFErrorRef error = NULL;
    BOOL success = CTFontManagerRegisterFontsForURL((__bridge CFURLRef)fontURL, kCTFontManagerScopeProcess, &error);
    
    if (!success) {
        NSLog(@"Failed to load font: %@", ((__bridge NSError *)error).localizedDescription);
        return nil;
    }
    
    // 폰트 이름 확인
    NSString *fontName = [self fontNameFromPath:fontPath];
    return fontName;
}

@end
