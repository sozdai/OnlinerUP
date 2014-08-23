//
//  MyMessage.h
//  OnlinerUP
//
//  Created by Alex Kardash on 8/22/14.
//
//

#import <Foundation/Foundation.h>

@interface MyMessage : NSObject

@property (strong, nonatomic) NSString* subject;
@property (strong, nonatomic) NSString* folder;
@property (strong, nonatomic) NSString* authorID;
@property (strong, nonatomic) NSString* authorName;
@property (strong, nonatomic) NSString* messageID;
@property (assign, nonatomic) NSTimeInterval date;
@property (assign, nonatomic) BOOL isRead;

@end
