//
//  DevilContact.m
//  devilcore
//
//  Created by Mu Young Ko on 2024/01/13.
//

#import "DevilContact.h"
#import "JevilInstance.h"

@interface DevilContact()
@property void (^callback)(id res);
@end

@implementation DevilContact

+ (DevilContact*)sharedInstance {
    static DevilContact *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)addContact:(id)param {
    CNMutableContact* c = [[CNMutableContact alloc] init];
    c.givenName = param[@"name"];
    if(param[@"email"])
        c.emailAddresses = @[
            [[CNLabeledValue alloc] initWithLabel:CNLabelEmailiCloud value:param[@"email"]]
        ];
    
    if(param[@"phone"])
        c.phoneNumbers = @[
            [[CNLabeledValue alloc] initWithLabel:CNLabelPhoneNumberMobile value:[[CNPhoneNumber alloc] initWithStringValue:param[@"phone"]]]
        ];
    CNContactViewController* vc = [CNContactViewController viewControllerForUnknownContact:c];
    [[JevilInstance currentInstance].vc.navigationController pushViewController:vc animated:YES];
}

- (void)getContactList:(id)param callback:(void (^)(id res))callback{
    id r = [@{} mutableCopy];
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusDenied || status == CNAuthorizationStatusRestricted) {
        r[@"r"] = @FALSE;
        r[@"msg"] = @"No Permission";
        callback(r);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // make sure the user granted us access

            if (!granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    r[@"r"] = @FALSE;
                    r[@"msg"] = @"No Permission";
                    callback(r);
                });
                return;
            }

            // build array of contacts

            NSMutableArray *contacts = [NSMutableArray array];
            NSError *fetchError;
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, CNContactPhoneNumbersKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];

            BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
                [contacts addObject:contact];
            }];
            if (!success) {
                NSLog(@"error = %@", fetchError);
            }

            // you can now do something with the list of contacts, for example, to show the names

            CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
            id list = [@[] mutableCopy];
            r[@"list"] = list;
            for (CNContact *contact in contacts) {
                NSString *name = [formatter stringFromContact:contact];
                NSString* phone = @"";
                if([contact.phoneNumbers count] > 0) {
                    CNPhoneNumber* number = (CNPhoneNumber*)contact.phoneNumbers[0].value;
                    phone = [number valueForKey:@"digits"];
                    //NSLog(@"contact = %@ %@", name, phone);
                    [list addObject: @{
                        @"name" : name,
                        @"phone" : phone,
                    }];
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                r[@"r"] = @TRUE;
                callback(r);
            });
        }];
    });
}

- (void)popupContactSelect:(id)param callback:(void (^)(id res))callback{
    UIViewController* vc = [JevilInstance currentInstance].vc;
    
    // CNContactPickerViewController 인스턴스를 생성합니다.
    CNContactPickerViewController *picker = [[CNContactPickerViewController alloc] init];
    picker.delegate = self; // 델리게이트 설정
    self.callback = callback;
    
    // 연락처 뷰 컨트롤러를 표시합니다.
    [vc presentViewController:picker animated:YES completion:nil];
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact; {
    if([contact.phoneNumbers count] > 0) {
        CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
        NSString *name = [formatter stringFromContact:contact];
        CNPhoneNumber* number = (CNPhoneNumber*)contact.phoneNumbers[0].value;
        NSString* phone = [number valueForKey:@"digits"];
        id r = [@{} mutableCopy];
        r[@"r"] = @TRUE;
        r[@"name"] = name;
        r[@"phone"] = phone;
        
        self.callback(r);
    }
}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString *selectedPhoneNumber = phoneNumber.stringValue;
    
    // 선택한 전화번호를 사용할 수 있습니다.
    NSLog(@"선택한 전화번호: %@", selectedPhoneNumber);
    
    // 이후에 선택한 전화번호로 원하는 작업을 수행할 수 있습니다.
    
    // 선택한 전화번호를 사용한 후, 연락처 뷰 컨트롤러를 닫을 수 있습니다.
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
