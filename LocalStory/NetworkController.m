//
//  NetworkController.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

// Lots of help from http://stackoverflow.com/questions/24250475/post-multipart-form-data-with-objective-c
// Even more help from http://nthn.me/posts/2012/objc-multipart-forms.html

#import "NetworkController.h"
#import "ICHObjectPrinter.h"

@interface NetworkController ()

@property (nonatomic, strong) NSArray *testArray;

@end

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

    self.testArray = [[NSArray alloc] initWithObjects:0,1,2,3, nil];

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
    NSLog(@"jwt value is >>>>>>>>> %@", jwt);
    return jwt;
  }
  return (NSString *)@"none";
}

- (void) signInToServerWithCompletionHandler:(void (^)(NSString *jwt))completionHandler {
  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }
  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt",  nil];
  NSString *stringForGet = self.baseURL;
  stringForGet = [stringForGet stringByAppendingString:@"/api/users"];
  NSLog(@"signInToServer url is %@", [stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
  [self getDataFromURL:urlForGet withDictionary:headersDictionary completionHandler:^(NSData *dataFrom, NSError *networkError){
    NSArray *arrayFrom = [Story parseJsonIntoStories:dataFrom];
    NSString *jwt = arrayFrom.firstObject;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      completionHandler(jwt);
    }];
  }];
}

// ########################################
#pragma mark Data Methods
// ########################################

- (void) getDataFromURL:(NSURL *)urlForGet withDictionary:(NSDictionary *)dictionaryForHeader completionHandler:(void (^)(NSData *dataFrom, NSError *networkError))completionHandler {
        NSLog(@"getDataFromURL");
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:urlForGet];
  [request setHTTPMethod:@"GET"];

  for (id key in dictionaryForHeader) {
          NSLog(@"key=%@ value=%@", key, dictionaryForHeader[key]);
    [request addValue:dictionaryForHeader[key] forHTTPHeaderField:key];
          NSLog(@"Values are %@", [dictionaryForHeader allValues]);
  }

  NSURLSession *sessionForGet = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [sessionForGet dataTaskWithRequest:request completionHandler:^(NSData *dataFrom, NSURLResponse *responseFrom, NSError *error) {

    if (error != nil) {
            NSLog(@"ERROR RIGHT HERE: %@", [error localizedDescription]);
      completionHandler(nil, error);
    } else {
            NSLog(@"No Error");
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)responseFrom;
      NSDictionary *strongStrings = [httpResponse allHeaderFields];
      for (NSString *item in strongStrings) {
            NSLog(@"Header item is %@", item);
      }

      [strongStrings enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
              NSLog(@"The key is %@", key);
              NSLog(@"The value is %@", object);
      }];

      NSInteger statusCode = [httpResponse statusCode];
            NSLog(@"Status code in getDataFromURL is: %ld", (long)statusCode);
      switch (statusCode) {
        case 200: {
                NSLog(@"Success");
          completionHandler(dataFrom, nil);
          break;
        }
        case 403:
          NSLog(@"Server code 403");
          break;

        case 500:
          NSLog(@"Server code 500");
          break;
          
        default: {
                NSLog(@"Fell through to default");
                NSLog(@"The code is %@", dataFrom);
          completionHandler(dataFrom, nil);
        }
      }
    }
  }];

  [dataTask resume];
}

- (void)saveTokenFromData:(NSData *)data {
  NSString *tokenResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
  NSArray *tokenComponents = [tokenResponse componentsSeparatedByString:@":"];
  NSString *tokenFor = [NSString stringWithString:[tokenComponents objectAtIndex:1]];
  NSString *keyFor = @"jwt";
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
  [[NSUserDefaults standardUserDefaults] setObject:tokenFor forKey:keyFor];
  [[NSUserDefaults standardUserDefaults] synchronize];
  NSLog(@"Saved a token value %@ to the key %@ in NSUserDefaults", tokenFor, keyFor);
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

  [self getDataFromURL:urlForGet withDictionary:headersDictionary completionHandler:^(NSData *dataFrom, NSError *networkError){
    NSArray *arrayFrom = [Story parseJsonIntoStories:dataFrom];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      completionHandler(arrayFrom);

      for (Story *item in arrayFrom) {
        NSLog(@"Title is %@ and latitude is %@", item.title, item.lat);
      }
    }];
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

  NSLog(@"getStoriesInView url is %@", [stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

  [self getDataFromURL:urlForGet withDictionary:headersDictionary completionHandler:^(NSData *dataFrom, NSError *networkError) {

    NSArray *arrayFrom = [Story parseJsonIntoStories:dataFrom];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      completionHandler(arrayFrom);
      for (Story *item in arrayFrom) {
        NSLog(@"Title is %@ and latitude is %@", item.title, item.lat);
      }
    }];
  }];
}


-(void) getUIImageForStory:(Story *)selectedStory withCompletionHandler:(void (^)(UIImage *imageForStory))completionHandler {

  NSString *checkToken = self.checkForAuthToken;
  if ([checkToken isEqual: @"none"]) {
    NSLog(@"NO TOKEN FOUND");
  } else {
    NSLog(@"Token found");
  }

  NSDictionary *headersDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:checkToken, @"jwt", nil];

  NSString *stringForGet = [NSString stringWithFormat:@"http://dry-atoll-3756.herokuapp.com/api/stories/single/image/%@", selectedStory.underscoreid];

  NSLog(@"getStoriesInView url is %@", [stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
  NSURL *urlForGet = [NSURL URLWithString:[stringForGet stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

  [self getDataFromURL:urlForGet withDictionary:headersDictionary completionHandler:^(NSData *dataFrom, NSError *networkError){
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

  NSString *urlString = [[NSString alloc]initWithString:[NSString stringWithFormat:@"%@/api/users",self.baseURL]];

  NSLog(@"getStoriesInView url is %@", [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
  NSURL *urlForGet = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlForGet];
  [request setHTTPMethod:@"POST"];
  for (id key in headersDictionary) {
    NSLog(@"key=%@ value=%@", key, headersDictionary[key]);
    [request addValue:headersDictionary[key] forHTTPHeaderField:key];
    NSLog(@"Values are %@", [headersDictionary allValues]);
  }

  NSString *boundary = @"0xKhTmLbOuNdArY";

  //        Begin Image section

  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

  NSString *filenameSeed = [storyToPost.title stringByReplacingOccurrencesOfString:@" " withString:@""];
  filenameSeed = [filenameSeed stringByAppendingString:@"_img"];
  NSString *filename = [filenameSeed stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

  NSData *imageData = UIImageJPEGRepresentation(imageToPost, 0.8);

  //         End of image section

  NSMutableData *body = [[NSMutableData alloc] init];

  [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
  [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]]; // Move up?
  [body appendData:[NSData dataWithData:imageData]];


  // storyBody, title, lat, lng
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

  NSLog(@"----------Object description is %@",[ICHObjectPrinter descriptionForObject:request]);

  NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Error is: %@", error.localizedDescription);
    } else if (response) {
      NSLog(@"\n\n\n\n\n\n\n\r----------response description is %@",[ICHObjectPrinter descriptionForObject:response]);
      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        switch (httpResponse.statusCode) {
          case 200: {
            NSLog(@"200");
            break;
          }
          case 403:
            NSLog(@"NOT AUTHORIZED");
            break;

          case 500:
            NSLog(@"SERVER FAILURE");
            break;

          default:
            NSLog(@"Response code is %ld", (long)httpResponse.statusCode);
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

  NSString *boundary = @"0xKhTmLbOuNdArY";

  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

  NSMutableData *body = [[NSMutableData alloc] init];

  // email, password, passwordConfirm
  // pattern is boundary string then form data with the key as the value of name


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
          case 200: {
            [self saveTokenFromData:data];
            break;
          }
          case 403:
            NSLog(@"NOT AUTHORIZED");
            break;

          case 500:
            NSLog(@"Server response : 500");
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

// ########################################
#pragma mark DEPRECATED
// ########################################

- (NSString *) generateAuthRequest {
  NSString *returnForNow = @"RAWR, I say, RAWR!!!";

  return returnForNow;
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






@import MobileCoreServices;    // only needed in iOS

- (NSString *)mimeTypeForPath:(NSString *)path
{
  // get a mime type for an extension using MobileCoreServices.framework

  CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
  CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
  assert(UTI != NULL);

  NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
  assert(mimetype != NULL);

  CFRelease(UTI);

  return mimetype;
}

- (NSData *)createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters paths:(NSArray *)paths fieldName:(NSString *)fieldName
{
  NSMutableData *httpBody = [NSMutableData data];

  // add params (all params are strings)

  [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
  }];

  // add image data

  for (NSString *path in paths) {
    NSString *filename  = [path lastPathComponent];
    NSData   *data      = [NSData dataWithContentsOfFile:path];
    NSString *mimetype  = [self mimeTypeForPath:path];

    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
  }

  [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

  return httpBody;
}




@end
