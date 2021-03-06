//
//  AppDelegate.h
//  LocalStory
//
//  Created by Jacob Hawken on 11/14/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SignUpViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//TEMP
@property (strong, nonatomic) SignUpViewController *signupVC;

@end

