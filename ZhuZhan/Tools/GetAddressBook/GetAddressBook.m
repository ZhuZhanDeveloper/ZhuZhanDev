//
//  GetAddressBook.m
//  通讯录
//
//  Created by 汪洋 on 15/1/21.
//  Copyright (c) 2015年 wy. All rights reserved.
//

#import "GetAddressBook.h"
@implementation GetAddressBook
@synthesize addressBook = _addressBook;
//注册通讯录
-(void)registerAddressBook:(void (^)(bool granted, NSError *error))block{
    CFErrorRef error = NULL;
    
    _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
        
        if (granted) {
            //查询所有
            [self filterContentForSearchText];
            if(block){
                block(YES,nil);
            }
        }else{
            NSLog(@"asdfasdfasf");
        }
    });
}

- (void)filterContentForSearchText{
    //如果没有授权则退出
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        return ;
    }
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    CFMutableArrayRef mresults=CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                        CFArrayGetCount(results),
                                                        results);
    //将结果按照拼音排序，将结果放入mresults数组中
    CFArraySortValues(mresults,
                      CFRangeMake(0, CFArrayGetCount(results)),
                      (CFComparatorFunction) ABPersonComparePeopleByName,
                      (void*) ABPersonGetSortOrdering());
    
    [self getNameAndPhone:mresults];
}

//获取联系人名字电话
-(void)getNameAndPhone:(CFMutableArrayRef)mresults{
    NSMutableDictionary *allDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *allArr = [[NSMutableArray alloc] init];
    //遍历所有联系人
    for (int k=0;k<CFArrayGetCount(mresults);k++) {
        NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
        ABRecordRef record=CFArrayGetValueAtIndex(mresults,k);
        ABRecordID recordID=ABRecordGetRecordID(record);
        //读取firstname
        NSString *personName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonFirstNameProperty);
        if(personName != nil){
            [contactDic setObject:personName forKey:@"firstname"];
        }else{
            [contactDic setObject:@"" forKey:@"firstname"];
        }
        //读取lastname
        NSString *lastname = (__bridge NSString*)ABRecordCopyValue(record, kABPersonLastNameProperty);
        if(lastname != nil){
            [contactDic setObject:lastname forKey:@"lastName"];
        }else{
            [contactDic setObject:@"" forKey:@"lastName"];
        }
        //读取middlename
        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(record, kABPersonMiddleNameProperty);
        if(middlename != nil){
            [contactDic setObject:lastname forKey:@"middleName"];
        }else{
            [contactDic setObject:@"" forKey:@"middleName"];
        }
//        //读取prefix前缀
//        NSString *prefix = (__bridge NSString*)ABRecordCopyValue(record, kABPersonPrefixProperty);
//        if(prefix != nil){
//            [contactDic setObject:lastname forKey:@"prefix"];
//        }
//        //读取suffix后缀
//        NSString *suffix = (__bridge NSString*)ABRecordCopyValue(record, kABPersonSuffixProperty);
//        if(suffix != nil){
//            [contactDic setObject:lastname forKey:@"suffix"];
//        }
        ABMultiValueRef phone = ABRecordCopyValue(record, kABPersonPhoneProperty);
        NSMutableArray *phoneArr = [[NSMutableArray alloc] init];
        for(NSInteger j = 0; j < ABMultiValueGetCount(phone); j++){
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, j));
            NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, j);
            NSMutableDictionary *phoneDic = [[NSMutableDictionary alloc] init];
            [phoneDic setValue:tmpPhoneIndex forKey:@"phoneNumber"];
            [phoneDic setValue:personPhoneLabel forKey:@"tag"];
            [phoneArr addObject:phoneDic];
        }
        [contactDic setObject:phoneArr forKey:@"phone"];

        //获取的联系人单一属性:Nickname
        NSString* tmpNickname = (__bridge NSString*)ABRecordCopyValue(record, kABPersonNicknameProperty);
        if(tmpNickname != nil){
            [contactDic setObject:tmpNickname forKey:@"nickName"];
        }else{
            [contactDic setObject:@"" forKey:@"nickName"];
        }
        //获取的联系人单一属性:Company name
        NSString* tmpCompanyname = (__bridge NSString*)ABRecordCopyValue(record, kABPersonOrganizationProperty);
        if(tmpCompanyname !=nil){
            [contactDic setObject:tmpCompanyname forKey:@"companyName"];
        }else{
            [contactDic setObject:@"" forKey:@"companyName"];
        }
        //获取的联系人单一属性:Job Title
        NSString* tmpJobTitle= (__bridge NSString*)ABRecordCopyValue(record, kABPersonJobTitleProperty);
        if(tmpJobTitle !=nil){
            [contactDic setObject:tmpJobTitle forKey:@"jobTitle"];
        }else{
            [contactDic setObject:@"" forKey:@"jobTitle"];
        }
        //获取的联系人单一属性:Department name
        NSString* tmpDepartmentName = (__bridge NSString*)ABRecordCopyValue(record, kABPersonDepartmentProperty);
        if(tmpDepartmentName !=nil){
            [contactDic setObject:tmpDepartmentName forKey:@"department"];
        }else{
            [contactDic setObject:@"" forKey:@"department"];
        }
        //获取的联系人单一属性:Email(s)
        NSMutableArray *emailArr = [[NSMutableArray alloc] init];
        ABMultiValueRef tmpEmails = ABRecordCopyValue(record, kABPersonEmailProperty);
        for(NSInteger j = 0; j<ABMultiValueGetCount(tmpEmails); j++){
            NSString * personEmailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(tmpEmails, j));
            NSString* tmpEmailIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpEmails, j);
            NSMutableDictionary *emailDic = [[NSMutableDictionary alloc] init];
            [emailDic setValue:tmpEmailIndex forKey:@"emailNumber"];
            [emailDic setValue:personEmailLabel forKey:@"tag"];
            [emailArr addObject:emailDic];
        }
        [contactDic setObject:emailArr forKey:@"email"];
        //获取的联系人单一属性:Birthday
        NSDate* tmpBirthday = (__bridge NSDate*)ABRecordCopyValue(record, kABPersonBirthdayProperty);
        if(tmpBirthday !=nil){
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *birthday = [formatter stringFromDate:tmpBirthday];
            [contactDic setObject:birthday forKey:@"birthday"];
        }else{
            [contactDic setObject:@"" forKey:@"birthday"];
        }
        //获取的联系人单一属性:Note
        NSString* tmpNote = (__bridge NSString*)ABRecordCopyValue(record, kABPersonNoteProperty);
        if(tmpNote !=nil){
            [contactDic setObject:tmpNote forKey:@"note"];
        }else{
            [contactDic setObject:@"" forKey:@"note"];
        }
        //获取IM多值
        NSMutableArray *IMArr = [[NSMutableArray alloc] init];
        ABMultiValueRef instantMessage = ABRecordCopyValue(record, kABPersonInstantMessageProperty);
        for (int l = 0; l < ABMultiValueGetCount(instantMessage); l++)
        {
            //获取IM Label
            NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            NSLog(@"instantMessageLabel ==》 %@",instantMessageLabel);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            NSString* IMName = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
            NSMutableDictionary *IMDic = [[NSMutableDictionary alloc] init];
            if(IMName != nil){
                [IMDic setValue:IMName forKey:@"tag"];
            }else{
                [IMDic setValue:@"" forKey:@"tag"];
            }
            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
            if(service != nil){
                [IMDic setValue:IMName forKey:@"service"];
            }else{
                [IMDic setValue:@"" forKey:@"service"];
            }
            [IMArr addObject:IMDic];
        }
        [contactDic setObject:IMArr forKey:@"IM"];
        
        ABMultiValueRef address = ABRecordCopyValue(record, kABPersonAddressProperty);
        long count = ABMultiValueGetCount(address);
        NSMutableArray *addressArr = [[NSMutableArray alloc] init];
        for(int j = 0; j < count; j++)
        {
            NSMutableDictionary *addressDic = [[NSMutableDictionary alloc] init];
            //获取地址Label
            NSString* addressLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(address, j));
            [addressDic setObject:addressLabel forKey:@"tag"];
            //获取該label下的地址6属性
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            if(country != nil){
                [addressDic setObject:country forKey:@"country"];
            }else{
                [addressDic setObject:@"" forKey:@"country"];
            }
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            if(city != nil){
                [addressDic setObject:city forKey:@"city"];
            }else{
                [addressDic setObject:@"" forKey:@"city"];
            }
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            if(state != nil){
                [addressDic setObject:state forKey:@"state"];
            }else{
                [addressDic setObject:@"" forKey:@"state"];
            }
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            if(street != nil){
                [addressDic setObject:street forKey:@"street"];
            }else{
                [addressDic setObject:@"" forKey:@"street"];
            }
            NSString* zipcode = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
            if(zipcode != nil){
                [addressDic setObject:zipcode forKey:@"zipcode"];
            }else{
                [addressDic setObject:@"" forKey:@"zipcode"];
            }
            NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
            if(coutntrycode != nil){
                [addressDic setObject:coutntrycode forKey:@"coutntrycode"];
            }else{
                [addressDic setObject:@"" forKey:@"coutntrycode"];
            }
            [addressArr addObject:addressDic];
        }
        [contactDic setObject:addressArr forKey:@"address"];
        
        //获取URL多值
        ABMultiValueRef url = ABRecordCopyValue(record, kABPersonURLProperty);
        NSMutableArray *urlArr = [[NSMutableArray alloc] init];
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            NSMutableDictionary *urlDic = [[NSMutableDictionary alloc] init];
            //获取url种类
            NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            [urlDic setObject:urlLabel forKey:@"tag"];
            //获取該Label下的值
            NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
            [urlDic setObject:urlContent forKey:@"urlContent"];
            [urlArr addObject:urlDic];
        }
        [contactDic setObject:urlArr forKey:@"url"];
        [allArr addObject:contactDic];
    }
    [allDic setObject:allArr forKey:@"data"];
    NSLog(@"%@",allDic);
}
@end
