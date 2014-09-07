//
//  MyAdTableViewController.h
//  OnlinerUP
//
//  Created by Alex on 20.07.14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAdTableViewController : UITableViewController <UIAlertViewDelegate>
- (IBAction)buttonUPClick:(UIButton *)sender;

@property (strong,nonatomic) NSMutableData * responseData;
@property (strong,nonatomic) NSString* task;
@property (strong,nonatomic) NSString *xpathQueryString;
@property (strong,nonatomic) NSString *upButtonXpath;
@property (strong,nonatomic) NSString* titleXpath;
@property (strong,nonatomic) NSString* urlXpath;
@property (strong,nonatomic) NSString* topicIDXpath;
@property (strong,nonatomic) NSString* topicPriceXpath;
@property (strong,nonatomic) NSString* topicTypeXpath;
@property (strong,nonatomic) NSString* timeLeftXpath;
@property (strong,nonatomic) NSString* imageUrlXpath;
@property (strong,nonatomic) NSString* categoryXpath;
@property (strong,nonatomic) NSString* commentsCountXpath;
@property (strong,nonatomic) NSString* commentsUnreadCountXpath;
@property (strong,nonatomic) NSString* sellTypeXpath;
@property (strong,nonatomic) NSString* htmlString;
@property (strong,nonatomic) NSDictionary* sellTypeDictionary;
@property (strong,nonatomic) NSString* messagesCountXpath;
@property (strong,nonatomic) NSString* messagesCount;
@property (strong,nonatomic) UIButton* sender;

-(void)loadAd;

- (IBAction)clickUpAllButton:(UIButton *)sender;


@end
