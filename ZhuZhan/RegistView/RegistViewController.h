//
//  RegistViewController.h
//  ZpzchinaMobile
//
//  Created by 汪洋 on 14-6-18.
//  Copyright (c) 2014年 汪洋. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol registViewDelegate <NSObject>

-(void)registComplete;

@end

@interface RegistViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    UITextField *_phoneNumberTextField;
    UITextField *_yzmTextField;
    UITextField *passWordField;
    UITextField *verifyPassWordField;
    UITextField *accountField;
}
@property(nonatomic,strong)id<registViewDelegate>delegate;
@end
