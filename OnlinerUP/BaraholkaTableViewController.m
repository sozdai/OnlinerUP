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

    
    [self.searchDisplayController setDisplaysSearchBarInNavigationBar:YES];
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
        if (!cell) {
            cell = [[BaraholkaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        cell.titleLabel.text = [NSString stringWithFormat:@"Table Content Section %d Row %d",indexPath.section,indexPath.row];
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (!cell) {
            cell = [[BaraholkaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
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

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (![searchText isEqualToString:@""]) {
        [self getStringFromUrl:@"http://baraholka.onliner.by/gapi/search/baraholka/topic.json" withParams:@{@"s":searchText} andHeaders:nil :^(NSArray *movies, NSError *error) {
            [_objects removeAllObjects];
            _objects = [movies mutableCopy];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];

    }
}

- (void)getStringFromUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*) headers:(void (^)(NSArray *movies, NSError *error))block {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    for(id key in headers)
    {
        NSString* value = [headers objectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableArray *newBaraholkaTopic= [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableArray* responseArray = [[NSArray arrayWithArray:responseObject] mutableCopy];
        if (![operation.responseString isEqualToString:@"[]"]) {
            [responseArray removeObjectAtIndex:0];
        }
        for (id key in responseArray) {
            Baraholka *myBaraholkaTotic = [Baraholka new];
            [newBaraholkaTopic addObject:myBaraholkaTotic];
            
            NSString* link = [key valueForKey:@"link"];
            myBaraholkaTotic.title = [self findTextIn:link fromStart:@"<strong>" toEnd:@"</strong>"];
            myBaraholkaTotic.topicID = [self findTextIn:link fromStart:@"?t=" toEnd:@"\""];
            myBaraholkaTotic.city = [self findTextIn:link fromStart:@"region\">" toEnd:@"</span>"];
            myBaraholkaTotic.type = [NSString stringWithFormat:@"%@",[key valueForKey:@"category"]];
            myBaraholkaTotic.price = [NSString stringWithFormat:@"%@ %@", [key valueForKey:@"price"], [key valueForKey:@"currency"]];
            myBaraholkaTotic.isTorg = [key valueForKey:@"bargain"];
            
        }
        if (block) {
            block([NSArray arrayWithArray:[[newBaraholkaTopic objectEnumerator] allObjects]], nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error connection %@",error);
        if (block) {
            block([NSArray array], error);
        }
    }];
}

//#pragma mark - Table view data source
//
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    BaraholkaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (!cell) {
//        cell = [[BaraholkaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    
//    return cell;
//}

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
