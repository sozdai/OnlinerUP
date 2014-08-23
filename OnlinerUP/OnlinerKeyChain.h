//
//  OnlinerKeyChain.h
//  OnlinerBy
//
//  Created by Mary Ozheredova on 16.06.14.
//  Copyright (c) 2014 Group7IosDevelopment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlinerKeyChain : NSObject
+(NSDictionary*) LoginAndPassword;
+(void) writeNewPassword:(NSString*) password;
+(void)deleteKeychainValue:(NSString *)identifier;

@end
