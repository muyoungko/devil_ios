//
//  JoinController.m
//  Devil
//
//  Created by 고무영 on 16/04/2019.
//  Copyright © 2019 trix. All rights reserved.
//

#import "JoinController.h"
#import "WebController.h"
#import "Devil.h"
#import "MainController.h"
#import "Lang.h"

@interface JoinController ()

@end

@implementation JoinController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = trans(@"회원 가입");
    self.data[@"email"] = self.email;
    [self showNavigationBar];
    [self constructBlockUnder:@"1605943385593"];
}

- (void)bottomClick:(id)sender{
    [self join];
}

-(BOOL)onInstanceCustomAction:(WildCardMeta *)meta function:(NSString*)functionName args:(NSArray*)args view:(WildCardUIView*) node
{
    if([functionName isEqualToString:@"check1"]){
        BOOL allcheck = [@"Y" isEqualToString: self.data[@"check1"]];
        for(int i=2;i<=3;i++)
            self.data[[NSString stringWithFormat:@"check%d",i]] =  allcheck?@"Y":@"N";
        [self reloadBlock];
        
        return true;
    } else if([functionName isEqualToString:@"check2"] || [functionName isEqualToString:@"check3"]){
        BOOL allcheck = true;
        for(int i=2;i<=3;i++)
            if(![@"Y" isEqualToString:self.data[[NSString stringWithFormat:@"check%d",i]]])
                allcheck = false;
        if(allcheck)
            self.data[@"check1"] = @"Y";
        else
            self.data[@"check1"] = @"N";
        [self reloadBlock];
        
        return true;
    } else if([functionName isEqualToString:@"join"]){
        [self join];
        
        return true;
    }
    return NO;
}

- (BOOL)join{
    __block NSString* email = trim(self.data[@"email"]);
    __block NSString* password = trim(self.data[@"pass"]);
    __block NSString* agree2 = self.data[@"check2"];
    __block NSString* agree3 = self.data[@"check3"];
    
    if(_identifier == nil)
        _identifier = email;
    
    if(!([@"Y" isEqualToString:agree2] &&
         [@"Y" isEqualToString:agree3])){
        [self showAlert:@"필수 항목에 동의해주세요."];
        return true;
    }
    
    if([_type isEqualToString:@"email"] && ![self validateEmailWithString:email]){
        [self showAlert:@"올바른 형식의 이메일을 입력해주세요."];
        return true;
    }
    
    if([_type isEqualToString:@"email"] && empty(password)){
        [self showAlert:@"비밀번호를 입력해주세요."];
        return true;
    }
    
    if([_type isEqualToString:@"email"]){
        if([password length] < 6){
            [self showAlert:@"비밀번호를 6자 이상으로 입력해주세요."];
            return true;
        }
        
        int count = 0;
        int dcount = 0;
        int len = (int)[password length];
        for (int i=0;i<len;i++) {
            char c = [password characterAtIndex:i];
            if(c>='0' && c<='9')
                count++;
            else
                dcount++;
        }
        if (count == 0 || dcount == 0) {
            [self showAlert:@"영문, 숫자를 혼합해주세요."];
            return true;
        }
    }
    
    if(empty(self.name))
        _name = [email componentsSeparatedByString:@"@"][0];
    
    if([_type isEqualToString:@"email"])
        _identifier = email;
    
    if([_type isEqualToString:@"fb"])
        _profile = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", _identifier];
    
    id p = [@{} mutableCopy];
    p[@"type"] = self.type;
    p[@"identifier"] = self.identifier;
    if(email != nil)
        p[@"email"]= email;
    if(password != nil)
        p[@"password"]= password;
    if(self.name != nil)
        p[@"name"]= self.name;
    if(self.profile != nil)
        p[@"profile"]= self.profile;
    if(self.sex != nil)
        p[@"sex"]= self.sex;
    if(self.age != nil)
        p[@"age"]= self.age;
    
    p[@"udid"]= [Devil sharedInstance].udid;
    
    p[@"agree1"] = @"Y";
    p[@"agree2"] = [@"Y" isEqualToString:agree2]?@"Y":@"N";
    p[@"agree3"] = [@"Y" isEqualToString:agree3]?@"Y":@"N";
    p[@"agree4"] = @"Y";
    p[@"agree5"] = @"Y";
    
    if(email == nil)
        email = @"none@kakao.com";
    
    [self showIndicator];
    [[Devil sharedInstance] request:@"/member/join" postParam:p complete:^(id  _Nonnull res) {
        [self hideIndicator];
        if(res && [res[@"r"] boolValue]){
            NSString* passwordOrToken = password;
            if(self.token != nil)
                passwordOrToken = self.token;
            if([@"apple" isEqualToString:self.type])
                email = self.identifier;
            [[Devil sharedInstance] login:self.type email:email passwordOrToken:passwordOrToken callback:^(id  _Nonnull res) {
                [self hideIndicator];
                if(res && [res[@"r"] boolValue]){
                    MainController* vc = [[MainController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        } else
            [self showAlert:res[@"msg"]];
    }];
    
    return YES;
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}





@end
