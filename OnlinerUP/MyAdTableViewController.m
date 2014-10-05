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
#import "OnlinerUPAppDelegate.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "AFNetworking/AFNetworking.h"
#import "Network.h"
#import "LoginViewController.h"
#import "SVWebViewController.h"
#import "MBProgressHUD.h"
#import "math.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAITrackedViewController.h"

@interface MyAdTableViewController (){
    NSMutableArray *_objects;
    NSMutableArray *_tempObjects;
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
    
    _purchaseController = [[PurchaceViewController alloc]init];
    
    [[SKPaymentQueue defaultQueue]
     addTransactionObserver:_purchaseController];
    
    
    [self loadXpath];
    self.adsCount = @" ";
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForNeedReloadForAdsPage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.sellTypeDictionary = @{@"ba-label ba-label-1":@"label_important.png",
                                    @"ba-label ba-label-2":@"label_sell.png",
                                    @"ba-label ba-label-3":@"label_buy.png",
                                    @"ba-label ba-label-4":@"label_change.png",
                                    @"ba-label ba-label-5":@"label_service.png",
                                    @"ba-label ba-label-6":@"label_rent.png",
                                    @"ba-label ba-label-7":@"label_close.png"};
    
    __weak typeof(self) weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf adsLoading];
//        [weakSelf getStringFromUrl:@"http://baraholka.onliner.by/gapi/messages/unread/" withParams:nil andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
    }];
    [self.tableView.pullToRefreshView setTitle:@"" forState:SVPullToRefreshStateAll];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = [[NSUserDefaults standardUserDefaults] valueForKey:KeyForUserDefaultUserName];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForNeedReloadForAdsPage])
    {
        [_objects removeAllObjects];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if (![_objects count]) {
        [self reloadAd];
    } else [self.tableView reloadData];
    
    //Google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"MyAd Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];

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
    
    cell.categoryLabel.text = myAd.category;
    if ([myAd.commentsCount length] != 0) {
        cell.commentsCountLabel.text = myAd.commentsCount;
        cell.commentsCountLabel.textColor = myAd.isUnRead?[UIColor orangeColor]:[UIColor blackColor];
        cell.commentsCountIcon.image = myAd.isUnRead?[UIImage imageNamed:@"icon_comment_unread"]:[UIImage imageNamed:@"icon_comment.png"];
        [cell.commentsCountLabel setHidden:NO];
        [cell.commentsCountIcon setHidden:NO];
        if (myAd.isUnRead) {
            [cell.contentView.layer setBorderColor:[UIColor orangeColor].CGColor];
            [cell.contentView.layer setBackgroundColor:[UIColor groupTableViewBackgroundColor].CGColor];
        } else {
            [cell.contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
            [cell.contentView.layer setBackgroundColor:[UIColor whiteColor].CGColor];
        }
    } else
    {
        [cell.commentsCountLabel setHidden:YES];
        [cell.commentsCountIcon setHidden:YES];
    }
    cell.sellTypeImage.image = [UIImage imageNamed:[self.sellTypeDictionary objectForKey:myAd.sellType]];
    return cell;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    MyAdTableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:@"Section"];
    [headerView.adCountLabel setText:self.adsCount?[NSString stringWithFormat:@"%@",self.adsCount]:@"Нет объявлений"];
    headerView.avatarImage.image = self.userAvatrarImage;
    headerView.accountAmountLabel.text = self.accountAmount?[NSString stringWithFormat:@"%@ руб. на счету", self.accountAmount]:@"";
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 51.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyAd* myAd = _objects[indexPath.row];
    UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
    CGSize constraintSize = CGSizeMake(251.0f,MAXFLOAT);
    NSString* subject = myAd.title;
    CGSize titleSize = [subject sizeWithFont:titleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return titleSize.height+29;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ads"
                                                          action:@"ads_row_selected"
                                                           label:nil
                                                           value:nil] build]];

    MyAd* ad = [_objects objectAtIndex:indexPath.row];
    if (ad.isUnRead) {
        ad.isUnRead = NO;
        [_objects replaceObjectAtIndex:indexPath.row withObject:ad];
    }
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[NSString stringWithFormat:@"http://baraholka.onliner.by/viewtopic.php?t=%@", ad.topicID]];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Load data
- (void) adsLoading
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // 1
        _tempObjects = [NSMutableArray array];
        self.currentPage = 0;
        [self loadAd];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //google analytics
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ads"
                                                                  action:@"ads_loading"
                                                                   label:@""
                                                                   value:nil] build]];
            _objects = [NSMutableArray array];
            _objects = [[[_tempObjects reverseObjectEnumerator] allObjects] mutableCopy];
            [_tempObjects removeAllObjects];
            [self.tableView reloadData];
            [self.tableView.pullToRefreshView stopAnimating];
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        });
    });
    
}

- (void) reloadAd
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForNeedReloadForAdsPage])
    {
        [_objects removeAllObjects];
        [MBProgressHUD hideHUDForView:self.tableView animated:NO];
        [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
        [self adsLoading];
    }
}

-(void)loadAd {
    NSString* currentPage = self.currentPage>0?[NSString stringWithFormat:@"&start=%d",self.currentPage*50]:@"";
    NSString* urlString = [NSString stringWithFormat:@"http://baraholka.onliner.by/search.php?type=ufleamarket%@",currentPage];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    if (htmlData) {
        self.htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        NSString* adsCount = [Network findTextIn:self.htmlString fromStart:@"(найдено " toEnd:@")<"];
        self.adsCount = adsCount?adsCount:nil;
        NSString* userId = [Network findTextIn:self.htmlString fromStart:@"avatar/48x48/" toEnd:@"\""];
        NSString* userAvatarUrl = [NSString stringWithFormat:@"https://content.onliner.by/user/avatar/80x80/%@",userId];
        self.userAvatrarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userAvatarUrl]]];
        NSString* amount = [[Network findTextIn:self.htmlString fromStart:@"<span id=\"user-balance\">" toEnd: @"</span>"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.accountAmount = amount?amount:@"";
        
        NSString* adsCountStr = [Network findTextIn:self.htmlString fromStart:@"(найдено " toEnd:@" объявл"];
        float adsCountFloat = [adsCountStr floatValue]/50;
        int maxPage = (int)floorf(adsCountFloat);
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KeyForNeedReloadForAdsPage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (self.adsCount) {
            // 2
            TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
            
            // 3
            NSArray *nodes = [parser searchWithXPathQuery:self.xpathQueryString];
            
            // 4
            NSMutableArray *singlePageObjects = [NSMutableArray array];
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
                myAd.category = [[[element searchWithXPathQuery:self.categoryXpath] objectAtIndex:0] text];
                
                if ([[element searchWithXPathQuery:self.commentsCountXpath] count] != 0) {
                    myAd.commentsCount=[[[element searchWithXPathQuery:self.commentsCountXpath] objectAtIndex:0] text];
                    myAd.isUnRead = NO;
                }
                if ([[element searchWithXPathQuery:self.commentsUnreadCountXpath] count] != 0) {
                    myAd.commentsCount=[[[element searchWithXPathQuery:self.commentsUnreadCountXpath] objectAtIndex:0] text];
                    myAd.isUnRead = YES;
                }
                
                myAd.sellType = [[[element searchWithXPathQuery:self.sellTypeXpath] objectAtIndex:0] objectForKey:@"class"];
            }
            
            singlePageObjects = [[[newAd objectEnumerator] allObjects] mutableCopy];
            [_tempObjects addObjectsFromArray:[singlePageObjects mutableCopy]];
            // 8
            
            if (self.currentPage<maxPage) {
                self.currentPage++;
                [self loadAd];
            }
            
        }
        else {
            NSLog(@"Нет объявлений");
        }
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForNeedReloadForAdsPage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)purchaseItem
{
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"inapp"
                                                          action:@"buy_up_all"
                                                           label:@""
                                                           value:nil] build]];
    _purchaseController.productID = @"com.sozdai.OnlinerUP.enableupbutton";
    
    [self.navigationController
     pushViewController:_purchaseController animated:YES];
    _purchaseController.productName = @"unlockUP";
    [_purchaseController getProductInfo:_purchaseController.productID];
}



#pragma mark - Buttons actions

- (IBAction)clickUpAllButton:(UIButton *)sender {
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"inapp"
                                                          action:@"click_up_all"
                                                           label:@""
                                                           value:nil] build]];
    NSInteger clickCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"UpAllClickCount"];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsUpUnlocked] ||  clickCount < 5)
    {
       
        [[NSUserDefaults standardUserDefaults] setInteger:clickCount+1 forKey:@"UpAllClickCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Исчерпан лимит" message:@"Получить полный доступ к 'UP' и 'UP All' кнопкам навсегда?" delegate:self cancelButtonTitle:@"Нет, спасибо" otherButtonTitles:@"Получить", nil];
        [alert show];
    }
}

- (IBAction)avatarImageClick:(UIButton *)sender {
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ads"
                                                          action:@"avatar_image_clicked"
                                                           label:@""
                                                           value:nil] build]];
    
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"https://profile.onliner.by/"];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)buttonUPClick:(UIButton *)sender
{
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ads"
                                                          action:@"click_up"
                                                           label:@""
                                                           value:nil] build]];
    
    self.sender = sender;
    MyAd *currentAd = [_objects objectAtIndex: sender.tag];
    int ballance = [self.accountAmount intValue];
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание, услуга платная!" message:@"Стоимость 3000 рублей" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Поднять", nil];
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
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
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
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка соединения" message:@"Проверьте соединение с интернетом" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
        });
    });
        
}

- (void) upAllFreeAds: (NSArray*) paramsArray
{
    [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
    NSString* token = [Network getHash];
    //3 generate ajax token using date
    NSDate *past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970] * 1000;
    NSString *t = [NSString stringWithFormat:@"%0.0f", oldTime];
    
    NSMutableString* url = [NSMutableString new];
    url = [[NSString stringWithFormat:@"http://baraholka.onliner.by/topics-up.php?t=%@",t] mutableCopy];
    
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setValue:@"0" forKey:@"expectedPrice"];
    for (NSString* topicID in paramsArray) {
        [url appendString:[NSString stringWithFormat:@"&topics[0][]=%@",topicID]];
    }
    [params setValue:token forKey:@"t"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self adsLoading];
//        [self getStringFromUrl:@"http://baraholka.onliner.by/gapi/messages/unread/" withParams:nil andHeaders:@{@"Content-Type":@"text/html; charset=utf-8"}];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка соединения" message:@"Проверьте соединение с интернетом" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.tableView animated:NO];
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Пополнить"])
    {
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"https://profile.onliner.by/account"];
        webViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    else if([title isEqualToString:@"Поднять"])
    {
        [self upAd:self.sender withParams:[_objects objectAtIndex:self.sender.tag]];
    }
    else if([title isEqualToString:@"Получить"])
    {
        [self purchaseItem];
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
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка соединения" message:@"Проверьте соединение с интернетом" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

@end
