//
//  MyMessagesTableViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 8/21/14.
//
//

#import "MyMessagesTableViewController.h"
#import "MyMessagesTableViewCell.h"
#import "AFNetworking.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "MyMessage.h"
#import "ModalWebViewController.h"
#import "Network.h"
#import "LoginViewController.h"

@interface MyMessagesTableViewController (){
    NSMutableArray *_objects;
}

@end

@implementation MyMessagesTableViewController

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
    
    __weak typeof(self) weakSelf = self;
    self.url = @"http://profile.onliner.by/messages/load/";
    self.folder = @"0";
    self.page = 1;
    [self.tableView addPullToRefreshWithActionHandler:^{
        NSDate *past = [NSDate date];
        NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
        NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
//        self.navigationItem.leftBarButtonItem.title = @"";
        
        [weakSelf getStringFromUrl:weakSelf.url
                        withParams:@{@"f":weakSelf.folder,
                                     @"p":[NSString stringWithFormat:@"%d", weakSelf.page],
                                     @"t":t}
                        andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf performInfinityScroll];
    }];
    
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateAll];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (![_objects count]) {
        [self.tableView triggerPullToRefresh];
    } else [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load data
- (void) loadMessages
{
    
}

- (void) getStringFromUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*) headers
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        [_objects removeAllObjects];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        for(id key in headers)
        {
            NSString* value = [headers objectForKey:key];
            [manager.requestSerializer setValue:value forHTTPHeaderField:key];
        }
        
        [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSMutableArray *newMessage = [[NSMutableArray alloc] initWithCapacity:0];
            
            NSDictionary* messages = [responseObject objectForKey:@"messages"];
            NSArray* keyArray = [messages allKeys];
            keyArray = [keyArray sortedArrayUsingComparator:^(id a, id b) {
                return [a compare:b options:NSNumericSearch];
            }];
            for (id key in keyArray) {
                MyMessage *myMessage = [MyMessage new];
                [newMessage addObject:myMessage];
                
                NSDictionary* keyMessage = [messages objectForKey:key];
                
                myMessage.subject = [keyMessage valueForKey:@"subject"];
                myMessage.folder = [keyMessage valueForKey:@"folder"];
                if ([self.folder isEqualToString:@"-1"]) {
                    myMessage.authorID = [keyMessage valueForKey:@"recipientId"];
                    myMessage.authorName = [keyMessage valueForKey:@"recipientName"];
                } else{
                    myMessage.authorID = [keyMessage valueForKey:@"authorId"];
                    myMessage.authorName = [keyMessage valueForKey:@"authorName"];
                }
                myMessage.messageID = [keyMessage valueForKey:@"id"];
                myMessage.date = [[keyMessage valueForKey:@"time"] doubleValue] ;
                myMessage.isRead = [[keyMessage valueForKey:@"unread"] boolValue];
            }
            if (self.page == 1) {
                _objects = [NSMutableArray array];
                [_objects removeAllObjects];
            }
            
            [_objects addObjectsFromArray: [[[newMessage reverseObjectEnumerator] allObjects] mutableCopy]];
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error connection %@",error);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView.infiniteScrollingView stopAnimating];
        });
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_objects count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MyMessagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MyMessage *myMessage = [_objects objectAtIndex: indexPath.section];
    cell.subjectTextField.text = myMessage.subject;
    
    // Configure the cell...
    
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *CellIdentifier = @"Section";
    MyMessagesTableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    MyMessage *myMessage = [_objects objectAtIndex: section];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    
    [headerView.envelopeImage setImage:[UIImage imageNamed:myMessage.isRead?@"envelope_unread":@"envelope_read"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-yy HH:mm"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:myMessage.date];
    headerView.dateLabel.text = [dateFormatter stringFromDate:date];
    
    [headerView.authorButton setTitle:myMessage.authorName forState:UIControlStateNormal];
    headerView.authorButton.tag = section;
    return headerView;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyMessage* myMessage = _objects[indexPath.section];
    NSString *subject = [myMessage valueForKey:@"subject"];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
    CGSize constraintSize;
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
        constraintSize = CGSizeMake(304.0f,MAXFLOAT);
    } else
    {
        constraintSize = CGSizeMake(465.0f,MAXFLOAT);
    }
    CGSize textSize = [subject sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return textSize.height+9;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyMessage* myMessage = _objects[indexPath.section];
    
    ModalWebViewController *controller = (ModalWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalWebViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    controller.title = myMessage.subject;
    controller.url = [NSString stringWithFormat:@"http://profile.onliner.by/messages#%@/%@",myMessage.folder,myMessage.messageID];

}

//- (NSArray *)rightButtons
//{
//    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                title:@"More"];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
//                                                title:@"Delete"];
//    
//    return rightUtilityButtons;
//}
//
//- (NSArray *)leftButtons
//{
//    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
//    
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"check.png"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"clock.png"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"cross.png"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"list.png"]];
//    
//    return leftUtilityButtons;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)authorButtonClick:(UIButton *)sender {
    
    MyMessage* myMessage = _objects[sender.tag];
    
    ModalWebViewController *controller = (ModalWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalWebViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    controller.title = myMessage.authorName;
    controller.url = [NSString stringWithFormat:@"https://profile.onliner.by/user/%@",myMessage.authorID];
}

- (IBAction)actionButtonClick:(UIBarButtonItem *)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:
                            @"Входящие",
                            @"Отправленные",
                            @"Сохраненные",
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:{
                   self.folder = @"0";
                    self.page=1;
                    [self.tableView triggerPullToRefresh];
                    self.navigationItem.title = @"Входящие";
                    break;}
                case 1:{
                    self.folder = @"-1";
                    self.page=1;
                    [self.tableView triggerPullToRefresh];
                    self.navigationItem.title = @"Отправленные";
                    break;}
                case 2:{
                    self.folder = @"1";
                    self.page=1;
                    [self.tableView triggerPullToRefresh];
                    self.navigationItem.title = @"Сохраненные";
                    break;}
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void) performInfinityScroll
{
    if (![_objects count]) {
        [self.tableView.infiniteScrollingView stopAnimating];
    } else
    {
        if ([_objects count] >= 50) {
            self.page++;
        }
        [self.tableView triggerPullToRefresh];
    }
}
@end
