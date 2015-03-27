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
+(void)ContactsAddWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block arr:(NSMutableArray*)arr noNetWork:(void(^)())noNetWork{
    if ([ConnectionAvailable isConnectionAvailable]) {
        //NSString* str=[arr JSONString];
        NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
        [dataDic setObject:arr forKey:@"data"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //申明返回的结果是json类型
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //申明请求的数据是json类型
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        //如果报接受类型不一致请替换一致text/html或别的
        //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        //你的接口地址
        NSString *url=[NSString stringWithFormat:@"%sapi/Contacts/ContactsAdd",serverAddress];
        //发送请求
        [manager POST:url parameters:dataDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}
@end
