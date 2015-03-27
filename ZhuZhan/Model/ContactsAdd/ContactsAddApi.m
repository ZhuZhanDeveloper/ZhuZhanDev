//
//  ContactsAddApi.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/26.
//
//

#import "ContactsAddApi.h"
#import "ConnectionAvailable.h"
#import "JSONKit.h"
@implementation ContactsAddApi
+ (NSURLSessionDataTask *)ContactsAddWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block arr:(NSMutableArray*)arr noNetWork:(void(^)())noNetWork{
    if (![ConnectionAvailable isConnectionAvailable]) {
        return nil;
    }
    
    NSString* str=[arr JSONString];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
     [dataDic setObject:str forKey:@"data"];
    NSString *urlStr = [NSString stringWithFormat:@"api/Contacts/ContactsAdd"];
  //  NSString *urlStr = [NSString stringWithFormat:@"contact"];
    return [[AFAppDotNetAPIClient sharedClient] POST:urlStr parameters:dataDic success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSLog(@"JSON===>%@",JSON);
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        NSLog(@"error ==> %@",error);
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
}
@end
