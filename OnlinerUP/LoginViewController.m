//
//  LoginViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 10/17/14.
//
//

#import "LoginViewController.h"
#import "Network.h"
#import "OnlinerUPAppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    NSURL* url = [NSURL URLWithString:@"https://profile.onliner.by/login"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    // Do any additional setup after loading the view.
}

-(void) viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //Check if special link
    if ([Network isAuthorizated]) {
        [self dismissViewControllerAnimated:self completion:nil];
        return NO;
    }
    
    return YES;
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView.request.URL.absoluteString isEqualToString:@"https://profile.onliner.by/login#login"]) {
        webView.scrollView.contentOffset = CGPointMake(0, 200);
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:self completion:nil];
}
@end
