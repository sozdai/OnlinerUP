//
//  Baraholka.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/24/14.
//
//

#import <Foundation/Foundation.h>

@interface Baraholka : NSObject

@property (strong, nonatomic) NSString* topicID;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* type;
@property (assign, nonatomic) BOOL isHighlighted;
@property (strong, nonatomic) NSString* price;
@property (strong, nonatomic) NSString* currency;
@property (strong, nonatomic) NSString* isTorg;
@property (strong, nonatomic) NSString* city;
@property (strong, nonatomic) NSString* description;
@property (strong, nonatomic) NSString* imageUrl;
@property (strong, nonatomic) NSData* imageData;
@property (strong, nonatomic) NSString* sellType;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* authorName;
@property (strong, nonatomic) NSString* authorID;
@property (strong, nonatomic) NSString* commentsCount;
@property (assign, nonatomic) BOOL isRead;



@end
