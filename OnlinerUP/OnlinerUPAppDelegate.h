//
//  OnlinerUPAppDelegate.h
//  OnlinerUP
//
//  Created by Alex Kardash on 7/30/14.
//
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

extern NSString* const KeyForUserDefaultsAuthorisationInfo;
extern NSString* const KeyForUserDefaultUserName;
extern NSString* const KeyForNeedReloadForAdsPage;
extern NSString* const KeyForNeedReloadForMessagesPage;
extern NSString* const KeyForIsAdsRemoved;
extern NSString* const KeyForIsUpUnlocked;
extern NSString* const KeyForShouldShowAp;


@interface OnlinerUPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIView* adsView;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
