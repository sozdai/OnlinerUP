//
//  SettingsTableViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 9/26/14.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>

@interface SettingsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate,SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;

@property (assign, nonatomic) BOOL adsRemoved;
@property (assign, nonatomic) BOOL upUnlocked;
@property (strong, nonatomic) NSString* InappName;

- (void)purchase:(SKProduct *)product;
- (void)restore;
- (void)tapsRemoveAdsButton;


- (void) sendEmail;


@end
