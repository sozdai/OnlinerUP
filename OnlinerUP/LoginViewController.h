//
//  LoginViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 10/17/14.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
- (IBAction)closeButtonClick:(id)sender;

@end
