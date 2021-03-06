//
//  ProductModel.h
//  ZhuZhan
//
//  Created by 汪洋 on 14-9-4.
//
//

#import <Foundation/Foundation.h>

@interface ProductModel : NSObject
@property (nonatomic,strong) NSString *a_id;
//名字
@property (nonatomic,strong) NSString *a_name;
//内容
@property (nonatomic,strong) NSString *a_content;
//图片
@property (nonatomic,strong) NSString *a_imageUrl;
//评论数
@property (nonatomic,strong) NSString *a_createdBy;
@property (nonatomic,strong) NSString *a_commentNumber;
@property (nonatomic, strong) NSString *a_imageWidth;
@property (nonatomic, strong) NSString *a_imageHeight;
@property (nonatomic, strong) NSString *a_avatarUrl;
@property (nonatomic, strong) NSString *a_userName;
@property (nonatomic, strong) NSString *a_isFocused;
@property(nonatomic,strong)NSString* a_userType;
@property (nonatomic, strong) NSDictionary *dict;



//获取产品
+ (NSURLSessionDataTask *)GetProductInformationWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block startIndex:(int)startIndex noNetWork:(void(^)())noNetWork;

//添加产品
+ (NSURLSessionDataTask *)AddProductInformationWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork;

//发布产品信息
+ (NSURLSessionDataTask *)PublishProductInformationWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork;

//关注产品
+ (NSURLSessionDataTask *)AddProductFocusWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork;

//取消关注
+ (NSURLSessionDataTask *)DeleteProductionUserFocusWithBlock:(void (^)(NSMutableArray *posts, NSError *error))block dic:(NSMutableDictionary *)dic noNetWork:(void(^)())noNetWork;
@end
