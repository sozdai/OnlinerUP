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
#import "UIScrollView+SVInfiniteScrolling.h"
#import "LoginViewController.h"
#import "AFNetworking.h"
#import "Baraholka.h"
#import "Network.h"
#import "TFHpple.h"
#import "OnlinerUPAppDelegate.h"
#import "MBProgressHUD.h"
#import "SVWebViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAITrackedViewController.h"

@interface BaraholkaTableViewController () <UISearchDisplayDelegate, UISearchBarDelegate, GADBannerViewDelegate>
{
    NSMutableArray *_objects;
    NSMutableArray *_categories;
    NSMutableDictionary* _config;
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
    self.currentBaraholkaPage = 0;
    self.sellType = @{@"1":@"label_important.png",
                      @"2":@"label_sell.png",
                      @"3":@"label_buy.png",
                      @"4":@"label_change.png",
                      @"5":@"label_service.png",
                      @"6":@"label_rent.png",
                      @"7":@"label_close.png"};
    
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:KeyForIsAdsRemoved
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = NO;

    [self loadVersion];
    
    [self.searchDisplayController.searchResultsTableView addInfiniteScrollingWithActionHandler:^{
        [self performInfinityScroll];
    }];
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self changeAdsPosition];

    if (![Network isAuthorizated]) {
        [self.loginButton setTitle:@"Вход"];
        [[self.tabBarController tabBar] setHidden:YES];
    } else
    {
        [self.loginButton setTitle:@"Выход"];
        [[self.tabBarController tabBar] setHidden:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCategories:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //Google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Baraholka screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)anObject
                       change:(NSDictionary *)aChange context:(void *)aContext
{
    [bannerView_ removeFromSuperview];
}

- (void) changeAdsPosition
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForShouldShowAd]) {
        CGFloat height;
        if ([Network isAuthorizated]) {
            height = 99;
        } else
        {
            height = 50;
        }
        [bannerView_ setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-height, bannerView_.bounds.size.width,bannerView_.bounds.size.height)];
    }
}


- (void) closeView
{
    [NSTimer scheduledTimerWithTimeInterval:300.0 target:self
                                   selector:@selector(unhideAds) userInfo:nil repeats:NO];
    self.didBannerClosed = YES;
    [bannerView_ setHidden:YES];
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    if ([self.searchDisplayController.searchBar isFirstResponder]) {
        [self.searchDisplayController.searchBar setShowsCancelButton:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    long count;
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
    
    long count;
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
                    [cell.contentView.layer setBackgroundColor:[UIColor whiteColor].CGColor];
                    [cell.contentView.layer setBorderWidth:0.5f];

                }
                cell.titleLabel.text = myBaraholkaTotic.title;
                cell.descriptionLabel.text = myBaraholkaTotic.topicDescription;
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
            cell.titleLabel.text = [[[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];
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
            if ([self.category length]) {
                title = self.categoryTitle;
            } else
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
    myLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    myLabel.textColor = [UIColor whiteColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    switch (section%4) {
        case 0:
            headerView.backgroundColor = [UIColor colorWithRed:0.91 green:0.396 blue:0.337 alpha:1.0];
            break;
        case 1:
            headerView.backgroundColor = [UIColor colorWithRed:0.392 green:0.639 blue:0.816 alpha:1.0];
            break;
        case 2:
            headerView.backgroundColor = [UIColor colorWithRed:0.455 green:0.753 blue:0.137 alpha:1.0];
            break;
        case 3:
            headerView.backgroundColor = [UIColor colorWithRed:0.941 green:0.635 blue:0.247 alpha:1.0];
            break;
            
        default:
            headerView.backgroundColor = [UIColor colorWithRed:(232/255.0) green:(101/255.0) blue:(86/255.0) alpha:1.0];
            break;
    }
    
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
            NSString* description = myBaraholka.topicDescription;
            UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
            UIFont *descriptionFont = [UIFont fontWithName:@"Helvetica Neue" size:12.0f];
            CGSize constraintSize;
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
                constraintSize = CGSizeMake(304.0f,MAXFLOAT);
            } else
            {
                constraintSize = CGSizeMake(464.0f,MAXFLOAT);
            }
            
            NSAttributedString *attributedSubject =
            [[NSAttributedString alloc]
             initWithString:subject
             attributes:@
             {
             NSFontAttributeName: titleFont
             }];
            CGRect titleRect = [attributedSubject boundingRectWithSize:constraintSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            CGSize titleSize = titleRect.size;
            CGFloat descriptionHeight = 0;
            if (description) {
                NSAttributedString *attributedDescription =
                [[NSAttributedString alloc]
                 initWithString:description
                 attributes:@
                 {
                 NSFontAttributeName: descriptionFont
                 }];
                CGRect descriptionRect = [attributedDescription boundingRectWithSize:constraintSize
                                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                                             context:nil];
                CGSize descriptionSize = descriptionRect.size;
                descriptionHeight = descriptionSize.height;
            }
            
            
            height = ceilf(titleSize.height)+descriptionHeight+58;
        }
        
        
        
    }
    else {
        if (tableView == self.tableView) {
            UIFont *titleFont = [UIFont fontWithName:@"Helvetica Neue" size:15.0f];
            CGSize constraintSize = CGSizeMake(304.0f,MAXFLOAT);
            NSString* subject = [[[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];
            NSAttributedString *attributedSubject =
            [[NSAttributedString alloc]
             initWithString:subject
             attributes:@
             {
             NSFontAttributeName: titleFont
             }];
            CGRect titleRect = [attributedSubject boundingRectWithSize:constraintSize
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                              context:nil];
            CGSize titleSize = titleRect.size;
            
            return ceilf(titleSize.height)+12;
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
            NSAttributedString *attributedSubject =
            [[NSAttributedString alloc]
             initWithString:subject
             attributes:@
             {
             NSFontAttributeName: titleFont
             }];
            CGRect titleRect = [attributedSubject boundingRectWithSize:constraintSize
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                               context:nil];
            CGSize titleSize = titleRect.size;
            
            return ceilf(titleSize.height)+34;
        }
    }
    
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //quick search table
    if (tableView == self.tableView)
    {
        //google analytics
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"search"
                                                              action:@"quick_search_cell_selected"
                                                               label:nil
                                                               value:nil] build]];

        NSString* url;
        self.categoryTitle = [[[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] objectAtIndex:indexPath.row] allKeys ] objectAtIndex:0];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:KeyForConfig] valueForKey:@"exceptions"]) {
            self.exceptionLinks = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyForConfig] valueForKey:@"exceptions"];
            for (id key in self.exceptionLinks) {
                if ([self.categoryTitle isEqualToString:key]) {
                    url = [self.exceptionLinks valueForKey:key];
                    
                }
            }
        }
        if (url) {
            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
            [webViewController.navigationItem setTitle:self.categoryTitle];
            webViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webViewController animated:YES];
            [bannerView_ setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-94, bannerView_.bounds.size.width,bannerView_.bounds.size.height)];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else
        {
            //google analytics
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"search"
                                                                  action:@"full_search_cell_selected"
                                                                   label:nil
                                                                   value:nil] build]];

            
            [self.searchDisplayController setActive: YES animated: YES];
            self.searchDisplayController.searchBar.hidden = NO;
            self.searchDisplayController.searchBar.placeholder = @"Поиск по категории";
            [MBProgressHUD showHUDAddedTo:self.searchDisplayController.searchResultsTableView animated:YES];
            self.category = [NSString stringWithFormat:@"&f=%@", [[[[[[[_categories objectAtIndex:indexPath.section] allValues] objectAtIndex:0] valueForKey:@"items"] objectAtIndex:indexPath.row] valueForKey:self.categoryTitle] valueForKey:@"f"]];
            [self baraholkaFullSearch:@"" andUrl:@"http://baraholka.onliner.by/search.php"];
        }
        
    }
    //full search table
    else {
        
        Baraholka* myBaraholka = [_objects objectAtIndex:indexPath.row];

        NSString* url = [NSString stringWithFormat:@"http://baraholka.onliner.by/viewtopic.php?t=%@", myBaraholka.topicID];
        if (_config) {
            self.exceptionLinks = [_config valueForKey:@"exceptions"];
            for (id key in self.exceptionLinks) {
                if ([myBaraholka.title isEqualToString:key]) {
                    url = [self.exceptionLinks valueForKey:key];
                }
            }
        }
        
        SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:url];
        webViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webViewController animated:YES];
        [bannerView_ setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-94, bannerView_.bounds.size.width,bannerView_.bounds.size.height)];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - SearchBar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![self.category length]) {
        self.currentBaraholkaPage = 0;
        [self baraholkaQuickSearch:searchBar.text];

    }
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"search"
                                                          action:@"quick_search"
                                                           label:searchText
                                                           value:nil] build]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentBaraholkaPage = 0;
    [MBProgressHUD hideHUDForView:self.searchDisplayController.searchResultsTableView animated:YES];
    [MBProgressHUD showHUDAddedTo:self.searchDisplayController.searchResultsTableView animated:YES];
    [self baraholkaFullSearch:searchBar.text andUrl:@"http://baraholka.onliner.by/search.php"];
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"search"
                                                          action:@"full_search"
                                                           label:searchBar.text
                                                           value:nil] build]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.isQuickCell = YES;
    self.category = @"";
    self.categoryTitle = @"";
    self.isFullCell = NO;
    self.currentBaraholkaPage = 0;
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    [MBProgressHUD hideHUDForView:self.searchDisplayController.searchResultsTableView animated:YES];
    self.searchDisplayController.searchBar.placeholder = @"Поиск по барахолке";
    [_objects removeAllObjects];
    [searchBar setShowsCancelButton:NO];
    [self.tableView reloadData];
    
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"search"
                                                          action:@"cancel_button"
                                                           label:searchBar.text
                                                           value:nil] build]];
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
//    // We need to prevent the resultsTable from hiding if the search is still active
    if (self.searchDisplayController.active == YES) {
        tableView.hidden = NO;
    }
    if (self.isFullCell && [self.category length]) {
        [self baraholkaFullSearch:@"" andUrl:@"http://baraholka.onliner.by/search.php"];
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
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KeyForShouldShowAd]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:KeyForIsAdsRemoved]) {
            [self adMobAd];
        }
    }
    
    NSDictionary* baraholkaXpath = [[[NSUserDefaults standardUserDefaults] objectForKey:KeyForConfig] objectForKey:@"baraholkaXpath"];
    
    self.xpathQueryString=[baraholkaXpath valueForKey:@"xpathQueryString"];
    
    self.listCategoryXpath=[baraholkaXpath valueForKey:@"listCategoryXpath"];
    self.listCategoryLinkXpath=[baraholkaXpath valueForKey:@"listCategoryLinkXpath"];
    self.listItemXpath=[baraholkaXpath valueForKey:@"listItemXpath"];
    self.listItemLinkXpath=[baraholkaXpath valueForKey:@"listItemLinkXpath"];
    self.listItemCount=[baraholkaXpath valueForKey:@"listItemCount"];
    
    self.topicTypeXpath=[baraholkaXpath valueForKey:@"topicTypeXpath"];
    self.titleXpath=[baraholkaXpath valueForKey:@"titleXpath"];
    self.descriptionXpath=[baraholkaXpath valueForKey:@"descriptionXpath"];
    self.categoryXpath=[baraholkaXpath valueForKey:@"categoryXpath"];
    self.sellTypeXpath=[baraholkaXpath valueForKey:@"sellTypeXpath"];
    self.cityXpath=[baraholkaXpath valueForKey:@"cityXpath"];
    self.topicIDXpath=[baraholkaXpath valueForKey:@"topicIDXpath"];
    self.urlXpath=[baraholkaXpath valueForKey:@"urlXpath"];

    self.topicPriceXpath=[baraholkaXpath valueForKey:@"topicPriceXpath"];
    self.topicCurrencyXpath=[baraholkaXpath valueForKey:@"topicCurrencyXpath"];
    self.topicTorgXpath=[baraholkaXpath valueForKey:@"topicTorgXpath"];
    
    self.topicAuthorXpath=[baraholkaXpath valueForKey:@"topicAuthorXpath"];
    self.imageUrlXpath=[baraholkaXpath valueForKey:@"imageUrlXpath"];
    self.commentsCountXpath=[baraholkaXpath valueForKey:@"commentsCountXpath"];
    
    self.upTopicTime=[baraholkaXpath valueForKey:@"upTopicTime"];
    
    if (![_categories count]) {
        [self loadCategories];
    }
}

#pragma mark - Search
-(void) baraholkaQuickSearch: (NSString*) searchText
{
    self.quickCellSearchText = searchText;
    [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
    self.isQuickCell = YES;
    if (![searchText isEqualToString:@""]) {
        [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        self.isFullCell = NO;
        [Network getUrl:@"http://baraholka.onliner.by/gapi/search/baraholka/topic.json" withParams:@{@"s":searchText} andHeaders:nil andSerializer:@"JSON" :^(NSArray* responseObject,NSString *responseString, NSError *error) {
            if (!error) {
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
                    
                    myBaraholkaTotic.isTorg = [[key valueForKey:@"bargain"]isEqualToString:@"ТОРГ"]?@"торг":@"";
                    
                }
                
                if ([searchText isEqualToString: self.quickCellSearchText]) {
                    [_objects removeAllObjects];
                    _objects = [newBaraholkaTopic mutableCopy];
                    [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }
                
            }
        }];
    }
}

-(void) baraholkaFullSearch:(NSString*)searchText andUrl:(NSString*) enterUrl{
    self.isQuickCell = NO;
    self.fullCellSearchText = searchText;
    long count = [_objects count];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        // 1
        NSString* currPage = @"";
        if (self.currentBaraholkaPage != 0)
        {
            currPage=[NSString stringWithFormat:@"&start=%d",self.currentBaraholkaPage*25];
        }
        
        NSString* topicTitle = @"";
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"topicTitle"]) {
            topicTitle = @"&topicTitle=1";
        }
        
         NSString* q = @"";
        if ([searchText length]) {
           q = searchText;
        }
        BOOL connectionError = NO;
        
        NSString* urlString = [NSString stringWithFormat:@"%@?charset=utf8&q=%@%@%@%@",enterUrl,q,self.category,topicTitle,currPage];
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (!data)
        {
            connectionError = YES;
        }
        else
        {
            // 2
            TFHpple *parser = [TFHpple hppleWithHTMLData:data];
            
            // 3
            NSArray *nodes = [parser searchWithXPathQuery:self.xpathQueryString];
            
            // 4
            int indexEE = 0;
            NSMutableArray *newBaraholka = [[NSMutableArray alloc] initWithCapacity:0];
            for (TFHppleElement *element in nodes) {
                // 5
                indexEE++;
                if (self.isQuickCell || ![self.fullCellSearchText isEqualToString:searchText])
                {
                    break;
                }
                else
                {
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
                        myBaraholka.topicDescription = [[[[[element searchWithXPathQuery:self.descriptionXpath] objectAtIndex:0] text] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
                        
                    }
                    if ([[element searchWithXPathQuery:self.categoryXpath] count]) {
                        myBaraholka.category = [[[element searchWithXPathQuery:self.categoryXpath] objectAtIndex:0] text];
                    } else myBaraholka.category = self.categoryTitle;
                    NSString* sellTypeClass = [[[element searchWithXPathQuery:self.sellTypeXpath] objectAtIndex:0] objectForKey:@"class"];
                    myBaraholka.sellType = [Network findTextIn:sellTypeClass fromStart:@"label-" toEnd:@"#"] ;
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
                        myBaraholka.commentsCount=[[[[[element searchWithXPathQuery:self.commentsCountXpath] objectAtIndex:0] text] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""] ;
                    }
                    if ([[element searchWithXPathQuery:self.topicTorgXpath] count]) {
                        myBaraholka.isTorg = [[[[element searchWithXPathQuery:self.topicTorgXpath] objectAtIndex:0] text] isEqualToString:@"ТОРГ"]?@"торг":@"";
                    }
                }
            }
            if (!self.isQuickCell)
            {
                if (self.currentBaraholkaPage == 0) {
                    _objects = [NSMutableArray array];
                    [_objects removeAllObjects];
                }
                [_objects addObjectsFromArray:[[[newBaraholka objectEnumerator] allObjects] mutableCopy]];
                
            }
            // 8
        }
       
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (connectionError) {
                [MBProgressHUD hideHUDForView:self.searchDisplayController.searchResultsTableView animated:YES];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Вероятно, соединение с Интернетом прервано." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }else if (!self.isQuickCell && [self.fullCellSearchText isEqualToString:searchText])
            {
                if (self.currentBaraholkaPage == 0) {
                    if ([_objects count] != count) {
                        [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    }
                }
                self.isFullCell = YES;
                [self.searchDisplayController.searchResultsTableView reloadData];
                [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
                [MBProgressHUD hideHUDForView:self.searchDisplayController.searchResultsTableView animated:YES];
            }
        });
    });
    
}

- (void) performInfinityScroll
{
    //google analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"search"
                                                          action:@"infinity_search"
                                                           label:self.searchDisplayController.searchBar.text
                                                           value:nil] build]];
    if (![_objects count]) {
        [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
    } else
    {
        if ([_objects count] >= 25) {
            self.currentBaraholkaPage++;
            [self baraholkaFullSearch:self.searchDisplayController.searchBar.text andUrl:@"http://baraholka.onliner.by/search.php"];
        }
        else if (self.isQuickCell)
        {
            self.currentBaraholkaPage = 0;
            [self baraholkaFullSearch:self.searchDisplayController.searchBar.text andUrl:@"http://baraholka.onliner.by/search.php"];
        }
        
    }
}

- (void) loadVersion
{
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [manager GET:@"http://kardash.by/version.json#" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![[[NSUserDefaults standardUserDefaults] valueForKey:KeyForConfigVersion] isEqualToString:[responseObject valueForKey:@"version"]] ) {
            [self loadConfig];
        } else
        {
            [self loadXpath];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

- (void) loadConfig
{
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    
    [manager GET:@"http://kardash.by/config.json#" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _config = [responseObject mutableCopy];
        if (_config) {
            NSDictionary* settings = [_config valueForKey:@"settings"];
            NSString* version = [settings valueForKey:@"version"];
            BOOL shouldShowAd = [[settings valueForKey:@"show ad"] boolValue];
            
            [[NSUserDefaults standardUserDefaults] setObject:_config forKey:KeyForConfig];
            [[NSUserDefaults standardUserDefaults] setBool:shouldShowAd forKey:KeyForShouldShowAd];
            [[NSUserDefaults standardUserDefaults] setValue:version forKey:KeyForConfigVersion];

            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self loadXpath];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}

- (void) loadCategories
{
    __block BOOL connectionError = NO;
    [MBProgressHUD hideHUDForView:self.tableView animated:NO];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        _categories = [NSMutableArray new];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://baraholka.onliner.by"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (!data)
        {
            connectionError = YES;
        } else
        {
            // 2
            TFHpple *parser = [TFHpple hppleWithHTMLData:data];
            
            // 3
            NSArray *nodes = [parser searchWithXPathQuery:self.listCategoryXpath];
            
            // 4
            for (TFHppleElement *element in nodes) {
                
                NSMutableDictionary* itemDict = [[NSMutableDictionary alloc] init];
                NSMutableArray* itemArray = [NSMutableArray new];
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
                    [itemArray addObject:@{itemName:dict}];
                    
                }
                
                NSMutableDictionary* catDict = [NSMutableDictionary dictionaryWithDictionary:@{categoryName:@{@"r":r,
                                                                                                              @"items":itemArray}}];
                [_categories addObject:catDict];
            }
            [self.tableView reloadData];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.tableView animated:YES];
            if (connectionError) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Вероятно, соединение с Интернетом прервано." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
    
}

- (void) reloadCategories:(NSNotification *)notification
{
    if (![_categories count]) {
        [self loadVersion];
    }
}

#pragma mark - AdMob

- (void) adMobAd
{
    
    bannerView_.translatesAutoresizingMaskIntoConstraints = YES;  //This part hung me up
    
    // Создание представления стандартного размера вверху экрана.
    // Доступные константы AdSize см. в GADAdSize.h.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    bannerView_.delegate=self;
    // Указание идентификатора рекламного блока.
    bannerView_.adUnitID = @"ca-app-pub-7869340624965568/3928217339";
    
    
    // Укажите, какой UIViewController необходимо восстановить
    // после перехода пользователя по объявлению и добавить в иерархию представлений.
    bannerView_.rootViewController = self;
    
    GADRequest* request = [GADRequest request];
    request.testDevices = @[ GAD_SIMULATOR_ID, @"MY_TEST_DEVICE_ID" ];
    
    // Инициирование общего запроса на загрузку с объявлением.
    [bannerView_ loadRequest:request];
    [self.navigationController.parentViewController.view addSubview:bannerView_];
    [self changeAdsPosition];
    UIButton *closeButton = [[UIButton alloc] initWithFrame: CGRectMake(0,0,18,18)];
    [closeButton setBackgroundColor:[UIColor colorWithWhite:0.33 alpha:0.5]];
    [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setBackgroundImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
    [bannerView_ addSubview:closeButton];
    [bannerView_ setHidden:YES];

    
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
        if (!self.didBannerClosed) {
            [view setHidden:NO];
        }
 }

- (void) adView:(GADBannerView *)banner didFailToReceiveAdWithError:(GADRequestError *)error{

}

- (void) unhideAds
{
    if (bannerView_.isHidden) {
        [bannerView_ setHidden:NO];
    }
}



#pragma mark - Button Actions

- (IBAction)loginButtonClicked:(UIBarButtonItem *)sender {
    if (![Network isAuthorizated]) {
        //google analytics
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"login"
                                                              action:@"login_button_clicked"
                                                               label:@""
                                                               value:nil] build]];
        LoginViewController *controller = (LoginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:nil];
    } else
    {
        //google analytics
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"login"
                                                              action:@"logout_button_clicked"
                                                               label:@""
                                                               value:nil] build]];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Выход" message:@"Вы действительно хотите выйти?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Выйти", nil];
        [alert show];
    }

}

- (void) logout
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForNeedReloadForAdsPage];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForNeedReloadForMessagesPage];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:KeyForUserDefaultUserName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Выйти"])
    {
        [self.loginButton setTitle:@"Вход"];
        [self logout];
        [Network cookiesStorageClearing];
        [[self.tabBarController tabBar] setHidden:YES];
        [self changeAdsPosition];
    }
    else if([title isEqualToString:@"Поднять"])
    {
        
    }
}



@end
