//
//  ContactsAddApi.m
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/26.
//
//

#import "ContactsAddApi.h"
#import "ConnectionAvailable.h"
@implementation ContactsAddApi
+ (NSURLSessionDataTask *)ContactsAddWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block arr:(NSMutableArray*)arr noNetWork:(void(^)())noNetWork{
    if (![ConnectionAvailable isConnectionAvailable]) {
        return nil;
    }
    NSString *urlStr = [NSString stringWithFormat:@"api/Contacts/ContactsAdd"];
    return [[AFAppDotNetAPIClient sharedNewClient] POST:urlStr parameters:arr success:^(NSURLSessionDataTask * __unused task, id JSON) {
        NSLog(@"JSON Focused===>%@",JSON);
        if([[NSString stringWithFormat:@"%@",JSON[@"d"][@"status"][@"statusCode"]]isEqualToString:@"1300"]){
            NSMutableArray *mutablePosts = [[NSMutableArray alloc] init];
            [mutablePosts addObject:JSON[@"d"][@"data"]];
            if (block) {
                block([NSMutableArray arrayWithArray:mutablePosts], nil);
            }
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        NSLog(@"error ==> %@",error);
        if (block) {
            block([NSMutableArray array], error);
        }
    }];
}
@end
