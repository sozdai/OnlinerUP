//
//  OnlinerKeyChain.m
//  OnlinerBy
//
//  Created by Mary Ozheredova on 16.06.14.
//  Copyright (c) 2014 Group7IosDevelopment. All rights reserved.
//

#import "OnlinerKeyChain.h"
#import "OnlinerUPAppDelegate.h"

@implementation OnlinerKeyChain

+(NSDictionary*) LoginAndPassword{
    NSString *userName=[[NSUserDefaults standardUserDefaults] valueForKey:KeyForUserDefaultUserName];
    if (!userName) return nil;
    NSData* passwordData=[OnlinerKeyChain searchKeychainCopyMatching:@"password"];
    if (!passwordData) return nil;
    NSString *password=[[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
    NSDictionary *loginAndPassword=@{@"login" : userName, @"password": password};
    return loginAndPassword;
}

+(void) writeNewPassword:(NSString*) password{
    [OnlinerKeyChain deleteKeychainValue:@"password" ];
    [OnlinerKeyChain createKeychainValue:password forIdentifier:@"password"];
    
}
+ (void)deleteKeychainValue:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [OnlinerKeyChain newSearchDictionary:identifier];
     CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef)searchDictionary;
     OSStatus status = SecItemDelete(cfquery);
    if (status!=errSecSuccess) {
        NSLog(@"Deleteing from keychain problem");
        
    } else NSLog(@"deleted from keychain");
    CFRelease(cfquery);
}
+ (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:CFBridgingRelease(kSecClassGenericPassword) forKey:CFBridgingRelease(kSecClass)];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(id)CFBridgingRelease(kSecAttrGeneric)];
    [searchDictionary setObject:encodedIdentifier forKey:(id)CFBridgingRelease(kSecAttrAccount)];
    //[searchDictionary setObject:serviceName forKey:(id)CFBridgingRelease(kSecAttrService)];
    
    return searchDictionary;
}
+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(id)CFBridgingRelease(kSecValueData)];
    
    OSStatus status = SecItemAdd((CFDictionaryRef)CFBridgingRetain(dictionary), NULL);
    if (status == errSecSuccess) {
        NSLog(@"created secsessfuly");
        return YES;
    }
    return NO;
}
+ (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [OnlinerKeyChain newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(id)CFBridgingRelease(kSecMatchLimitOne) forKey:(id)CFBridgingRelease(kSecMatchLimit)];
    
    // Add search return types
    [searchDictionary setObject:(id)kCFBooleanTrue forKey:(id)CFBridgingRelease(kSecReturnData)];
    
    // NSData *result = nil;
    /*1*/ CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef)searchDictionary;
    /*2*/ CFDictionaryRef cfresult = NULL;
    /*3*/ OSStatus status = SecItemCopyMatching(cfquery, (CFTypeRef *)&cfresult);
    /*4*/ CFRelease(cfquery);
    /*5*/ NSData *result = (__bridge_transfer NSData *)cfresult;
    
    return result;
}

@end
