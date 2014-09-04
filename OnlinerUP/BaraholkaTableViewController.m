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
#import "AFNetworking.h"
#import "Baraholka.h"
#import "Network.h"
#import "TFHpple.h"
#import "ModalWebViewController.h"

@interface BaraholkaTableViewController ()
{
    NSMutableArray *_objects;
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
    self.currentBaraholkaPage = 0;
    self.sellType = @{@"1":@"label_important.png",
                      @"2":@"label_sell.png",
                      @"3":@"label_buy.png",
                      @"4":@"label_change.png",
                      @"5":@"label_service.png",
                      @"6":@"label_rent.png",
                      @"7":@"label_close.png"};
    [self.searchDisplayController setDisplaysSearchBarInNavigationBar:NO];
    [self.searchDisplayController.searchResultsTableView addInfiniteScrollingWithActionHandler:^{
        if (self.isFullCell) {
            [self performInfinityScroll];
        }
    }];
    
    [self loadXpath];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    [self.searchDisplayController.searchBar setShowsCancelButton:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count;
    if (tableView == self.tableView) {
        count = 3;
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
        if (tableView == self.tableView) {
            cell.titleLabel.text = [NSString stringWithFormat:@"Table Content Section %ld Row %ld",(long)indexPath.section,(long)indexPath.row];
        }
        else if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_objects count] != 0) {
                Baraholka *myBaraholkaTotic = [Baraholka new];
                myBaraholkaTotic = [_objects objectAtIndex:indexPath.row];
                
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
        BaraholkaTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (tableView == self.tableView) {
            cell.titleLabel.text = [NSString stringWithFormat:@"Table Content Section %ld Row %ld",(long)indexPath.section,(long)indexPath.row];
        }
        else if (tableView == self.searchDisplayController.searchResultsTableView) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (self.isFullCell) {
        
        if (tableView == self.tableView) {
            height = 60;
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
            
            height = titleSize.height+descriptionSize.height+53;
        }
        
        
        
    }
    else {
        if (tableView == self.tableView) {
            height = 60;
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
    ModalWebViewController *controller = (ModalWebViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ModalWebViewController"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    Baraholka* myBaraholka = [_objects objectAtIndex:indexPath.row];
    
    controller.title = @"Объявление";
    controller.url = [NSString stringWithFormat:@"http://baraholka.onliner.by/viewtopic.php?t=%@", myBaraholka.topicID];
}

#pragma mark - SearchBar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.currentBaraholkaPage = 0;
    [self baraholkaQuickSearch:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentBaraholkaPage = 0;
    [self baraholkaFullSearch:searchBar.text];
}

#pragma mark - load data

- (void) loadXpath
{
    self.xpathQueryString=@"//td[@class='frst ph colspan']/..";
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
                myBaraholkaTotic.title = [[[self findTextIn:link fromStart:@"<strong>" toEnd:@"</strong>"]  stringByReplacingOccurrencesOfString:@"amp;" withString:@""] stringByReplacingOccurrencesOfString:@"&quot;" withString:@""];
                myBaraholkaTotic.topicID = [self findTextIn:link fromStart:@"?t=" toEnd:@"\""];
                myBaraholkaTotic.city = [self findTextIn:link fromStart:@"region\">" toEnd:@"</span>"];
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
            
        NSString* urlString = [NSString stringWithFormat:@"http://baraholka.onliner.by/search.php?charset=utf-8&q=%@%@",searchText,currPage];
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
            if ([type isEqualToString:@"m-imp"]) {
                [myBaraholka setIsHighlighted:YES];
            };
            
            myBaraholka.title = [[[element searchWithXPathQuery:self.titleXpath] objectAtIndex:0] text];
            if ([[element searchWithXPathQuery:self.descriptionXpath] count]) {
                myBaraholka.description = [[[[[element searchWithXPathQuery:self.descriptionXpath] objectAtIndex:0] text] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];

            }
            myBaraholka.category = [[[element searchWithXPathQuery:self.categoryXpath] objectAtIndex:0] text];
            myBaraholka.sellType = [self findTextIn:[[[element searchWithXPathQuery:self.sellTypeXpath] objectAtIndex:0] objectForKey:@"class"] fromStart:@"label-" toEnd:@"#"] ;
            myBaraholka.city = [[[element searchWithXPathQuery:self.cityXpath] objectAtIndex:0] text];
            myBaraholka.topicID = [self findTextIn:[[[element searchWithXPathQuery:self.titleXpath] objectAtIndex:0] objectForKey:self.topicIDXpath] fromStart:@"?t=" toEnd:@"#"];
            if ([[element searchWithXPathQuery:self.topicPriceXpath] count]) {
                myBaraholka.price = [[[element searchWithXPathQuery:self.topicPriceXpath] objectAtIndex:0] text];
                myBaraholka.currency = [[[element searchWithXPathQuery:self.topicCurrencyXpath] objectAtIndex:0] text];
            }
            myBaraholka.authorName = [[[element searchWithXPathQuery:self.topicAuthorXpath] objectAtIndex:0] text];
            myBaraholka.authorID = [self findTextIn:[[[element searchWithXPathQuery:self.topicAuthorXpath] objectAtIndex:0] objectForKey:self.urlXpath] fromStart:@"/user/" toEnd:@"#"];
            
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
            [_objects removeAllObjects];
        }
        
        [_objects addObjectsFromArray:[[[newBaraholka objectEnumerator] allObjects] mutableCopy]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentBaraholkaPage == 0) {
                [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
            [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
            NSLog(@"Success");
        });
    });
    
    
}

- (void) performInfinityScroll
{
    if ([_objects count] >= 25) {
        self.currentBaraholkaPage++;
        [self baraholkaFullSearch:self.searchDisplayController.searchBar.text];
    } else [self.searchDisplayController.searchResultsTableView.infiniteScrollingView stopAnimating];
}


#pragma mark - help

- (NSString*) findTextIn:(NSString*) text fromStart:(NSString*) startText toEnd:(NSString*) endText {
    NSString* value;
    NSRange start = [text rangeOfString:startText];
    if (start.location != NSNotFound)
    {
        value = [text substringFromIndex:start.location + start.length];
        NSRange end = [value rangeOfString:endText];
        if (end.location != NSNotFound)
        {
            value = [value substringToIndex:end.location];
        }
    }
    return value;
}



@end
