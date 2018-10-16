//
//  NMErrorCode.h
//  NMWalletAPP
//
//  Created by boundlessocean on 2017/4/21.
//  Copyright © 2017年 Lemon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NMErrorCode : NSObject
+ (NSString *)descriptionWithErrorCode:(NSInteger)code;
@end
