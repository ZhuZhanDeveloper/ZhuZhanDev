//
//  ContactsAddApi.h
//  ZhuZhan
//
//  Created by 汪洋 on 15/3/26.
//
//

#import <Foundation/Foundation.h>

@interface ContactsAddApi : NSObject
+ (void)ContactsAddWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block arr:(NSMutableArray*)arr noNetWork:(void(^)())noNetWork;
@end
