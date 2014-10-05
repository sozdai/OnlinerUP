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
                if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsUpUnlocked]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.userInteractionEnabled = NO;
                }
                
            } else
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForShouldShowAp]) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsAdsRemoved]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.userInteractionEnabled = NO;
                    }
                    [cell setHidden:NO];
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
        _purchaseController.productID = @"com.sozdai.OnlinerUP.enableupbutton";
        _purchaseController.productName = @"enableUP";
        [_purchaseController getProductInfo:_purchaseController.productID];

    } else{
        _purchaseController.productID = @"com.sozdai.OnlinerUP.remads";
        _purchaseController.productName = @"removeAds";    }
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"inapp"
                                                          action:@"purchase_item"
                                                           label:_purchaseController.productName
                                                           value:nil] build]];
}

#pragma mark - Feedback

- (void) sendEmail
{
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"feedback"
                                                          action:@"send_email"
                                                           label:nil
                                                           value:nil] build]];
    // Email Subject
    NSString *emailTitle = @"Барахолка";
    // Email Content
    NSString *messageBody = @"Здравствуйте, ";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObjects:@"sasha@kardash.by",nil];
    
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
        case MFMailComposeResultCancelled:{
            //google analytics
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"feedback"
                                                                  action:@"email_canceled"
                                                                   label:nil
                                                                   value:nil] build]];
            break;}
        case MFMailComposeResultSaved:
        {
            //google analytics
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"feedback"
                                                                  action:@"email_saved"
                                                                   label:nil
                                                                   value:nil] build]];
            break;}
        case MFMailComposeResultSent:{
            //google analytics
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"feedback"
                                                                  action:@"email_sent"
                                                                   label:nil
                                                                   value:nil] build]];
            break;}
        case MFMailComposeResultFailed:
        {
            //google analytics
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"feedback"
                                                                  action:@"email_failed"
                                                                   label:nil
                                                                   value:nil] build]];
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
