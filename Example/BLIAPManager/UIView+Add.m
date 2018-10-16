//
//  UIView+Add.m
//  TrafficPlatform
//
//  Created by boundlessocean on 2018/4/9.
//  Copyright © 2018年 Lemon. All rights reserved.
//

#import "UIView+Add.h"
#import <objc/runtime.h>

static char topNameKey;
static char rightNameKey;
static char bottomNameKey;
static char leftNameKey;
static const char *ActionHandlerTapGestureKey;

@implementation UIView (Add)
+ (UIView *)xm_loadView{
   return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil].firstObject;
}

- (void)xm_setCornerRadius:(NSInteger)cornerRadius{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
}

- (void)xm_caseInAnimate{
    [self xm_caseInAnimate:nil complete:nil];
}

- (void)xm_caseOutAnimate{
    [self xm_caseOutAnimate:nil complete:nil];
}

- (void)xm_caseInAnimate:(AnimationCallBack)animate complete:(CompleteCallBack)complete{
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        !animate ? : animate();
    } completion:^(BOOL finished) {
        !complete ? : complete();
    }];
}

- (void)xm_caseOutAnimate:(AnimationCallBack)animate complete:(CompleteCallBack)complete{
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
        !animate ? : animate();
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        !complete ? : complete();
    }];
}







- (void)xm_tapActionWithBlock:(void (^)(void))block{
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
    
    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    
    objc_setAssociatedObject(self, &ActionHandlerTapGestureKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized)  {
        void(^action)(void) = objc_getAssociatedObject(self, &ActionHandlerTapGestureKey);
        if (action)  {
            action();
        }
    }
}


- (void)bl_setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left
{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)b_enlargedRect
{
    NSNumber *topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber *rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber *bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber *leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge) {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    }
    else
    {
        return self.bounds;
    }
}


- (void)xm_setCornerRadius:(UIRectCorner)corners radii:(NSInteger)radii{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height) byRoundingCorners:corners cornerRadii:CGSizeMake(radii, radii)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)xm_shadowConfig{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.1;
}

- (void)xm_shadowRemove{
    self.layer.shadowOpacity = 0;
}

- (void)xm_gradientLayer:(UIColor *)fromColor to:(UIColor *)toColor{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor, (__bridge id)toColor.CGColor];
    gradientLayer.locations = @[@0.0, @0.5, @1.0];
    gradientLayer.frame = self.bounds;
    gradientLayer.startPoint = CGPointMake(0, .5);
    gradientLayer.endPoint = CGPointMake(1, .5);
    [self.layer addSublayer:gradientLayer];
}


- (void)xm_animateCaseIn:(void (^ __nullable)(BOOL finished))completion{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         [self layoutIfNeeded];
     } completion:^(BOOL finished) {
         if (completion) {
             completion(finished);
         }
         
     }];
}

- (void)xm_animateCaseOut:(void (^ __nullable)(BOOL finished))completion{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         [self layoutIfNeeded];
     } completion:^(BOOL finished) {
         if (completion) {
             completion(finished);
         }
         
     }];
}

@end
