//
//  DevilReview.m
//  devilcore
//
//  Created by Mu Young Ko on 2023/11/08.
//

#import "DevilReview.h"
#import "Jevil.h"
@import StoreKit;

@interface DevilReview ()

@end


@implementation DevilReview

+(DevilReview*)sharedInstance {
    static DevilReview *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#define REVIEW_DATE_MAP @"REVIEW_DATE_MAP"
#define REVIEW_SHOWED @"REVIEW_SHOWED"

-(BOOL)reviewShouldShow {
    
    if([Jevil get:REVIEW_SHOWED])
        return NO;
    
    NSString* s = [Jevil get:REVIEW_DATE_MAP];
    if(!s)
        s = @"{}";
    
    NSData *jsonData = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMdd"];
    NSString* today = [df stringFromDate:[NSDate date]];
    json[today] = @"Y";
    
    NSData * dd = [NSJSONSerialization  dataWithJSONObject:json options:0 error:&e];
    NSString * myString = [[NSString alloc] initWithData:dd   encoding:NSUTF8StringEncoding];
    [Jevil save:REVIEW_DATE_MAP :myString];
    
    id ks = [json allKeys];
    if([ks count] >= 5) {
        [Jevil save:REVIEW_SHOWED :@"Y"];
        return YES;
    }
    
    return NO;
}

-(BOOL)review {
    if([self reviewShouldShow])
        [SKStoreReviewController requestReview];
    
    
//    var count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.processCompletedCountKey)
//    count += 1
//    UserDefaults.standard.set(count, forKey: UserDefaultsKeys.processCompletedCountKey)
//    print("Process completed \(count) time(s).")
//
//
//    // Keep track of the most recent app version that prompts the user for a review.
//    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
//
//    // Get the current bundle version for the app.
//    let infoDictionaryKey = kCFBundleVersionKey as String
//    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
//        else { fatalError("Expected to find a bundle version in the info dictionary.") }
//     // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
//     if count >= 4 && currentVersion != lastVersionPromptedForReview {
//         Task { @MainActor [weak self] in
//             // Delay for two seconds to avoid interrupting the person using the app.
//             // Use the equation n * 10^9 to convert seconds to nanoseconds.
//             try? await Task.sleep(nanoseconds: UInt64(2e9))
//             if let windowScene = self?.view.window?.windowScene,
//                self?.navigationController?.topViewController is ProcessCompletedViewController {
//                 SKStoreReviewController.requestReview(in: windowScene)
//                 UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastVersionPromptedForReviewKey)
//            }
//         }
//     }
    return YES;
}

@end
