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

@interface LoginViewController ()

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

- (void) loginToApp
{
        
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
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
   NSLog(@"Ошбика соединения");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([self rightCookiesDidLoad]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyForUserDefaultsAuthorisationInfo];
        [OnlinerKeyChain writeNewPassword: self.passwordTextField.text];
        NSLog(@"Success");
        [self dismissViewControllerAnimated:self completion:nil];
    }		
    else {
        NSLog( @"Не удалось авторизироваться.\n Проверьте логин и пароль.");
    }
    
}

-(BOOL)isAuthorizated{
    BOOL isAuth=[[NSUserDefaults standardUserDefaults] boolForKey:KeyForUserDefaultsAuthorisationInfo];
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
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KeyForUserDefaultsAuthorisationInfo ];
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}




@end
