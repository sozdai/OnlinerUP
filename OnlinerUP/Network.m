//
//  Network.m
//  OnlinerUP
//
//  Created by Alex Kardash on 8/27/14.
//
//

#import "Network.h"
#import "AFNetworking.h"

@implementation Network

+ (void)getUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*)headers :(void (^)(NSArray *array, NSString* responseString, NSError *error))block {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    for(id key in headers)
    {
        NSString* value = [headers objectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            block([NSArray arrayWithArray:responseObject], operation.responseString, nil);
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

+ (void)postUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*)headers :(void (^)(NSArray *array, NSString* responseString, NSError *error))block {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    for(id key in headers)
    {
        NSString* value = [headers objectForKey:key];
        [manager.requestSerializer setValue:value forHTTPHeaderField:key];
    }
    
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (block) {
            block([NSArray arrayWithArray:responseObject], operation.responseString, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error connection %@",error);
        if (block) {
            block([NSArray array], [NSString string], error);
        }
    }];
}

@end
