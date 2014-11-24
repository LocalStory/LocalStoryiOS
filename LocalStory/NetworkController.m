//
//  NetworkController.m
//  LocalStory
//
//  Created by Nate Birkholz on 11/16/14.
//  Copyright (c) 2014 Code Fellows. All rights reserved
//

// Lots of help from http://nthn.me/posts/2012/objc-multipart-forms.html

#import "NetworkController.h"
#import "ICHObjectPrinter.h"

@interface NetworkController ()


@end

@implementation NetworkController

@synthesize someProperty;

// ########################################
#pragma mark SINGLETON Methods
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
  // Should not be necessary due to ARC
}

// ########################################
#pragma mark INIT
// ########################################

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.someProperty = @"Default Property Value";
    self.authCreateGet = @"https://GETAUTHHERE.COM";
    self.baseURL = @"http://dry-atoll-3756.herokuapp.com";
    self.locationsGet = @"/locations/HERE:lat/HERE:long";
    self.storyIdGet = @"/stories/:storyId";
    self.userIdAuthGet = @"/api/users/:userId";
    self.userAuthSignInGet = @"/api/users";
    self.storiesAuthPost = @"/api/stories";
    self.userAuthCreatePost = @"/api/users";
  }
  return self;
}

// ########################################
#pragma mark AUTH Flow
// ########################################

- (NSString *) checkForAuthToken {
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunched"] == YES) {
    NSString *jwt = [[NSUserDefaults standardUserDefaults] objectForKey:@"jwt"];
    NSLog(@"Value of JWT is %@", jwt);
    return jwt;
  }
  return (NSString *)@"none"; // Calls to this function check for this specific value
}


// ########################################
#pragma mark Data Methods
// ########################################

- (void) getDataFromURL:(NSURL *)urlForGet withDictionary:(NSDictionary *)dictionaryForHeader withCompletionHandler:(void (^)(NSData *dataFrom, NSError *networkError))completionHandler {
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlForGet];
  [request setHTTPMethod:@"GET"];

  for (id key in dictionaryForHeader) {
    [request addValue:dictionaryForHeader[key] forHTTPHeaderField:key];
  }
  NSLog(@"Values are %@", [dictionaryForHeader allValues]);
  NSURLSession *sessionForGet = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [sessionForGet dataTaskWithRequest:request completionHandler:^(NSData *dataFrom, NSURLResponse *responseFrom, NSError *error) {
    if (error != nil) {
      completionHandler(nil, error);
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)responseFrom;
      NSInteger statusCode = [httpResponse statusCode];
            NSLog(@"Status code in getDataFromURL is: %ld", (long)statusCode);
      switch (statusCode) {
        case 200:
          NSLog(@"Success");
          completionHandler(dataFrom, nil);
          break;
        case 403:
          NSLog(@"Server code 403: Most likely bad/missing JWT");
          break;
        case 500:
          NSLog(@"Server code 500: Server doesn't recognize the request");
          break;
        default:
          NSLog(@"Fell through to default: Response code is %ld", (long)httpResponse.statusCode);
          completionHandler(dataFrom, nil);
      }
    }
  }];

  [dataTask resume];
}

- (void)saveTokenFromData:(NSData *)data {
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  NSString *tokenFor = [[NSString alloc] initWithString:json[@"jwt"]];
  NSString *keyFor = @"jwt";
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
  [[NSUserDefaults standardUserDefaults] setObject:tokenFor forKey:keyFor];
  [[NSUserDefaults standardUserDefaults] synchronize];
}



// ########################################
#pragma mark GET Methods
// ########################################

- (void) getStoriesInView:(SearchArea *)searchAreaFor completionHandler:(void (^)(NSArray *stories))completionHandler  {

  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }

  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt", searchAreaFor.latMax, @"latMax", searchAreaFor.latMin, @"latMin", searchAreaFor.lngMax, @"lngMax", searchAreaFor.lngMin, @"lngMin",  nil];

  NSString *stringForGet = self.baseURL;
  stringForGet = [stringForGet stringByAppendingString:@"/api/stories/location/"];

  NSLog(@"getStoriesInView url is %@", [stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

  [self getDataFromURL:urlForGet withDictionary:headersDictionary withCompletionHandler:^(NSData *dataFrom, NSError *networkError){
    id dataToTest = [NSJSONSerialization JSONObjectWithData:dataFrom options:NSJSONReadingAllowFragments error:&networkError];
    if([dataToTest isKindOfClass:[NSDictionary class]]) {
      NSArray *oversizeArray = [[NSArray alloc] initWithObjects:@"tooMany", nil]; // Should test this return isEqual: @"tooMany" to prompt the user to zoom in
      completionHandler(oversizeArray);
    } else {
      NSArray *arrayFrom = [Story parseJsonIntoStories:dataFrom];
      NSLog(@"here");
      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSLog(@"ADDING");
        completionHandler(arrayFrom);
        NSLog(@"Retrieved %lu items", (unsigned long)arrayFrom.count);
      }];
    }
  }];
}

- (void) getStoriesForUserWithCompletionHandler:(void (^)(NSArray *stories))completionHandler  {
  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }
  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt", nil];
  NSString *stringForGet = self.baseURL;
  stringForGet = [stringForGet stringByAppendingString:@"/api/stories/user/"];
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

  [self getDataFromURL:urlForGet withDictionary:headersDictionary withCompletionHandler:^(NSData *dataFrom, NSError *networkError) {
    NSArray *arrayFrom = [Story parseJsonIntoStories:dataFrom];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      completionHandler(arrayFrom);
      NSLog(@"Retrieved %lu items", (unsigned long)arrayFrom.count);
    }];
  }];
}

- (void) getUIImageForStory:(Story *)selectedStory withCompletionHandler:(void (^)(UIImage *imageForStory))completionHandler {
  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }
  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt", nil];
  NSString *stringForGet = [NSString stringWithFormat:@"http://dry-atoll-3756.herokuapp.com/api/stories/single/image/%@", selectedStory.underscoreid];
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

  [self getDataFromURL:urlForGet withDictionary:headersDictionary withCompletionHandler:^(NSData *dataFrom, NSError *networkError){
    UIImage *imageFrom = [UIImage imageWithData:dataFrom];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      completionHandler(imageFrom);
    }];
  }];
}


// ########################################
#pragma mark POST Methods
// ########################################

- (void) postNewStoryToForm:(Story *)storyToPost withImage:(UIImage *)imageToPost {

  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }
  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt", nil];
  NSString *urlString = @"http://dry-atoll-3756.herokuapp.com";
  urlString = [urlString stringByAppendingString:@"/api/stories/"];
  NSURL *urlForGet = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlForGet];
  [request setHTTPMethod:@"POST"];
  for (id key in headersDictionary) {
    [request addValue:headersDictionary[key] forHTTPHeaderField:key];
  }
  NSLog(@"Header values are %@", [headersDictionary allValues]);
  NSString *boundary = @"0xF!5Hm0nG3r";
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
  //        Image file name handling
  NSString *filenameSeed = [storyToPost.title stringByReplacingOccurrencesOfString:@" " withString:@""];
  filenameSeed = [filenameSeed stringByAppendingString:@"_img"];
  NSString *filename = [filenameSeed stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  //        End Image file name handling

  NSMutableData *body = [[NSMutableData alloc] init];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  if (imageToPost) { // Only add an image to the form data if it is present...
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *imageData = UIImageJPEGRepresentation(imageToPost, 0.8);
    [body appendData:[NSData dataWithData:imageData]];
  }
  // Need to pass values for storyBody, title, lat, lng
  // pattern is boundary string then form data with the key as the value of name
  // and the value at the end of the series
  // Content-Type: text/plain should be inherent, may be text/HTML, which should be fine...

  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"title\"\r\n\r\n%@", storyToPost.title] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"storyBody\"\r\n\r\n%@", storyToPost.story] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n%@", storyToPost.lat] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"lng\"\r\n\r\n%@", storyToPost.lng] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

  [request setHTTPBody:body];

  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Error is: %@", error.localizedDescription);
    } else if (response) {
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
          case 200:
            NSLog(@"Server code 200: Success!");
            break;
          case 403:
            NSLog(@"Server code 403: Most likely bad/missing JWT");
            break;
          case 500:
            NSLog(@"Server code 500: Server doesn't recognize the request");
            break;
          default:
            NSLog(@"Fell through to default: Response code is %ld", (long)httpResponse.statusCode);
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

- (void) postAddNewUser:(NSString *)emailForUser withPassword:(NSString *)passwordForUser withConfirmedPassword:(NSString *)passwordConfirmForUser {
  NSString *urlString = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@/api/users",self.baseURL]];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:[NSURL URLWithString:urlString]];
  [request setHTTPMethod:@"POST"];

  NSString *boundary = @"0xF!5Hm0nG3r";
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
  NSMutableData *body = [[NSMutableData alloc] init];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n%@", emailForUser] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"password\"\r\n\r\n%@", passwordForUser] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"passwordConfirm\"\r\n\r\n%@", passwordConfirmForUser] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

  [request setHTTPBody:body];

  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Error is: %@", error.localizedDescription);
    } else if (response) {
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
          case 200:
            [self saveTokenFromData:data];
            break;
          case 403:
            NSLog(@"Server code 403: Most likely bad/missing JWT");
            break;
          case 500:
            NSLog(@"Server code 500: Server doesn't recognize the request");
            break;
          default:
            NSLog(@"Fell through to default: Response code is %ld", (long)httpResponse.statusCode);
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

// ########################################
#pragma mark NETWORK ELEMENTS
// ########################################





// ########################################
#pragma mark DEPRECATED
// ########################################


- (void) signInToServerWithCompletionHandler:(void (^)(NSString *jwt))completionHandler { // Deprecated, may add login but currently unnecessary
  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }
  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt",  nil];
  NSString *stringForGet = self.baseURL;
  stringForGet = [stringForGet stringByAppendingString:@"/api/users"];
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [self getDataFromURL:urlForGet withDictionary:headersDictionary withCompletionHandler:^(NSData *dataFrom, NSError *networkError){
    NSArray *arrayFrom = [Story parseJsonIntoStories:dataFrom];
    NSString *jwt = arrayFrom.firstObject;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      completionHandler(jwt);
    }];
  }];
}

- (void)logHTTPHeaderFieldsFromHTTTPResponse:(NSHTTPURLResponse *)httpResponse { // Nice to have around for logging problems
  NSDictionary *headerStrings = [httpResponse allHeaderFields];
  [headerStrings enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
    NSLog(@"The key is %@", key);
    NSLog(@"The value is %@", object);
  }];
}

@end
