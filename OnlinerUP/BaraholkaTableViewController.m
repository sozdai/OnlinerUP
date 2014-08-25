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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.searchDisplayController setDisplaysSearchBarInNavigationBar:YES];
    self.sellType = @{@"1":@"label_important.png",
                      @"2":@"label_sell.png",
                      @"3":@"label_buy.png",
                      @"4":@"label_change.png",
                      @"5":@"label_service.png",
                      @"6":@"label_rent.png",
                      @"7":@"label_close.png"};
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            myBaraholkaTotic.type = [key valueForKey:@"category"];
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_objects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BaraholkaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BaraholkaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    if ([_objects count] != 0) {
        Baraholka *myBaraholkaTotic = [Baraholka new];
        myBaraholkaTotic = [_objects objectAtIndex:indexPath.row];
        
        cell.textLabel.text = myBaraholkaTotic.title;
        cell.titleLabel.text = myBaraholkaTotic.title;
        cell.cityLabel.text = myBaraholkaTotic.city;
        cell.priceLabel.text = myBaraholkaTotic.price;
        cell.sellTypeImage.image = [UIImage imageNamed:[self.sellType objectForKey:myBaraholkaTotic.type]];
        cell.torgLabel.text = myBaraholkaTotic.isTorg;
   
    }
    return cell;
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

@end
