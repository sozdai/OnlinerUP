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
#import "MyMessage.h"
#import "ModalWebViewController.h"

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
    
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
    self.navigationItem.leftBarButtonItem.title = @"";
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf getStringFromUrl:@"http://profile.onliner.by/messages/load/"
                        withParams:@{@"f":@"0",
                                     @"p":@"1",
                                     @"t":t}
                        andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
    }];
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateAll];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.tableView triggerPullToRefresh];
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
                myMessage.authorID = [keyMessage valueForKey:@"authorId"];
                myMessage.authorName = [keyMessage valueForKey:@"authorName"];
                myMessage.messageID = [keyMessage valueForKey:@"id"];
                myMessage.date = [[keyMessage valueForKey:@"time"] doubleValue] ;
                myMessage.isRead = [[keyMessage valueForKey:@"unread"] boolValue];
            }
            _objects = [[[newMessage reverseObjectEnumerator] allObjects] mutableCopy];
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error connection %@",error);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.pullToRefreshView stopAnimating];
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
    cell.leftUtilityButtons = [self leftButtons];
    cell.rightUtilityButtons = [self rightButtons];
    cell.delegate = self;
    
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

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"More"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
                                                icon:[UIImage imageNamed:@"check.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"cross.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}

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
@end
