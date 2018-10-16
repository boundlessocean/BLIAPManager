//
//  UIView+Add.h
//  TrafficPlatform
//
//  Created by boundlessocean on 2018/4/9.
//  Copyright © 2018年 Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^AnimationCallBack)(void);
typedef void (^CompleteCallBack)(void);
@interface UIView (Add)

+ (__kindof  UIView  *)xm_loadView;

// 动态添加手势
- (void)xm_tapActionWithBlock:(void (^)(void))block;
// 动画
- (void)xm_caseInAnimate;
- (void)xm_caseOutAnimate;
- (void)xm_caseInAnimate:(AnimationCallBack)animate complete:(CompleteCallBack)complete;
- (void)xm_caseOutAnimate:(AnimationCallBack)animate complete:(CompleteCallBack)complete;

// 设置圆角
- (void)xm_setCornerRadius:(NSInteger)cornerRadius;
- (void)xm_setCornerRadius:(UIRectCorner)corners radii:(NSInteger)radii;

// 阴影配置
- (void)xm_shadowConfig;
- (void)xm_shadowRemove;

// 渐变色
- (void)xm_gradientLayer:(UIColor *)fromColor to:(UIColor *)toColor;

// 约束动画回调
- (void)xm_animateCaseIn:(void (^ __nullable)(BOOL finished))completion;
- (void)xm_animateCaseOut:(void (^ __nullable)(BOOL finished))completion;
@end
