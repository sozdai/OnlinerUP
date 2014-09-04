//
//  BaraholkaTableViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/23/14.
//
//

#import <UIKit/UIKit.h>

@interface BaraholkaTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary* sellType;
@property (strong, nonatomic) NSString* htmlString;

@property (strong,nonatomic) NSString *xpathQueryString;
@property (strong,nonatomic) NSString* topicTypeXpath;
@property (strong,nonatomic) NSString* titleXpath;
@property (strong,nonatomic) NSString *descriptionXpath;
@property (strong,nonatomic) NSString* categoryXpath;
@property (strong,nonatomic) NSString* sellTypeXpath;
@property (strong,nonatomic) NSString* cityXpath;
@property (strong,nonatomic) NSString* topicIDXpath;
@property (strong,nonatomic) NSString* urlXpath;
@property (strong,nonatomic) NSString* topicPriceXpath;
@property (strong,nonatomic) NSString* topicTorgXpath;
@property (strong,nonatomic) NSString* topicCurrencyXpath;
@property (strong,nonatomic) NSString* topicAuthorXpath;

@property (strong,nonatomic) NSString* imageUrlXpath;
@property (strong,nonatomic) NSString* commentsCountXpath;
@property (strong,nonatomic) NSString* commentsUnreadCountXpath;
@property (strong,nonatomic) NSString* upTopicTime;
@property (assign,nonatomic) BOOL isFullCell;
@property (assign,nonatomic) int currentBaraholkaPage;




-(void) baraholkaQuickSearch:(NSString*)searchText;
-(void) baraholkaFullSearch:(NSString*)searchText;
-(void) loadXpath;

@end
