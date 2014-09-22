//
//  BaraholkaTableViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 8/23/14.
//
//

#import "BaraholkaTableViewController.h"
#import "BaraholkaTableViewCell.h"
#import "BaraholkaFullTableViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "Baraholka.h"
#import "Network.h"
#import "TFHpple.h"
#import "ModalWebViewController.h"
#import "OnlinerUPAppDelegate.h"

@interface BaraholkaTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
{
    NSMutableArray *_objects;
    NSMutableArray *_categories;
}

@end

@implementation BaraholkaTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFullCell = NO;
    self.category = @"";
    [self loadCategories];
    self.currentBaraholkaPage = 0;
    self.sellType = @{@"1":@"label_important.png",
                      @"2":@"label_sell.png",
                      @"3":@"label_buy.png",
                      @"4":@"label_change.png",
                      @"5":@"label_service.png",
                      @"6":@"label_rent.png",
                      @"7":@"label_close.png"};
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;

    
    [self.searchDisplayController.searchResultsTableView addInfiniteScrollingWithActionHandler:^{
        
    [self performInfinityScroll];
        
    }];
    [self loadXpath];
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:@"http://kardash.by/config.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@, %@",error, error.userInfo);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [self.searchDisplayController.searchResultsTableView reloadData];
    if (![Network isAuthorizated]) {
        [self.loginButton setTitle:@"Вход"];
        [[self.tabBarController tabBar] setHidden:YES];
    } else
    {
        [self.loginButton setTitle:@"Выход"];
        [[self.tabBarController tabBar] setHidden:NO];
    }
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    [self.searchDisplayController.searchBar setShowsCancelButton:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count;
    if (tableView == self.tableView) {
        count = [_categories count];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count;
    if (tableView == self.tableView) {
        count = [[[[[_categories objectAtIndex:section] allValues] objectAtIndex:0] valueForKey:@"items"] count];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        count = [_objects count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isFullCell) {
        BaraholkaFullTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FullCell"];
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_objects count] != 0) {
                Baraholka *myBaraholkaTotic = [Baraholka new];
                myBaraholkaTotic = [_objects objectAtIndex:indexPath.row];
                if (myBaraholkaTotic.isHighlighted) {
                    [cell.titleLabel setTextColor:[UIColor redColor]];
                    [cell.contentView.layer setBorderColor:[UIColor orangeColor].CGColor];
                    [cell.contentView.layer setBorderWidth:1.0f];
                }
                cell.titleLabel.text = myBaraholkaTotic.title;
                cell.descriptionLabel.text = myBaraholkaTotic.description;
                cell.sellTypeImage.image = [UIImage imageNamed:[self.sellType objectForKey:myBaraholkaTotic.sellType]];
                cell.cityLabel.text = myBaraholkaTotic.city;
                if (myBaraholkaTotic.price) {
                    cell.priceLabel.text = [NSString stringWithFormat:@"%@ %@", myBaraholkaTotic.price, myBaraholkaTotic.currency];
                } else cell.priceLabel.text = @"";
                cell.torgLabel.text = myBaraholkaTotic.isTorg;
                cell.baraholkaImage.image = [UIImage imageWithData:myBaraholkaTotic.imageData];
                cell.categoryLabel.text = myBaraholkaTotic.category;
                if (myBaraholkaTotic.commentsCount) {
                    
                    cell.commentsLabel.text = myBaraholkaTotic.commentsCount;
                }
                else
                {
                    [cell.commentsImage setHidden:YES];
                    [cell.commentsLabel setHidden:YES];
                }
            }
        }
        return cell;
    }
    else {
        BaraholkaTableViewCell *cell;
        if (tableView == self.tableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
            cell.titleLabel.text = [[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] allKeys ]objectAtIndex:indexPath.row];
        }
        else if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
            if ([_objects count] != 0) {
                Baraholka *myBaraholkaTotic = [Baraholka new];
                myBaraholkaTotic = [_objects objectAtIndex:indexPath.row];
            
                cell.titleLabel.text = myBaraholkaTotic.title;
                cell.cityLabel.text = myBaraholkaTotic.city;
                cell.priceLabel.text = myBaraholkaTotic.price;
                cell.sellTypeImage.image = [UIImage imageNamed:[self.sellType objectForKey:myBaraholkaTotic.type]];
                cell.torgLabel.text = myBaraholkaTotic.isTorg;
//                [cell setBackgroundColor:[UIColor colorWithRed:255.f green:0.f blue:0.f alpha:0.05]];
            }
        }
            return cell;
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* title = @"";
    if (tableView == self.tableView) {
        if ([_categories count]) {
            title = [[[_categories objectAtIndex:section] allKeys] objectAtIndex:0];
        }
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (!self.isFullCell)
        {
           title = @"Быстрый поиск";
        } else if ([self.category length]) {
            title = self.categoryTitle;
        } else
        {
            title = @"Все категории";
        }
    }
        return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    
    
    myLabel.frame = CGRectMake(8, 0, 312, 20);
    myLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    myLabel.textColor = [UIColor darkGrayColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (self.isFullCell) {
        
        if (tableView == self.tableView) {
            
        }
        else if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            Baraholka* myBaraholka = [_objects objectAtIndex:indexPath.row];
            NSString* subject = myBaraholka.title;
            NSString* description = myBaraholka.description;
            UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
            UIFont *descriptionFont = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
            CGSize constraintSize;
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
                constraintSize = CGSizeMake(304.0f,MAXFLOAT);
            } else
            {
                constraintSize = CGSizeMake(464.0f,MAXFLOAT);
            }
            
            CGSize titleSize = [subject sizeWithFont:titleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            CGSize descriptionSize = [description sizeWithFont:descriptionFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            
            height = titleSize.height+descriptionSize.height+58;
        }
        
        
        
    }
    else {
        if (tableView == self.tableView) {
            UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:15.0f];
            CGSize constraintSize = CGSizeMake(304.0f,MAXFLOAT);
            NSString* subject = [[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] allKeys ]objectAtIndex:indexPath.row];
            CGSize titleSize = [subject sizeWithFont:titleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            height = titleSize.height+10;
        }
        else if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            Baraholka* myBaraholka = [_objects objectAtIndex:indexPath.row];
            NSString* subject = myBaraholka.title;
            UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
            CGSize constraintSize;
            if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
                constraintSize = CGSizeMake(304.0f,MAXFLOAT);
            } else
            {
                constraintSize = CGSizeMake(464.0f,MAXFLOAT);
            }
            CGSize textSize = [subject sizeWithFont:titleFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
            height = textSize.height+34;
        }
    }
    
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        NSString* categoryName = [[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] allKeys ]objectAtIndex:indexPath.row];
        [self.searchDisplayController setActive: YES animated: YES];
        self.searchDisplayController.searchBar.hidden = NO;
        [self.searchDisplayController.searchBar becomeFirstResponder];
        self.category = [NSString stringWithFormat:@"&f=%@", [[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] valueForKey:categoryName] valueForKey:@"f"]];
        self.categoryTitle = [[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] allKeys ]objectAtIndex:indexPath.row];
        [self baraholkaFullSearch:@""];
    }
    else {
        ModalWebViewController *controller = (ModalWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalWebViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:nil];
        
        Baraholka* myBaraholka = [_objects objectAtIndex:indexPath.row];
        
        controller.title = @"Объявление";
        controller.url = [NSString stringWithFormat:@"http://baraholka.onliner.by/viewtopic.php?t=%@", myBaraholka.topicID];
    }
}

#pragma mark - SearchBar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![self.category length]) {
        self.currentBaraholkaPage = 0;
        [self baraholkaQuickSearch:searchBar.text];

    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentBaraholkaPage = 0;
    [self baraholkaFullSearch:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.category = @"";
    self.categoryTitle = @"";
    self.isFullCell = NO;
    [_objects removeAllObjects];
    [searchBar setShowsCancelButton:NO];
    [self.tableView reloadData];
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
//    // We need to prevent the resultsTable from hiding if the search is still active
    if (self.searchDisplayController.active == YES) {
        tableView.hidden = NO;
    }
    if (self.isFullCell && [self.category length]) {
        [self baraholkaFullSearch:@""];
    } else [_objects removeAllObjects];
    [tableView reloadData];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
    controller.searchResultsTableView.hidden = NO;
    [controller.searchResultsTableView setContentInset:UIEdgeInsetsMake(64,
                                                                        controller.searchResultsTableView.contentInset.left,
                                                                        controller.searchResultsTableView.contentInset.bottom+48,
                                                                        controller.searchResultsTableView.contentInset.right)];
    [self.searchDisplayController.searchResultsTableView reloadData];
    
    // Then we need to remove the semi transparent overlay which is here
    for (UIView *v in [[[controller.searchResultsTableView superview] superview] subviews]) {
        
        if (v.frame.origin.y == 64) {
            [v setHidden:YES];
        }
    }
    
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [controller.searchResultsTableView setContentInset:UIEdgeInsetsMake(64,
                                                                        controller.searchResultsTableView.contentInset.left,
                                                                        controller.searchResultsTableView.contentInset.bottom-48,
                                                                        controller.searchResultsTableView.contentInset.right)];
}




#pragma mark - load data

- (void) loadXpath
{
    
    self.xpathQueryString=@"//td[@class='frst ph colspan']/..";
    
    self.listCategoryXpath=@"//div[@class='cm-onecat']";
    self.listCategoryLinkXpath=@"//small/a";
    self.listItemXpath=@"//li";
    self.listItemLinkXpath=@"//a";
    self.listItemCount=@"//sup";
    
    self.topicTypeXpath=@"m-imp";
    self.titleXpath=@"//h2[@class='wraptxt']/a";
    self.descriptionXpath=@"//*[@class='wraptxt']/../p[2]";
    self.categoryXpath=@"//a[@class='gray-link']";
    self.sellTypeXpath=@"//div[@class='txt-i']/div";
    self.cityXpath=@"//p[@class='ba-signature']/strong";
    self.topicIDXpath=@"href";
    self.urlXpath=@"href";
    
    self.topicPriceXpath=@"//td[@class='cost']/big/strong";
    self.topicCurrencyXpath=@"//td[@class='cost']/big";
    self.topicTorgXpath = @"//small[@class='cost-torg']";
    
    self.topicAuthorXpath=@"//a[@class='gray']";
    self.imageUrlXpath=@"http://content.onliner.by/baraholka/icon_large/";
    self.commentsCountXpath=@"//p[@class='ba-post-coms']/a/span";
    
    self.upTopicTime=@"//p[@class='ba-post-up']";
}

#pragma mark - Search
-(void) baraholkaQuickSearch: (NSString*) searchText
{
    [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
    if (![searchText isEqualToString:@""]) {
        [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.isFullCell = NO;
        [Network getUrl:@"http://baraholka.onliner.by/gapi/search/baraholka/topic.json" withParams:@{@"s":searchText} andHeaders:nil andSerializer:@"JSON" :^(NSArray* responseObject,NSString *responseString, NSError *error) {
            NSMutableArray *newBaraholkaTopic= [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray* responseArray = [[NSArray arrayWithArray:responseObject] mutableCopy];
            if (![responseString isEqualToString:@"[]"]) {
                [responseArray removeObjectAtIndex:0];
            }
            for (id key in responseArray) {
                Baraholka *myBaraholkaTotic = [Baraholka new];
                [newBaraholkaTopic addObject:myBaraholkaTotic];
                NSString* link = [key valueForKey:@"link"];
                myBaraholkaTotic.title = [[[[[[Network findTextIn:link fromStart:@"<strong>" toEnd:@"</strong>"]
                                              stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]
                                             stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""]
                                            stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"]
                                           stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
                                          stringByReplacingOccurrencesOfString:@"lt;" withString:@"<"];
                myBaraholkaTotic.topicID = [Network findTextIn:link fromStart:@"?t=" toEnd:@"\""];
                myBaraholkaTotic.city = [Network findTextIn:link fromStart:@"region\">" toEnd:@"</span>"];
                myBaraholkaTotic.type = [NSString stringWithFormat:@"%@",[key valueForKey:@"category"]];
                NSString* price = [NSString stringWithFormat:@"%@",[key valueForKey:@"price"]];
                if (![price isEqualToString:@"<null>"]) {
                    myBaraholkaTotic.price = [NSString stringWithFormat:@"%@ %@", price, [key valueForKey:@"currency"]];
                }
                
                myBaraholkaTotic.isTorg = [key valueForKey:@"bargain"];
                
            }
            [_objects removeAllObjects];
            _objects = [newBaraholkaTopic mutableCopy];
            [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            [self.searchDisplayController.searchResultsTableView reloadData];
            
        }];
    }
}

-(void) baraholkaFullSearch:(NSString*)searchText {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // 1
        self.isFullCell = YES;
        
        NSString* currPage = @"";
        if (self.currentBaraholkaPage != 0)
        {
            currPage=[NSString stringWithFormat:@"&start=%d",self.currentBaraholkaPage*25];
        }
            
        NSString* urlString = [NSString stringWithFormat:@"http://baraholka.onliner.by/search.php?charset=utf-8&q=%@%@%@",searchText,currPage,self.category];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        // 2
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        
        // 3
        NSArray *nodes = [parser searchWithXPathQuery:self.xpathQueryString];
        
        // 4
        NSMutableArray *newBaraholka = [[NSMutableArray alloc] initWithCapacity:0];
        for (TFHppleElement *element in nodes) {
            // 5
            Baraholka *myBaraholka = [Baraholka new];
            [newBaraholka addObject:myBaraholka];
            
            // 7
            NSString* type = [NSString stringWithFormat:@"%@",[element objectForKey:@"class"]];
            myBaraholka.isHighlighted = NO;
            if ([type isEqualToString:@"m-imp"] || [type isEqualToString:@"m-imp last-tr"]) {
                [myBaraholka setIsHighlighted:YES];
            };
            
            myBaraholka.title = [[[element searchWithXPathQuery:self.titleXpath] objectAtIndex:0] text];
            if ([[element searchWithXPathQuery:self.descriptionXpath] count]) {
                myBaraholka.description = [[[[[element searchWithXPathQuery:self.descriptionXpath] objectAtIndex:0] text] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];

            }
            myBaraholka.category = [[[element searchWithXPathQuery:self.categoryXpath] objectAtIndex:0] text];
            myBaraholka.sellType = [Network findTextIn:[[[element searchWithXPathQuery:self.sellTypeXpath] objectAtIndex:0] objectForKey:@"class"] fromStart:@"label-" toEnd:@"#"] ;
            myBaraholka.city = [[[element searchWithXPathQuery:self.cityXpath] objectAtIndex:0] text];
            myBaraholka.topicID = [Network findTextIn:[[[element searchWithXPathQuery:self.titleXpath] objectAtIndex:0] objectForKey:self.topicIDXpath] fromStart:@"?t=" toEnd:@"#"];
            if ([[element searchWithXPathQuery:self.topicPriceXpath] count]) {
                myBaraholka.price = [[[element searchWithXPathQuery:self.topicPriceXpath] objectAtIndex:0] text];
                myBaraholka.currency = [[[element searchWithXPathQuery:self.topicCurrencyXpath] objectAtIndex:0] text];
            }
            myBaraholka.authorName = [[[element searchWithXPathQuery:self.topicAuthorXpath] objectAtIndex:0] text];
            myBaraholka.authorID = [Network findTextIn:[[[element searchWithXPathQuery:self.topicAuthorXpath] objectAtIndex:0] objectForKey:self.urlXpath] fromStart:@"/user/" toEnd:@"#"];
            
            myBaraholka.imageUrl = [NSString stringWithFormat:@"%@%@",self.imageUrlXpath,myBaraholka.topicID];
            myBaraholka.imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString: myBaraholka.imageUrl]];
            
           if ([[element searchWithXPathQuery:self.commentsCountXpath] count]) {
                myBaraholka.commentsCount=[[[element searchWithXPathQuery:self.commentsCountXpath] objectAtIndex:0] text];
            }
            if ([[element searchWithXPathQuery:self.topicTorgXpath] count]) {
                myBaraholka.isTorg = [[[element searchWithXPathQuery:self.topicTorgXpath] objectAtIndex:0] text];
            }
            
        }
        
        // 8
        if (self.currentBaraholkaPage == 0) {
            _objects = [NSMutableArray array];
            [_objects removeAllObjects];
        }
        
        [_objects addObjectsFromArray:[[[newBaraholka objectEnumerator] allObjects] mutableCopy]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentBaraholkaPage == 0) {
                [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
            [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
            NSLog(@"Success");
        });
    });

}

- (void) performInfinityScroll
{
    
    if (![_objects count]) {
        [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
    } else
    {
        if ([_objects count] >= 25) {
            self.currentBaraholkaPage++;
        }
        [self baraholkaFullSearch:self.searchDisplayController.searchBar.text];
    }
}

- (void) loadCategories
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        _categories = [NSMutableArray new];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://baraholka.onliner.by"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 2
        TFHpple *parser = [TFHpple hppleWithHTMLData:data];
        
        // 3
        NSArray *nodes = [parser searchWithXPathQuery:self.listCategoryXpath];
        
        // 4
        for (TFHppleElement *element in nodes) {
            
            NSMutableDictionary* itemDict = [[NSMutableDictionary alloc] init];
            NSString* categoryName = [[[element children] objectAtIndex:1] text ];
            
            NSString* r = [Network findTextIn:[[[element  searchWithXPathQuery:self.listCategoryLinkXpath] objectAtIndex:0] objectForKey:@"href"] fromStart:@"&r=" toEnd:@"\""] ;
            
            
            // 7
            NSArray* items = [element searchWithXPathQuery:self.listItemXpath];
            
            for (TFHppleElement* item in items) {
                NSString* itemName = [[[item searchWithXPathQuery:self.listItemLinkXpath] objectAtIndex:0] text];
                NSString* f = [Network findTextIn:[[[item searchWithXPathQuery:self.listItemLinkXpath] objectAtIndex:0] objectForKey:@"href"] fromStart:@"?f=" toEnd:@"\""];
                NSString* count = [[[[[item searchWithXPathQuery:self.listItemCount] objectAtIndex:0] text] stringByReplacingOccurrencesOfString:@"\n" withString:@""]
                stringByReplacingOccurrencesOfString:@" " withString:@""];
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:@{@"f":f,
                                                                                            @"count":count}];
                [itemDict setValue:dict forKey:itemName];
                
            }
            NSMutableDictionary* catDict = [NSMutableDictionary dictionaryWithDictionary:@{categoryName:@{@"r":r,
                                                                                             @"items":itemDict}}];
            
            [_categories addObject:catDict];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            NSLog(@"Success");
        });
    });
    
}

#pragma mark - Button Actions

- (IBAction)loginButtonClicked:(UIBarButtonItem *)sender {
    if (![Network isAuthorizated]) {
        LoginViewController *controller = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Выход" message:@"Вы действительно хотите выйти?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Выйти", nil];
        [alert show];
    }

}

- (void) logout
{
    NSString *dataString=[NSString stringWithFormat:@"&key=%@",[Network getHash]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://profile.onliner.by/logout?redirect=http://profile.onliner.by"]];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithString:dataString] dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPBody = body;
    request.HTTPMethod = @"POST";
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!theConnection) NSLog(@"No connection");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Выйти"])
    {
        [self.loginButton setTitle:@"Вход"];
        [self logout];
        [LoginViewController cookiesStorageClearing];
        [[self.tabBarController tabBar] setHidden:YES];
    }
    else if([title isEqualToString:@"Поднять"])
    {
        
    }
}



@end
