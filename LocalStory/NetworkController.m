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

- (void)stubForGetMethod {
  
}

- (void)stubForPostMethod {
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
  [request addValue:@"TOKEN GOES HERE" forHTTPHeaderField:@"JWT"];
  [request setHTTPBody:postdata];
  request.HTTPBody = postdata;

  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Error is: %@", error.localizedDescription);
    } else if (response) {
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
          case 200: {
          [self saveTokenFromData:data];
            break;
          }
          case 403:
            NSLog(@"NOT AUTHORIZED");
            break;

          case 500:
            NSLog(@"SERVER FAILURE");
            break;

          default:
            break;
        }

      } else {
        NSLog(@"Response is not HTTP");
      }
    } else {
      NSLog(@"Response is NIL");
    }
  }];
  [dataTask resume];
}

- (void)saveTokenFromData:(NSData *)data {
  NSString *tokenResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@"="];
  NSArray *tokenSeedArray = [[tokenComponents objectAtIndex:1] componentsSeparatedByString:@"&"];
  NSString *tokenFor = (NSString *)[tokenSeedArray firstObject];
  NSString *keyFor = @"AuthToken";
  [[NSUserDefaults standardUserDefaults] setObject:tokenFor forKey:keyFor];
  [[NSUserDefaults standardUserDefaults] synchronize];
  NSLog(@"Saved a token value %@ to the key %@ in NSUserDefaults", tokenFor, keyFor);
}




@end
