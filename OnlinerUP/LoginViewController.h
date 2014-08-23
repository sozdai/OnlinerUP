//
//  LoginViewController.h
//  OnlinerUP
//
//  Created by Alex Kardash on 6/24/14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *loginTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong,nonatomic) NSMutableData * responseData;
@property (strong,nonatomic) NSString* task;

+(void) cookiesStorageClearing;
- (IBAction)login:(id)sender;

@end
