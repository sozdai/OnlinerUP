//
//  MyAd.h
//  OnlinerUP
//
//  Created by Alex on 20.07.14.
//  Copyright (c) 2014 sozdai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyAd : NSObject

@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* topicID;
@property (strong, nonatomic) NSString* topicPrice;
@property (strong, nonatomic) NSString* topicType;
@property (strong, nonatomic) NSString* timeLeft;
@property (strong, nonatomic) NSString* imageUrl;
@property (strong, nonatomic) NSData* imageData;
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* commentsCount;
@property (assign, nonatomic) BOOL isRead;
@property (strong, nonatomic) NSString* sellType;

@end
