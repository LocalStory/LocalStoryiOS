//
//  NetworkController.h
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Story.h"
#import "Location.h"
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

@end
