//
//  Network.m
//  OnlinerUP
//
//  Created by Alex Kardash on 8/27/14.
//
//

#import "Network.h"
#import "AFNetworking.h"
#import "OnlinerUPAppDelegate.h"

@implementation Network

+ (void)getUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*)headers andSerializer:(NSString*)serializer :(void (^)(NSArray *responseObject, NSString* responseString, NSError *error))block {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if ([serializer isEqualToString:@"JSON"]) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else if ([serializer isEqualToString:@"HTTP"])
    {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    for(id key in headers)
    {
        NSString* value = [headers objectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            NSMutableArray* array = [NSMutableArray array];
            if ([serializer isEqualToString:@"JSON"]) {
                array = responseObject;
            }
            block([NSArray arrayWithArray:array], operation.responseString, nil);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error connection %@",error);
        if (block) {
            block([NSArray array], [NSString string], error);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        }
    }];
}

+ (void)postUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*)headers andSerializer:(NSString*)serializer :(void (^)(NSArray *responseObject, NSString* responseString, NSError *error))block {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if ([serializer isEqualToString:@"JSON"]) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else if ([serializer isEqualToString:@"HTTP"])
    {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    for(id key in headers)
    {
        NSString* value = [headers objectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            NSMutableArray* array = [NSMutableArray array];
            if ([serializer isEqualToString:@"JSON"]) {
                array = responseObject;
            }
            block([NSArray arrayWithArray:array], operation.responseString, nil);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error connection %@",error);
        if (block) {
            block([NSArray array], [NSString string], error);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
        }
    }];
}

+ (NSString*) getHash
{
    NSURL *pageUrl = [NSURL URLWithString:@"http://baraholka.onliner.by/search.php?type=ufleamarket"];
    NSString *webData= [NSString stringWithContentsOfURL:pageUrl encoding:NSUTF8StringEncoding error:nil];
    return [self findTextIn: webData fromStart:@"AdvertUp.token = \"" toEnd: @"\""];
}

+ (NSString*) getBallance
{
    NSURL *pageUrl = [NSURL URLWithString:@"http://baraholka.onliner.by/search.php?type=ufleamarket"];
    NSString *webData= [NSString stringWithContentsOfURL:pageUrl encoding:NSUTF8StringEncoding error:nil];
    return [[Network findTextIn: webData fromStart:@"<span id=\"user-balance\">" toEnd: @"</span>"] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString*) findTextIn:(NSString*) text fromStart:(NSString*) startText toEnd:(NSString*) endText {
    NSString* value;
    NSRange start = [text rangeOfString:startText];
    if (start.location != NSNotFound)
    {
        value = [text substringFromIndex:start.location + start.length];
        NSRange end = [value rangeOfString:endText];
        if (end.location != NSNotFound)
        {
            value = [value substringToIndex:end.location];
        }
    }
    return value;
}

+ (BOOL)isAuthorizated{
    BOOL isAuth=NO;
    if ([self rightCookiesDidLoad]) {
        isAuth=[[NSUserDefaults standardUserDefaults] boolForKey:KeyForUserDefaultsAuthorisationInfo];
    }
    return isAuth;
}

+ (BOOL) rightCookiesDidLoad{
    NSHTTPCookieStorage *cookieStorage=[NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies=[cookieStorage cookies];
    NSHTTPCookie *cookie;
    for (cookie in cookies) {
        if ([cookie.name isEqualToString:@"onl_session"]) return true;
        
    }
    return false;
}

@end
