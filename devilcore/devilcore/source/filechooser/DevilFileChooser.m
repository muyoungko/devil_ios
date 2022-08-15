//
//  DevilFileChooser.m
//  devilcore
//
//  Created by Mu Young Ko on 2022/08/15.
//

#import "DevilFileChooser.h"

@import UniformTypeIdentifiers;


@interface DevilFileChooser()<UIDocumentPickerDelegate>
@property void (^callback)(id res);
@end

@implementation DevilFileChooser

+ (DevilFileChooser*)sharedInstance {
    static DevilFileChooser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)fileChooser:(UIViewController*)vc param:(id)param callback:(void (^)(id res))callback {
    UIDocumentPickerViewController* documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                 inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    if (@available(iOS 11.0, *)) {
        documentPicker.allowsMultipleSelection = false;
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 13.0, *))
        documentPicker.shouldShowFileExtensions = true;
    self.callback = callback;
    [vc presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if(self.callback) {
        NSString* path = [urls[0] path];
        self.callback([@{
            @"r":@TRUE,
            @"file" :path,
        } mutableCopy]);
        self.callback = nil;
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    if(self.callback) {
        self.callback([@{
            @"r":@FALSE,
        } mutableCopy]);
        self.callback = nil;
    }
}


@end
