//
//  MyMessagesTableViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/21/14.
//
//

#import <UIKit/UIKit.h>

@interface MyMessagesTableViewController : UITableViewController
- (IBAction)authorButtonClick:(UIButton *)sender;
- (IBAction)actionButtonClick:(UIBarButtonItem *)sender;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* folder;
@property (assign, nonatomic) int page;

@end
