//
//  NetworkController.h
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Story.h"
#import "Location.h"
#import "SearchArea.h"
#import <UIKit/UIKit.h>

@interface NetworkController : NSObject{
  NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, strong) NSString *authCreateGet;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSString *locationsGet;
@property (nonatomic, strong) NSString *storyIdGet;
@property (nonatomic, strong) NSString *userIdAuthGet;
@property (nonatomic, strong) NSString *userAuthSignInGet;
@property (nonatomic, strong) NSString *storiesAuthPost;
@property (nonatomic, strong) NSString *userAuthCreatePost;

+ (id)sharedNetworkController;

- (void)saveTokenFromData:(NSData *)data;
- (NSString *) checkForAuthToken;
- (void) getDataFromURL:(NSURL *)urlForGet withDictionary:(NSDictionary *)dictionaryForHeader completionHandler:(void (^)(NSData *dataFrom, NSError *networkError))completionHandler;
- (void) getStoriesInView:(SearchArea *)searchAreaFor completionHandler:(void (^)(NSArray *stories))completionHandler ;
- (void) getStoriesForUserWithCompletionHandler:(void (^)(NSArray *stories))completionHandler;
- (void) postAddNewUser:(NSString *)emailForUser withPassword:(NSString *)passwordForUser withConfirmedPassword:(NSString *)passwordConfirmForUser;
- (void) postNewStoryToForm:(Story *)storyToPost withImage:(UIImage *)imageToPost;
-(void) getUIImageForStory:(Story *)selectedStory withCompletionHandler:(void (^)(UIImage *imageForStory))completionHandler;

@end
