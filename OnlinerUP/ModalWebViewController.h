//
//  ModalWebViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/8/14.
//
//

#import <UIKit/UIKit.h>

@interface ModalWebViewController : UIViewController

@property (strong, nonatomic) NSString* url;
- (IBAction)actionClick:(UIBarButtonItem *)sender;
- (IBAction)closeClick:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
