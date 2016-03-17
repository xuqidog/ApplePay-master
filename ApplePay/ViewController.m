//
//  ViewController.m
//  ApplePay
//
//  Created by 邢行 on 16/3/15.
//  Copyright © 2016年 XingHang. All rights reserved.
//

/*
 Apple Pay接入流程：
 1.申请 Merchant ID  (在苹果开发者中心)
 2.创建 APP ID <打开Apple Pay功能>
   并关联Merchant ID (在苹果开发者中心)
 3.在工程 的 Capabilites 打开Apple Pay 的功能 选择该工程 相对应的 Merchant ID
 4. 导入 PassKit 框架 进行开发
 */

#import "ViewController.h"
#import <PassKit/PassKit.h>


#define ApplePayId @"merchant.com.applePay.good2"


@interface ViewController () <PKPaymentAuthorizationViewControllerDelegate>

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    PKPaymentButton *payButton = [[PKPaymentButton alloc] initWithPaymentButtonType:PKPaymentButtonTypeBuy paymentButtonStyle:PKPaymentButtonStyleBlack];
    payButton.frame = CGRectMake(0, 0, 300, 44);
    payButton.center = self.view.center;
    [self.view addSubview:payButton];
    
    [payButton addTarget:self
                  action:@selector(pay:)
        forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)pay:(id)sender{
    
    if(![PKPaymentAuthorizationViewController canMakePayments]) {
        NSLog(@"PKPayment can make payments");
        return;
    }
    
    NSLog(@"开始支付了");
    
    PKPaymentRequest *payment = [[PKPaymentRequest alloc] init];
    
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
    
//    PKPaymentSummaryItem *total2 = [PKPaymentSummaryItem summaryItemWithLabel:@"Total" amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
    
    payment.paymentSummaryItems = @[
                                    total,
//                                    total2,
                                    ];
    
    
    // 人民币
    payment.currencyCode = @"CNY";
    
    // 中国
    payment.countryCode = @"CN";
    
    // 在 developer.apple.com member center 里设置的 merchantID
    payment.merchantIdentifier = ApplePayId;
    
    // Fixbug: 原来设置为 `PKMerchantCapabilityCredit` 在真机上无法回调 `didAuthorizePayment` 方法
    payment.merchantCapabilities =
    PKMerchantCapability3DS |
    PKMerchantCapabilityEMV |
    PKMerchantCapabilityCredit |
    PKMerchantCapabilityDebit;
    
    // 支持哪种结算网关
    //    extern NSString * const PKPaymentNetworkAmex NS_AVAILABLE(NA, 8_0);
    //    extern NSString * const PKPaymentNetworkChinaUnionPay NS_AVAILABLE(NA, 9_2);
    //    extern NSString * const PKPaymentNetworkDiscover NS_AVAILABLE(NA, 9_0);
    //    extern NSString * const PKPaymentNetworkInterac NS_AVAILABLE(NA, 9_2);
    //    extern NSString * const PKPaymentNetworkMasterCard NS_AVAILABLE(NA, 8_0);
    //    extern NSString * const PKPaymentNetworkPrivateLabel NS_AVAILABLE(NA, 9_0);
    //    extern NSString * const PKPaymentNetworkVisa NS_AVAILABLE(NA, 8_0);
    payment.supportedNetworks = @[
                                  PKPaymentNetworkChinaUnionPay,
                                  PKPaymentNetworkAmex,
                                  PKPaymentNetworkDiscover,
                                  PKPaymentNetworkInterac,
                                  PKPaymentNetworkMasterCard,
                                  PKPaymentNetworkPrivateLabel,
                                  PKPaymentNetworkVisa,
                                  ];
    
    NSLog(@"payment: %@", payment);
    payment.requiredBillingAddressFields = PKAddressFieldEmail | PKAddressFieldPostalAddress;
    
    PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:payment];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:NULL];
    
    
    
}



#pragma mark- 主要代理
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSLog(@"did authorize payment token: %@, %@", payment.token, payment.token.transactionIdentifier);
    
    completion(PKPaymentAuthorizationStatusSuccess);
}


#pragma mark- 取消支付
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"finish");
    [controller dismissViewControllerAnimated:controller completion:NULL];
}






-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingContact:(PKContact *)contact completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {
    NSLog(@"didSelectShippingContact");
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {
    NSLog(@"didSelectShippingMethod");
}

- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"paymentAuthorizationViewControllerWillAuthorizePayment");
    
    
}



/*
 2016-03-15 21:19:08.566 ApplePay[9340:4924166] 开始支付了
 2016-03-15 21:19:08.567 ApplePay[9340:4924166] payment: <PKPaymentRequest: 0x15c67dbe0>
 2016-03-15 21:21:46.221 ApplePay[9340:4924166] paymentAuthorizationViewControllerWillAuthorizePayment
 2016-03-15 21:21:56.591 ApplePay[9340:4924166] did authorize payment token: <PKPaymentToken: 0x15c5b46b0; transactionIdentifier: 0B86C6D28187A0BBFF94476E24D3BD5B67482204B67C6CBEA96516463991F675; paymentData: 4606 bytes>, 0B86C6D28187A0BBFF94476E24D3BD5B67482204B67C6CBEA96516463991F675
 2016-03-15 21:21:58.213 ApplePay[9340:4924166] finish
 */


/** 
 29.1 应用程序在使用苹果支付必须提供所有物资采购信息到用户之前销售的任何货物或服务，或他们将被拒绝;应用程序在使用苹果  支付提供定期付款必须至少透露续约期限和它将继续，直到取消，这一事实的长度，什么将在每个期间，会给客户，以及如何取消收费的收费提供。
 29.2 应用程序在使用苹果支付必须正确使用苹果支付的品牌和用户界面元素以及苹果支付身份指南中所述，否则他们拒绝的
 29.3 应用程序在使用苹果公司支付采购机制可能不提供商品或服务的违法的任何领土好或服务将交付和可能不能用于任何非法目的 
 29.4 应用程序使用苹果支付必须提供隐私策略或他们将被拒绝的 
 29.5 应用程序在使用苹果支付可能只分享获得通过苹果支付与第三方提供任何便利或提高交付的商品和服务，或遵守法律要求的用户数据*/

@end
