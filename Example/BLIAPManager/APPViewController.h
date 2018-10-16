//
//  APPViewController.h
//  BLIAPManager
//
//  Created by boundlessocean@icloud.com on 10/14/2018.
//  Copyright (c) 2018 boundlessocean@icloud.com. All rights reserved.
//

@import UIKit;

#import "BLIAPManager.h"
@interface APPViewController : UIViewController

/**
 通知服务器校验凭证
 */
+ (void)IAP_requestCheakReceipt:(BLIAPTransactionOrder *)transactionOrder;
@end
@interface MTRechargeModel : NSObject
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString * money;
@property (nonatomic, strong) NSString *goldcoin;
@end
