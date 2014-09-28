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
#import "PurchaceViewController.h"

@interface SettingsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) PurchaceViewController *purchaseController;

- (void)purchaseItem:(long) index;
- (void) sendEmail;


@end
