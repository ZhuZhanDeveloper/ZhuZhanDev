//
//  FourthAnimationView.m
//  AnimationDemo
//
//  Created by 孙元侃 on 14/12/8.
//  Copyright (c) 2014年 wy. All rights reserved.
//

#import "FourthAnimationView.h"
#import "GetImagePath.h"
#define Height (kScreenHeight==480?412:500)
@interface FourthAnimationView ()
@property(nonatomic,strong)UIImageView *image;
@property(nonatomic,strong)UIButton *inViewBtn;
@property(nonatomic)BOOL animationEnd;
@end

@implementation FourthAnimationView

static int j;
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        self.image = [[UIImageView alloc] initWithFrame:self.frame];
        self.image.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.image];
        j=1;
        self.image.image = [GetImagePath getImagePath:@"040001"];
    }
    return self;
}
-(void)startAnimation{
    if (!self.animationEnd) {
        [self.delegate startAnimation];

        self.animationEnd=YES;
        j=1;
        [self addImage:j];
    }
}
-(void)addImage:(int)index{
    UIScrollView* scrollView=(UIScrollView*)self.superview;
    [scrollView setContentOffset:CGPointMake(960, 0)];
    if(index <=25){
        if(index<10){
            self.image.image = [GetImagePath getImagePath:[NSString stringWithFormat:@"04000%d",index]];
        }else{
            self.image.image = [GetImagePath getImagePath:[NSString stringWithFormat:@"0400%d",index]];
        }
        j++;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self addImage:j];
        });
    }else{
        self.inViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.inViewBtn.frame = CGRectMake(100, Height, 120, 50);
        [self.inViewBtn addTarget:self action:@selector(dismis) forControlEvents:UIControlEventTouchUpInside];
        //[self.inViewBtn setBackgroundColor:[UIColor yellowColor]];
        [self addSubview:self.inViewBtn];
        [self.delegate endAnimation];
    }
}

-(void)dismis{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"dismis" object:nil];
}
@end
