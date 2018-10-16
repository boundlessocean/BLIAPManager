//
//  APPViewController.m
//  BLIAPManager
//
//  Created by boundlessocean@icloud.com on 10/14/2018.
//  Copyright (c) 2018 boundlessocean@icloud.com. All rights reserved.
//

#import "APPViewController.h"
#import "MJExtension.h"
#import "NetWork/NetWork+Brief.h"
#import "MTDiamondView.h"
#import "UIView+Add.h"
#import "Masonry.h"
@interface APPViewController ()

@property (nonatomic, strong) NSMutableArray <MTRechargeModel *>*dataSource;
@end

#define URL_webServer(url) [NSString stringWithFormat:@"%@%@", api_webserver,url]
#define api_webserver @"http://apm.jingcaishuo.net"

// 充值
#define api_pay_price @"/user/v1/charge_types"
// 支付参数获取
#define api_pay_recharge @"/user/v1/charge"
// 生产订单
#define api_pay_order @"/user/v1/order_prepare"
@implementation APPViewController
{
    NSInteger _selectIndex;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [NetWork GET_URL:URL_webServer(api_pay_price)
        parameterDic:@{@"client":@"IOS"}
        successBlock:^(NSDictionary *responseObject) {
            _dataSource = [MTRechargeModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
            [self IAP_cheakProduct];
        } failureBlock:nil];
}

- (IBAction)charge:(id)sender {
    [self IAP_requestOrder];
}



#pragma mark - - In-App Purchase
/**
 检查产品合规性
 */
- (void)IAP_cheakProduct{
    NSMutableSet *data = [NSMutableSet setWithCapacity:0];
    for (MTRechargeModel *model in _dataSource) {
        [data addObject:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:model.money]];
    }
    [[BLIAPManager shareIAPManager] cheakProducts:data
                                         complete:^(NSArray<SKProduct *> *products,
                                                    NSArray<NSString *> *invalidProductIdentifiers,
                                                    BLIAPError error) {
                                             if (error) {
//                                                 [Tool showTextHUD:@"未能连接到iTunes store" andView:self.view];
                                             } else if(invalidProductIdentifiers.count){
                                                 NSMutableArray *data = [NSMutableArray arrayWithCapacity:0];
                                                 for (NSString *name in invalidProductIdentifiers) {
                                                     [data addObject:[name stringByReplacingOccurrencesOfString:[NSBundle mainBundle].bundleIdentifier withString:@""]];
                                                 }
                                                 _dataSource = [[_dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (money IN %@)",data]] mutableCopy];
                                                 [self p_updateData];
                                             } else {
                                                 [self p_updateData];
                                             }
                                         }];
}

/**
 生成订单
 */
- (void)IAP_requestOrder{
    NSMutableDictionary *parameters = [@{@"chargeTypeId" : @(_dataSource[_selectIndex].id).stringValue,
                                         @"paymentType" : @"6"}
                                       mutableCopy];
    if (@"没有登录") {
        [parameters setObject:BLIAPManager.deviceUDID forKey:@"deviceNo"];
    }
    [NetWork POST_URL:URL_webServer(api_pay_order)
         parameterDic:parameters
         successBlock:^(NSDictionary *responseObject) {
             if ([responseObject[@"code"] integerValue] == 100000) {
                 NSString *orderID = responseObject[@"data"][@"order"][@"orderId"];
                 NSString *orderJson =  [@{@"oderID":orderID,
                                           @"chargeTypeId":@(_dataSource[_selectIndex].id).stringValue}
                                         mj_JSONString];
                 [self IAP_requestItunesPayment:orderJson];
             }
         } failureBlock:nil];
}


/**
 向iTunes发起交易
 */
- (void)IAP_requestItunesPayment:(NSString *)orderJson{
    NSString *product = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString:_dataSource[_selectIndex].money];
    [[BLIAPManager shareIAPManager] requestPayment:orderJson
                                productIdentifiers:product
                                          complete:^(BLIAPTransactionOrder *transactionOrder,
                                                     BLIAPError error)
     {
         if (transactionOrder.receiptData && transactionOrder.oderJson) {
             [self.class IAP_requestCheakReceipt:transactionOrder];
         } else if (error){
             switch (error) {
                 case BLIAPErrorUnableFindProduct:{
//                     [Tool showTextHUD:@"没有找到该产品" andView:self.view];
                     break;
                 }
                 case BLIAPErrorCheakIAPState:{
//                     [Tool showTextHUD:@"用户未开启内购功能" andView:self.view];
                     break;
                 }
                 case BLIAPErrorTransactionStateFailed:{
//                     [Tool showTextHUD:@"交易失败" andView:self.view];
                     break;
                 }
                 default:
                     break;
             }
         }
     }];
}

/**
 通知服务器校验凭证
 */
+ (void)IAP_requestCheakReceipt:(BLIAPTransactionOrder *)transactionOrder{
    NSDictionary *order = [transactionOrder.oderJson mj_JSONObject];
    NSMutableDictionary *parameters = [@{@"chargeTypeId" : order[@"chargeTypeId"],
                                         @"paymentType" : @"6",
                                         @"order" : order[@"oderID"],
                                         @"appleCertification" : transactionOrder.receiptData}
                                       mutableCopy];
    if (@"没有登录") {
        [parameters setObject:BLIAPManager.deviceUDID forKey:@"deviceNo"];
    }
    [NetWork POST_URL:URL_webServer(api_pay_recharge)
         parameterDic:parameters
         successBlock:^(NSDictionary *responseObject) {
             if ([responseObject[@"code"] integerValue] == 100000) {
                 [BLIAPManager finishTransaction:transactionOrder.oderJson];
             } else if ([responseObject[@"code"] integerValue] == 100602){
                 [BLIAPManager finishTransaction:transactionOrder.oderJson];
                 NSInteger code = [[responseObject[@"msg"] mj_JSONObject][@"status"] integerValue];
                 switch (code) {
                     case 21002:
                     case 21003:
                     case 21010:
//                         [Tool showTextHUD:@"收据无法获得授权" andView:self.view];
                         break;
                     default:
//                         [Tool showTextHUD:@"服务器当前不可用" andView:self.view];
                         break;
                 }
             }
         } failureBlock:nil];
}

#pragma mark - - Private

- (void)p_updateData{
    CGFloat width = 106;
    CGFloat height = 61;
    CGFloat spaceX = (UIScreen.mainScreen.bounds.size.width - 3*width)/4;
    CGFloat spaceY = 20;
    CGFloat viewH = 0;
    for (int i = 0; i < _dataSource.count; i++) {
        MTDiamondView *view = [MTDiamondView xm_loadView];
        view.model = _dataSource[i];
        if (i == 0) view.select = YES;
        [view xm_tapActionWithBlock:^{
            view.select = YES;
            _selectIndex = i;
            for (int i = 0; i < _dataSource.count; i++) {
                if (_dataSource[i].id != view.model.id) {
                    MTDiamondView *view = [self.view viewWithTag:_dataSource[i].id + 100];
                    view.select = NO;
                }
            }
        }];
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo((i%3 + 1)*spaceX + (i%3)*width);
            make.top.mas_equalTo(i/3*height + (i/3+1)*spaceY);
            make.size.mas_equalTo(CGSizeMake(width, height));
        }];
        viewH = i/3*height + (i/3+1)*spaceY + height;
    }
}

@end

@implementation MTRechargeModel

@end
