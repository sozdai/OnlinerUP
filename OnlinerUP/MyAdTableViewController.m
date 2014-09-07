//
//  MyAdTableViewController.m
//  OnlinerUP
//
//  Created by Alex on 20.07.14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import "MyAdTableViewController.h"
#import "TFHpple.h"
#import "MyAd.h"
#import "MyAdTableViewCell.h"
#import "ModalWebViewController.h"
#import "OnlinerUPAppDelegate.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "AFNetworking/AFNetworking.h"
#import "Network.h"
#import "LoginViewController.h"

@interface MyAdTableViewController (){
    NSMutableArray *_objects;
}

@end

@implementation MyAdTableViewController

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
    [self loadXpath];
    
    self.sellTypeDictionary = @{@"ba-label ba-label-1":@"label_important.png",
                                    @"ba-label ba-label-2":@"label_sell.png",
                                    @"ba-label ba-label-3":@"label_buy.png",
                                    @"ba-label ba-label-4":@"label_change.png",
                                    @"ba-label ba-label-5":@"label_service.png",
                                    @"ba-label ba-label-6":@"label_rent.png",
                                    @"ba-label ba-label-7":@"label_close.png"};
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf loadAd];
        [weakSelf getStringFromUrl:@"http://baraholka.onliner.by/gapi/messages/unread/" withParams:nil andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
    }];
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateAll];
    [self.tableView triggerPullToRefresh];
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

- (void) getStringFromUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*) headers
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
   // manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    for(id key in headers)
    {
        NSString* value = [headers objectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.messagesCount = operation.responseString;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.messagesCount = @"";
    }];
}

- (void) loadXpath
{
    self.xpathQueryString = @"//td[@class='frst ph colspan']/..";
    self.upButtonXpath = @"//div[@class='b-up-section-5 arrow-right']/a";
    self.urlXpath = @"href";
    self.topicIDXpath = @"topicid";
    self.topicPriceXpath = @"expectedprice";
    self.topicTypeXpath = @"type";
    self.titleXpath = @"//h2[@class='wraptxt']/a";
    self.timeLeftXpath = @"//*[@class='time']";
    self.imageUrlXpath = @"http://content.onliner.by/baraholka/icon/";
    self.categoryXpath = @"//a[@class='gray-link']";
    self.commentsCountXpath = @"//a[@class='c-read-replies-count']";
    self.commentsUnreadCountXpath = @"//a[@class='c-org']";
    self.sellTypeXpath = @"//div[@class='txt-i']/div";
    self.messagesCountXpath = @"//*[@class='new_privmsg_count']";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MyAdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    MyAd *myAd = [_objects objectAtIndex: indexPath.row];
    cell.textView.text = myAd.title;
    cell.upButton.tag = indexPath.row;
    [cell.upButton setBackgroundImage:[UIImage imageNamed: [NSString stringWithFormat: @"btn-up-%@.png",myAd.topicType]] forState:(UIControlStateNormal)];
    BOOL type = [myAd.topicType intValue];
    if (type) {
        [cell.upButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        [cell.upButton setTitle: [NSString stringWithFormat:@"%@", myAd.timeLeft ] forState:UIControlStateNormal];
    } else
    {
        [cell.upButton setTitleColor: [UIColor colorWithRed:167/255.0f green:51/255.0f blue:0/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [cell.upButton setTitle: @"UP" forState:UIControlStateNormal];
    }
    
    cell.adImage.image = [UIImage imageWithData:myAd.imageData];
    cell.categoryLabel.text = myAd.category;
    if ([myAd.commentsCount length] != 0) {
        cell.commentsCountLabel.text = myAd.commentsCount;
        cell.commentsCountLabel.textColor = myAd.isRead?[UIColor blackColor]:[UIColor orangeColor];
        cell.commentsCountIcon.image = myAd.isRead?[UIImage imageNamed:@"icon_comment.png"]:[UIImage imageNamed:@"icon_comment_unread"];
        [cell.commentsCountLabel setHidden:NO];
        [cell.commentsCountIcon setHidden:NO];
    } else
    {
        [cell.commentsCountLabel setHidden:YES];
        [cell.commentsCountIcon setHidden:YES];
    }
    cell.sellTypeImage.image = [UIImage imageNamed:[self.sellTypeDictionary objectForKey:myAd.sellType]];
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([_objects count]) {
        MyAdTableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:@"Section"];
        NSString* countText = [Network findTextIn:self.htmlString fromStart:@"найдено " toEnd:@")"];
        [countText length]?[headerView.adCountLabel setText:countText]:[headerView.adCountLabel setText:@"Нет объявлений"];
        
        self.navigationItem.title = [Network findTextIn:self.htmlString fromStart:@"onliner__user__name\"><a href=\"https://profile.onliner.by/\">" toEnd:@"</a>"];
        [headerView.envelopeButton setTitle:[NSString stringWithFormat:@" %@",self.messagesCount] forState:UIControlStateNormal];
        headerView.accountAmountLabel.text = [NSString stringWithFormat:@"%@ руб. на счету", [Network getBallance] ];
        return headerView;
    } else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 51.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 51.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModalWebViewController *controller = (ModalWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalWebViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    MyAd* ad = [_objects objectAtIndex:indexPath.row];
    
    controller.title = @"Объявление";
    controller.url = [NSString stringWithFormat:@"http://baraholka.onliner.by/viewtopic.php?t=%@", ad.topicID];
}

#pragma mark - Load data

- (void) getMessCount
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://baraholka.onliner.by/gapi/messages/unread/"]];
    
    NSMutableData *body = [NSMutableData data];
    request.HTTPBody = body;
    request.HTTPMethod = @"GET";
    [request setValue:@"text/plain, */*; q=0.01" forHTTPHeaderField:@"Accept"];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!theConnection) NSLog(@"No connection");
}

-(void)loadAd {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // 1
        NSURL *url = [NSURL URLWithString:@"http://baraholka.onliner.by/search.php?type=ufleamarket"];
        NSData *htmlData = [NSData dataWithContentsOfURL:url];
        self.htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        // 2
        TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
        
        // 3
        NSArray *nodes = [parser searchWithXPathQuery:self.xpathQueryString];
        
        // 4
        NSMutableArray *newAd = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *element in nodes) {
            // 5
            MyAd *myAd = [MyAd new];
            [newAd addObject:myAd];
            
            // 7
            TFHppleElement* elementUP = [[element searchWithXPathQuery:self.upButtonXpath] objectAtIndex:0];
            
            myAd.url = [elementUP objectForKey:self.urlXpath];
            myAd.topicID = [elementUP objectForKey:self.topicIDXpath];
            myAd.topicPrice = [elementUP objectForKey:self.topicPriceXpath];
            myAd.topicType = [elementUP objectForKey:self.topicTypeXpath];
            // 6
            myAd.title = [[[element searchWithXPathQuery:self.titleXpath] objectAtIndex:0] text];
            if ([myAd.topicType isEqualToString:@"1"]) {
                NSString* tl = [NSString stringWithFormat:@"s%@", [[[element searchWithXPathQuery:self.timeLeftXpath] objectAtIndex:0] text]];
                if ([tl rangeOfString:@"час" options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    myAd.timeLeft = [NSString stringWithFormat:@"%@ ч", [Network findTextIn:tl fromStart:@"s" toEnd:@" час"]];
                } else
                {
                    myAd.timeLeft = [NSString stringWithFormat:@"%@ м", [Network findTextIn:tl fromStart:@"s" toEnd:@" мин"]];
                }
                //[self findTextIn:tl fromStart:@"" toEnd:@" "];
            }
            myAd.imageUrl = [NSString stringWithFormat:@"%@%@",self.imageUrlXpath,myAd.topicID];
            myAd.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: myAd.imageUrl]];
            myAd.category = [[[element searchWithXPathQuery:self.categoryXpath] objectAtIndex:0] text];
            
            if ([[element searchWithXPathQuery:self.commentsCountXpath] count] != 0) {
                myAd.commentsCount=[[[element searchWithXPathQuery:self.commentsCountXpath] objectAtIndex:0] text];
                myAd.isRead = YES;
            }
            
            if ([[element searchWithXPathQuery:self.commentsUnreadCountXpath] count] != 0) {
                myAd.commentsCount=[[[element searchWithXPathQuery:self.commentsUnreadCountXpath] objectAtIndex:0] text];
                myAd.isRead = NO;
            }
            
            myAd.sellType = [[[element searchWithXPathQuery:self.sellTypeXpath] objectAtIndex:0] objectForKey:@"class"];
            
        }
        
        // 8
        _objects = [[[newAd reverseObjectEnumerator] allObjects] mutableCopy];
        [self getMessCount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.pullToRefreshView stopAnimating];
            [self.tableView reloadData];
        });
    });
    
}


#pragma mark - Buttons actions

- (IBAction)clickUpAllButton:(UIButton *)sender {
    
    NSArray* params = [self getIDsWithType0];
    if (![params count] == 0) {
        [self upAllFreeAds:params];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Нет объявлений" message:@"Не осталось объявлений чтобы поднять бесплатно" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (IBAction)refreshButtonClick:(UIButton *)sender {
    [self loadAd];
}

- (IBAction)buttonUPClick:(UIButton *)sender
{
    self.sender = sender;
    MyAd *currentAd = [_objects objectAtIndex: sender.tag];
    int ballance = [[Network getBallance] intValue];
    int type = [currentAd.topicType intValue];
    
    if (type == 0) {
        [self upAd:sender withParams:currentAd];
    }
    else if (ballance < 3000)
    {
        int needDeposit = 3000 - ballance;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Вам не хватает %d рублей", needDeposit] message:@"Пополнить счет?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Пополнить", nil];
        [alert show];
    } else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание услуга платная!" message:@"Стоимость 3000 рублей" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Поднять", nil];
        [alert show];
    }
}

- (NSArray*) getIDsWithType0
{
    MyAd *currentAd = [MyAd new];
    NSMutableArray* params = [NSMutableArray array];
    for (currentAd in _objects) {
        if ([currentAd.topicType isEqualToString:@"0"]) {
            [params addObject:currentAd.topicID];
        }
    }
    return [params mutableCopy];
}

- (void) upAd: (UIButton*) sender withParams: (MyAd*) currentAd
{
    NSString* token = [Network getHash];
    //3 generate ajax token using date
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
    
    NSString* url = [NSString stringWithFormat:@"http://baraholka.onliner.by/topics-up.php?t=%@", t];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:currentAd.topicPrice forKey:@"expectedPrice"];
    
    if ([currentAd.topicPrice isEqualToString:@"0"])
    {
        [params setValue:currentAd.topicID forKey:@"topics[0][]"];
    } else
    {
        [params setValue:currentAd.topicID forKey:@"topics[1][]"];
    }
    [params setValue:token forKey:@"t"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [sender setBackgroundImage:[UIImage imageNamed: [NSString stringWithFormat: @"btn-up-1.png"]] forState:(UIControlStateNormal)];
        [sender setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        [sender setTitle:@"20 ч" forState:UIControlStateNormal];
        currentAd.timeLeft = @"20 ч";
        currentAd.topicType = @"1";
        currentAd.topicPrice = @"3000";
        [_objects replaceObjectAtIndex:sender.tag withObject:currentAd];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@, %@",error, error.userInfo);
    }];
        
}

- (void) upAllFreeAds: (NSArray*) paramsArray
{
    NSString* token = [Network getHash];
    //3 generate ajax token using date
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
    
    NSString* url = [NSString stringWithFormat:@"http://baraholka.onliner.by/topics-up.php?t=%@",t];
    NSMutableDictionary* params = [NSMutableDictionary new];
    
    [params setValue:@"0" forKey:@"expectedPrice"];
    [params setObject:paramsArray forKey:@"topics[0][]"];
    [params setValue:token forKey:@"t"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.tableView triggerPullToRefresh];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@, %@",error, error.userInfo);
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Пополнить"])
    {
        ModalWebViewController *controller = (ModalWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalWebViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:nil];
    
        controller.title = @"Пополнить счет";
        controller.url = @"https://profile.onliner.by/account";
    }
    else if([title isEqualToString:@"Поднять"])
    {
        [self upAd:self.sender withParams:[_objects objectAtIndex:self.sender.tag]];
    }
}

#pragma mark - Connection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.task = [NSString stringWithFormat:@"%@",response];
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Ошибка соединения");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Success");
    
    
}

@end
