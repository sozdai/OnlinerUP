//
//  BaraholkaTableViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/23/14.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface BaraholkaTableViewController : UITableViewController{
    GADBannerView *bannerView_;
}

@property (strong, nonatomic) NSDictionary* sellType;
@property (strong, nonatomic) NSString* htmlString;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* categoryTitle;


@property (strong,nonatomic) NSString* listCategoryXpath;
@property (strong,nonatomic) NSString* listCategoryLinkXpath;
@property (strong,nonatomic) NSString* listItemXpath;
@property (strong,nonatomic) NSString* listItemLinkXpath;
@property (strong,nonatomic) NSString* listItemCount;

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
@property (assign,nonatomic) BOOL isQuickCell;
@property (assign,nonatomic) int currentBaraholkaPage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property(nonatomic, strong) UIView *adsView;
@property (assign, nonatomic) BOOL didBannerClosed;

-(void) baraholkaQuickSearch:(NSString*)searchText;
-(void) baraholkaFullSearch:(NSString*)searchText;
-(void) loadXpath;

@end
