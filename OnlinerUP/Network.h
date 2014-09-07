//
//  Network.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/27/14.
//
//

#import <Foundation/Foundation.h>

@interface Network : NSObject

+ (void)getUrl: (NSString*) url withParams: (NSDictionary*)params andHeaders:(NSDictionary*)headers andSerializer: (NSString*)serializer :(void (^)(NSArray *responseObject, NSString* responseString, NSError *error))block;

+ (void)postUrl: (NSString*) url withParams: (NSDictionary*) params andHeaders:(NSDictionary*)headers andSerializer:(NSString*)serializer :(void (^)(NSArray *responseObject, NSString* responseString, NSError *error))block;

+ (NSString*) getHash;

+ (NSString*) getBallance;

+ (NSString*) findTextIn:(NSString*) text fromStart:(NSString*) startText toEnd:(NSString*) endText;

+ (BOOL)isAuthorizated;

@end
