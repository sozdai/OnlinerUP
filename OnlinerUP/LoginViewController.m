//
//  LoginViewController.m
//  OnlinerUP
//
//  Created by Alex Kardash on 6/24/14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import "LoginViewController.h"
#import "OnlinerUPAppDelegate.h"
#import "OnlinerKeyChain.h"
#import "MyAdTableViewController.h"
#import "MBProgressHUD.h"
#import "SVWebViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    [self.loginTextField setText:@"Мистер Грин"];
    [self.passwordTextField setText:@"sashajorik"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [self loginToApp];
}

- (IBAction)closeButtonClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:self completion:nil];
}

- (IBAction)registerButtonClick:(UIButton *)sender {
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"https://profile.onliner.by/reg"];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)forgotPasswordClick:(UIButton *)sender {
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:@"https://profile.onliner.by/login/lost"];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void) loginToApp
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *dataString=[NSString stringWithFormat:@"username=%@&password=%@&autologin=on&x=306&y=38",self.loginTextField.text,self.self.passwordTextField.text];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://profile.onliner.by/login?redirect=http://baraholka.onliner.by/search.php?type=ufleamarket"]];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithString:dataString] dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPBody = body;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!theConnection) NSLog(@"No connection");
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.task = [NSString stringWithFormat:@"%@",response];
    [self.responseData setLength:0];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка соединения" message:@"Проверьте соединение с интернетом" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([self rightCookiesDidLoad]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForUserDefaultsAuthorisationInfo];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [OnlinerKeyChain writeNewPassword: self.passwordTextField.text];
        [self dismissViewControllerAnimated:self completion:nil];
        [[NSUserDefaults standardUserDefaults] setValue:self.loginTextField.text forKey:KeyForUserDefaultUserName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }		
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка авторизации" message:@"Неправильный логин или пароль" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(BOOL)isAuthorizated{
    BOOL isAuth=NO;
    if ([self rightCookiesDidLoad]) {
        isAuth=[[NSUserDefaults standardUserDefaults] boolForKey:KeyForUserDefaultsAuthorisationInfo];
    }
    return isAuth;
}

-(bool) rightCookiesDidLoad{
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies=[cookieStorage cookies];
    NSHTTPCookie *cookie;
    for (cookie in cookies) {
        if ([cookie.name isEqualToString:@"onl_session"]) return true;
    
    }
    return false;
}

+(void) cookiesStorageClearing{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KeyForUserDefaultsAuthorisationInfo ];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)goButtonClicked:(UITextField *)sender {
    [self loginToApp];
    [sender resignFirstResponder];
}



@end
