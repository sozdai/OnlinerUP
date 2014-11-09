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

#define YOUR_APP_STORE_ID 564204730 //Change this one to your ID

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
//    self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
    NSString* version = [[NSUserDefaults standardUserDefaults] valueForKey:KeyForConfigVersion];
    if (version) {
        self.versionLabel.text = [NSString stringWithFormat:@"v %@",[[NSUserDefaults standardUserDefaults] valueForKey:KeyForConfigVersion]];
    }
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return 3;
            break;
            
        case 1:
            return 2;
            break;
            
        case 3:
            return 1;
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
            switch (indexPath.row) {
                    
                case 1:
                    [self sendEmail];
                    break;
                    
                case 2:
                    
                     // Would contain the right link
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id923025320"]];
                    break;
            }
            
            
        }
            break;
            
        case 1:
        {
            
            [self purchaseItem:indexPath.row];
        }
            break;
        
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    BOOL topicTitle = [[NSUserDefaults standardUserDefaults] boolForKey:@"topicTitle"];
                    [[NSUserDefaults standardUserDefaults] setBool:!topicTitle forKey:@"topicTitle"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [tableView reloadData];
                }
                    break;
                default:
                    break;
            }
        }
            
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
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 0)
            {
                NSInteger clickCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"UpAllClickCount"];
                  if ( clickCount >= [[[[[NSUserDefaults standardUserDefaults] objectForKey:KeyForConfig] objectForKey:@"settings"] valueForKey:@"upAllClickCount"] intValue]) {
                      if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsUpUnlocked]) {
                          cell.accessoryType = UITableViewCellAccessoryCheckmark;
                          cell.selectionStyle = UITableViewCellSelectionStyleNone;
                          cell.userInteractionEnabled = NO;
                      }
                  } else
                      [cell setHidden:YES];
                      break;
                
            } else
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForShouldShowAd]) {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsAdsRemoved]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.userInteractionEnabled = NO;
                    }
                } else
                [cell setHidden:YES];
                break;
            }
        }
        case 2:
        {
            if (indexPath.row == 0)
            {
                BOOL topicTitle = [[NSUserDefaults standardUserDefaults] boolForKey:@"topicTitle"];
                if (topicTitle) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
            break;
            
        default:
            break;
    };
 }

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return 114.0f;
                    break;
                case 1:
                    return 32.0f;
                    break;
                case 2:
                    return 32.0f;
                    break;
                    
                default:
                    break;
            }
        case 1:
            switch (indexPath.row) {
                case 0:{
                    NSInteger clickCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"UpAllClickCount"];
                    if ( clickCount < [[[[[NSUserDefaults standardUserDefaults] objectForKey:KeyForConfig] objectForKey:@"settings"] valueForKey:@"upAllClickCount"] intValue]) {
                        return 0.0f;
                        break;
                    }
                }
                    break;
                case 1:{
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:KeyForShouldShowAd]) {
                        return 0.0f;
                        break;
                    }
                }
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return 32.0f;
}

#pragma mark - in-app purchaces

- (void)purchaseItem:(long) index
{
    [self.navigationController
     pushViewController:_purchaseController animated:YES];
    if (index == 0) {
        _purchaseController.productTitle.text = @"Загрузка...";
        _purchaseController.productDescription.text = @"";
        _purchaseController.buyButton.enabled = NO;
        _purchaseController.restoreButton.enabled = NO;
        _purchaseController.productID = @"com.sozdai.OnlinerUP.enableupbutton";
        _purchaseController.productName = @"enableUP";
        [_purchaseController getProductInfo:_purchaseController.productID];

    } else{
        _purchaseController.productTitle.text = @"Загрузка...";
        _purchaseController.productDescription.text = @"";
        _purchaseController.buyButton.enabled = NO;
        _purchaseController.restoreButton.enabled = NO;
        _purchaseController.productID = @"com.sozdai.OnlinerUP.remads";
        _purchaseController.productName = @"removeAds";
        [_purchaseController getProductInfo:_purchaseController.productID];
    }
    
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Успешно отправлено" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil, nil];
            [alert show];
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
