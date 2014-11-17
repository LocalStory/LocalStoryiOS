//
//  NetworkController.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "NetworkController.h"

@implementation NetworkController

@synthesize someProperty;

// ########################################
#pragma mark Singleton Methods
// ########################################


+ (id)sharedNetworkController {
  static NetworkController *sharedNetworkController = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedNetworkController = [[self alloc] init];
  });
  return sharedNetworkController;
}

- (void)dealloc {
  // ARC is awesome but just in case...
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.someProperty = @"Default Property Value";

    self.authCreateGet = @"https://GETAUTHHERE.COM";
    self.baseURL = @"BASEURL";
    self.locationsGet = @"/locations/HERE:lat/HERE:long";
    self.storyIdGet = @"/stories/:storyId";
    self.userIdAuthGet = @"/api/users/:userId";
    self.userAuthSignInGet = @"/api/users";
    self.storiesAuthPost = @"/api/stories";
    self.userAuthCreatePost = @"/api/users";
  }
  return self;
}

- (NSString *) generateAuthRequest {
  NSString *returnForNow = @"RAWR, I say, RAWR!!!";

  return returnForNow;
}

- (void) stubForPostMethod {
  NSURL *callbackURL = [[NSURL alloc] init]; // will get callbackURL as a parameter eventually
  NSString *query = callbackURL.query;

  NSArray *components = [query componentsSeparatedByString:@"code="];
  NSString *code = [components lastObject];
  NSString *urlQuery = @"CLIENTID element of query";
  urlQuery = [urlQuery stringByAppendingString:(NSString *)@"&"];
  urlQuery = [urlQuery stringByAppendingString:(NSString *)@"CLIENTSECRET element goes here"];
  urlQuery = [urlQuery stringByAppendingString:(NSString *)@"&"];
  urlQuery = [urlQuery stringByAppendingString:code];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"POST URL goes here"]];
  [request setHTTPMethod:@"POST"];
  NSData *postdata = [urlQuery dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSInteger length = [postdata length];
  NSString *lengthString = [NSString stringWithFormat:@"%ld", (long)length];
  [request setValue:lengthString forHTTPHeaderField:@"content-length"];
  [request setValue:@"TOKEN GOES HERE" forHTTPHeaderField:@"TOKEN HEADER"];
  [request setHTTPBody:postdata];
  request.HTTPBody = postdata;

}

@end
