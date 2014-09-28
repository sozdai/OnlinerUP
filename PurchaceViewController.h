//
//  PurchaceViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 9/28/14.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "OnlinerUPAppDelegate.h"

@interface PurchaceViewController : UIViewController
<SKPaymentTransactionObserver, SKProductsRequestDelegate>


@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productPrice;

@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UITextView *productDescription;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *restoreButton;
- (IBAction)buyProduct:(id)sender;
- (IBAction)restoreProduct:(id)sender;
- (void)getProductInfo:(NSString*) ProductID;

@end
