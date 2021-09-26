//
//  DevilAlertDialog.m
//  devilcore
//
//  Created by Mu Young Ko on 2021/09/27.
//

#import "DevilAlertDialog.h"
#import "DevilBlockDialog.h"
#import "WildCardConstructor.h"

@interface DevilAlertDialog()
@property void (^callback)(BOOL yes);
@property (nonatomic, retain) DevilBlockDialog* dialog;
@end

@implementation DevilAlertDialog

+ (DevilAlertDialog*)sharedInstance {
    static DevilAlertDialog *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+(BOOL)showAlertTemplate:(NSString*)msg :(void (^)(BOOL yes))callback {
    id data = [@{} mutableCopy];
    data[@"alert_msg"] = msg;
    data[@"alert_yes_text"] = @"확인";
    [DevilAlertDialog sharedInstance].callback = callback;
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:@"alert-devil-template"];
    if(blockId) {
        [DevilAlertDialog sharedInstance].dialog = [DevilBlockDialog popup:@"alert-devil-template" data:data title:nil yes:nil no:nil show:nil delegate:[DevilAlertDialog sharedInstance] onselect:^(BOOL yes, id  _Nonnull res) {
            
        }];
        return YES;
    }
    return NO;
}

+(BOOL)showConfirmTemplate:(NSString*)msg :(NSString*)yes :(NSString*)no :(void (^)(BOOL yes))callback {
    id data = [@{} mutableCopy];
    data[@"alert_msg"] = msg;
    data[@"alert_yes_text"] = yes;
    data[@"alert_no_text"] = no;
    [DevilAlertDialog sharedInstance].callback = callback;
    NSString* blockId = [[WildCardConstructor sharedInstance] getBlockIdByName:@"confirm-devil-template"];
    if(blockId) {
        [DevilAlertDialog sharedInstance].dialog = [DevilBlockDialog popup:@"confirm-devil-template" data:data title:nil yes:nil no:nil show:nil delegate:[DevilAlertDialog sharedInstance] onselect:^(BOOL yes, id  _Nonnull res) {
            
        }];
        return YES;
    }
    return NO;
}

- (BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString *)functionName args:(NSArray *)args view:(WildCardUIView *)node {
    if([functionName isEqualToString:@"yes"]) {
        if(self.callback)
            self.callback(YES);
        self.callback = nil;
        [[DevilAlertDialog sharedInstance].dialog dismiss];
        [DevilAlertDialog sharedInstance].dialog = nil;
        return YES;
    } else if([functionName isEqualToString:@"no"]) {
        if(self.callback)
            self.callback(NO);
        self.callback = nil;
        [[DevilAlertDialog sharedInstance].dialog dismiss];
        [DevilAlertDialog sharedInstance].dialog = nil;
        return YES;
    }
    return NO;
}

@end
