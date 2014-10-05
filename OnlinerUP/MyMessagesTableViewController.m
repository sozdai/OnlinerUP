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
#import "Network.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "SVWebViewController.h"
#import "OnlinerUPAppDelegate.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAITrackedViewController.h"


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
    self.shouldMoveUp = YES;
    self.title = @"Входящие";
    [self.tableView addPullToRefreshWithActionHandler:^{
        weakSelf.page = 1;
        [weakSelf loadMessages];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf performInfinityScroll];
    }];
    
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateAll];
}

-(void) viewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForNeedReloadForMessagesPage])
    {
        [_objects removeAllObjects];
        [self.tableView reloadData];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KeyForNeedReloadForMessagesPage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    self.shouldMoveUp = NO;
    self.page = 1;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self loadMessages];
    
    //Google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Messages Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load data
- (void) loadMessages
{
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
    [self getStringFromUrl:self.url
                withParams:@{@"f":self.folder,
                             @"p":[NSString stringWithFormat:@"%d", self.page],
                             @"t":t}
                andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
}

- (void) reloadMessages
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
            
            self.newMessagesCount = 0;
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
                myMessage.isUnRead = [[keyMessage valueForKey:@"unread"] boolValue];
                
                if ([self.folder isEqualToString:@"0"] && myMessage.isUnRead) {
                    self.newMessagesCount++;
                }
            }
            if (self.page == 1) {
                _objects = [NSMutableArray array];
                [_objects removeAllObjects];
            }
            
            [_objects addObjectsFromArray: [[[newMessage reverseObjectEnumerator] allObjects] mutableCopy]];
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
            if (self.page == 1 && self.shouldMoveUp) {
                [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }

            if (self.newMessagesCount) {
                self.navigationItem.title = [NSString stringWithFormat:@"%@ (%d)", self.title, self.newMessagesCount];
            } else self.navigationItem.title = self.title;
            
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (self.page == 1)
            {
            _objects = [NSMutableArray array];
                [self.tableView reloadData];
            }
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
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
    
    [headerView.envelopeImage setImage:[UIImage imageNamed:myMessage.isUnRead?@"envelope_unread":@"envelope_read"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-yy HH:mm"];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:myMessage.date];
    headerView.dateLabel.text = [dateFormatter stringFromDate:date];
    
    [headerView.authorButton setTitle:myMessage.authorName forState:UIControlStateNormal];
    headerView.authorButton.tag = section;
    
    switch (section%4) {
        case 0:
            headerView.backgroundColor = [UIColor colorWithRed:0.98 green:0.878 blue:0.867 alpha:1];
            break;
        case 1:
            headerView.backgroundColor = [UIColor colorWithRed:0.878 green:0.929 blue:0.965 alpha:1];
            break;
        case 2:
            headerView.backgroundColor = [UIColor colorWithRed:0.89 green:0.949 blue:0.827 alpha:1];
            break;
        case 3:
            headerView.backgroundColor = [UIColor colorWithRed:0.988 green:0.925 blue:0.851 alpha:1];
            break;
            
        default:
            headerView.backgroundColor = [UIColor colorWithRed:(232/255.0) green:(101/255.0) blue:(86/255.0) alpha:1.0];
            break;
    }
    
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
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"http://profile.onliner.by/messages#%@/%@",myMessage.folder,myMessage.messageID]];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)authorButtonClick:(UIButton *)sender {
    
    MyMessage* myMessage = _objects[sender.tag];
    
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"https://profile.onliner.by/user/%@",myMessage.authorID]];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
    
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
                    self.shouldMoveUp = YES;
                    NSDate *past = [NSDate date];
                    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
                    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
                    
                    [self getStringFromUrl:self.url
                                    withParams:@{@"f":self.folder,
                                                 @"p":[NSString stringWithFormat:@"%d", self.page],
                                                 @"t":t}
                                    andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
                    self.title = @"Входящие";
                    break;}
                case 1:{
                    self.folder = @"-1";
                    self.page=1;
                    self.shouldMoveUp = YES;
                    NSDate *past = [NSDate date];
                    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
                    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
                    
                    [self getStringFromUrl:self.url
                                withParams:@{@"f":self.folder,
                                             @"p":[NSString stringWithFormat:@"%d", self.page],
                                             @"t":t}
                                andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
                    self.title = @"Отправленные";
                    break;}
                case 2:{
                    self.folder = @"1";
                    self.page=1;
                    self.shouldMoveUp = YES;
                    NSDate *past = [NSDate date];
                    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
                    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
                    
                    [self getStringFromUrl:self.url
                                withParams:@{@"f":self.folder,
                                             @"p":[NSString stringWithFormat:@"%d", self.page],
                                             @"t":t}
                                andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
                    self.title = @"Сохраненные";
                    break;}
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"messages"
                                                          action:@"open_message_folder"
                                                           label:self.title
                                                           value:nil] build]];
}

- (void) performInfinityScroll
{
    self.shouldMoveUp = NO;
    if (![_objects count]) {
        [self.tableView.infiniteScrollingView stopAnimating];
    } else
    {
        if ([_objects count] >= 50) {
            self.page++;
        }
        [self loadMessages];
    }
    
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"messages"
                                                          action:@"infinity_scroll"
                                                           label:self.title
                                                           value:nil] build]];
}
@end
