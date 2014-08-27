//
//  BaraholkaTableViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 8/23/14.
//
//

#import "BaraholkaTableViewController.h"
#import "BaraholkaTableViewCell.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "AFNetworking.h"
#import "Baraholka.h"
#import "Network.h"

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
    
    self.sellType = @{@"1":@"label_important.png",
                      @"2":@"label_sell.png",
                      @"3":@"label_buy.png",
                      @"4":@"label_change.png",
                      @"5":@"label_service.png",
                      @"6":@"label_rent.png",
                      @"7":@"label_close.png"};


    [self.searchDisplayController setDisplaysSearchBarInNavigationBar:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAppear:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    [self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

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
    BaraholkaTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (tableView == self.tableView) {
        cell.titleLabel.text = [NSString stringWithFormat:@"Table Content Section %d Row %d",indexPath.section,indexPath.row];
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
            
        }

    }
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [_objects removeAllObjects];
    switch(selectedScope)
    {
        case 0:
            /* do something */
            break;
            
        case 1:
            [self baraholkaQuickSearch:searchBar.text];
            break;
            
        case 2:
            /* do something else */
            break;
            
        case 3:
            /* do something else */
            break;
            
        default:
            /* do some default thing for unknown unit */
            break;
    };
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_objects removeAllObjects];
    switch(searchBar.selectedScopeButtonIndex)
    {
        case 0:
            /* do something */
            break;
            
        case 1:
            [self baraholkaQuickSearch:searchBar.text];
            break;
            
        case 2:
            /* do something else */
            break;
            
        case 3:
            /* do something else */
            break;
            
        default:
            /* do some default thing for unknown unit */
            break;
    };
}

- (void) baraholkaQuickSearch: (NSString*) searchText
{
    if (![searchText isEqualToString:@""]) {
        [Network getUrl:@"http://baraholka.onliner.by/gapi/search/baraholka/topic.json" withParams:@{@"s":searchText} andHeaders:nil :^(NSArray *array, NSString *responseString, NSError *error) {
            NSMutableArray *newBaraholkaTopic= [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray* responseArray = [[NSArray arrayWithArray:array] mutableCopy];
            if (![responseString isEqualToString:@"[]"]) {
                [responseArray removeObjectAtIndex:0];
            }
            for (id key in responseArray) {
                Baraholka *myBaraholkaTotic = [Baraholka new];
                [newBaraholkaTopic addObject:myBaraholkaTotic];
                
                NSString* link = [key valueForKey:@"link"];
                myBaraholkaTotic.title = [[self findTextIn:link fromStart:@"<strong>" toEnd:@"</strong>"] stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
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
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    if (tableView == self.tableView) {
        height = 60;
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        Baraholka* myBaraholka = [_objects objectAtIndex:indexPath.row];
        NSString *subject = myBaraholka.title;
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica Neue" size:17.0f];
        CGSize constraintSize;
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
            constraintSize = CGSizeMake(304.0f,MAXFLOAT);
        } else
        {
            constraintSize = CGSizeMake(465.0f,MAXFLOAT);
        }
        CGSize textSize = [subject sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        height = textSize.height+34;
    }
    

    return height;
}


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
