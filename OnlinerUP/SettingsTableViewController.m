//
//  SettingsTableViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 9/26/14.
//
//

#import "SettingsTableViewController.h"
#import "Network.h"
#import "OnlinerUPAppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAITrackedViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _purchaseController = [[PurchaceViewController alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return 1;
            break;
            
        case 1:
            return 2;
            break;
            
        default:
            return 1;
            break;
    };
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
        {
            [self sendEmail];
            
        }
            break;
            
        case 1:
        {
            
            [self purchaseItem:indexPath.row];
        }
            break;
            
        default:
            break;
    };
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch(indexPath.section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 0)
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsAdsRemoved]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInteractionEnabled = NO;
                }
                
            } else
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsUpUnlocked]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInteractionEnabled = NO;
                }
            }
        }
            break;
            
        default:
            break;
    };
 }

#pragma mark - in-app purchaces

- (void)purchaseItem:(long) index
{
    [self.navigationController
     pushViewController:_purchaseController animated:YES];
    if (index == 0) {
        _purchaseController.productID = @"com.sozdai.OnlinerUP.remads";
        _purchaseController.productName = @"removeAds";
    } else{
        _purchaseController.productID = @"com.sozdai.OnlinerUP.enableupbutton";
        _purchaseController.productName = @"enableUP";
    }
    [_purchaseController getProductInfo:_purchaseController.productID];
}



//
//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    SKProduct *validProduct = nil;
//    int count = [response.products count];
//    if(count > 0){
//        validProduct = [response.products objectAtIndex:0];
//        NSLog(@"Products Available!");
//        [self purchase:validProduct];
//    }
//    else if(!validProduct){
//        NSLog(@"No products available");
//        //this is called if your product id is not valid, this shouldn't be called unless that happens.
//    }
//}
//    
//- (void)purchase:(SKProduct *)product{
//    SKPayment *payment = [SKPayment paymentWithProduct:product];
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}
//
//- (void)restore
//{
//    //this is called when the user restores purchases, you should hook this up to a button
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//}
//
//- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
//{
//    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
//    for (SKPaymentTransaction *transaction in queue.transactions)
//    {
//        if(SKPaymentTransactionStateRestored){
//            NSLog(@"Transaction state -> Restored");
//            //called when the user successfully restores a purchase
//            if ([self.InappName isEqualToString:@"removeAds"]) {
//                [self doRemoveAds];
//            } else [self doUnlockUp];
//            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            break;
//        }
//        
//    }
//    
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
//    for(SKPaymentTransaction *transaction in transactions){
//        switch (transaction.transactionState){
//            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
//                //called when the user is in the process of purchasing, do not add any of your own code here.
//                break;
//            case SKPaymentTransactionStatePurchased:
//                //this is called when the user has successfully purchased the package (Cha-Ching!)
//                if ([self.InappName isEqualToString:@"removeAds"]) {
//                    [self doRemoveAds];
//                } else [self doUnlockUp];
//                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                if ([self.InappName isEqualToString:@"removeAds"]) {
//                    [self doRemoveAds];
//                } else [self doUnlockUp];
//                NSLog(@"Transaction state -> Purchased");
//                break;
//            case SKPaymentTransactionStateRestored:
//                NSLog(@"Transaction state -> Restored");
//                //add the same code as you did from SKPaymentTransactionStatePurchased here
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                if ([self.InappName isEqualToString:@"removeAds"]) {
//                    [self doRemoveAds];
//                } else [self doUnlockUp];
//                break;
//            case SKPaymentTransactionStateFailed:
//                //called when the transaction does not finnish
//                if(transaction.error.code != SKErrorPaymentCancelled){
//                    NSLog(@"Transaction state -> Cancelled");
//                    //the user cancelled the payment ;(
//                }
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//        }
//    }
//}
//
//- (void)doRemoveAds{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForIsAdsRemoved];
//    //use NSUserDefaults so that you can load wether or not they bought it
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self.tableView reloadData];
//}
//
//- (void)doUnlockUp
//{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForIsUpUnlocked];
//    //use NSUserDefaults so that you can load wether or not they bought it
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [self.tableView reloadData];
//}


#pragma mark - Feedback

- (void) sendEmail
{
    // Email Subject
    NSString *emailTitle = @"Барахолка";
    // Email Content
    NSString *messageBody = @"Здравствуйте, ";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObjects:@"sasha@kardash.by",@"sash.kardash@gmail.com",nil];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка отправки" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
