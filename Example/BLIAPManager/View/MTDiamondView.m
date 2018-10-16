//
//  MTDiamondView.m
//  mrtc
//
//  Created by boundlessocean on 2018/9/25.
//  Copyright © 2018年 xycentury. All rights reserved.
//

#import "MTDiamondView.h"
@interface MTDiamondView ()
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UILabel *diamond;
@end
@implementation MTDiamondView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
}

- (void)setTag:(NSInteger)tag{
    [super setTag:tag];
}

- (void)setSelect:(BOOL)select{
    _select = select;
    if (_select) {
        self.layer.borderColor = [UIColor grayColor].CGColor;
        _money.textColor = [UIColor redColor];
        _diamond.textColor = [UIColor redColor];
    } else {
        self.layer.borderColor = [UIColor blackColor].CGColor;
        _money.textColor = [UIColor blackColor];
        _diamond.textColor = [UIColor blackColor];
    }
}

- (void)setModel:(MTRechargeModel *)model{
    _model = model;
    self.tag = _model.id + 100;
    _money.text = [_model.money stringByAppendingString:@"元"];
    _diamond.text = [_model.goldcoin stringByAppendingString:@"钻石"];
}

@end
