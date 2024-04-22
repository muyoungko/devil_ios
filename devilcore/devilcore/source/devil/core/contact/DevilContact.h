//
//  DevilContact.h
//  devilcore
//
//  Created by Mu Young Ko on 2024/01/13.
//

#import <Foundation/Foundation.h>
@import ContactsUI;
@import Contacts;

NS_ASSUME_NONNULL_BEGIN

@interface DevilContact : NSObject<CNContactPickerDelegate, CNContactViewControllerDelegate>

+ (DevilContact*)sharedInstance;
- (void)addContact:(id)param;
- (void)getContactList:(id)param callback:(void (^)(id res))callback;
- (void)popupContactSelect:(id)param callback:(void (^)(id res))callback;

@end

NS_ASSUME_NONNULL_END
