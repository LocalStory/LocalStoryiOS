//
//  Story.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved
//

#import "Story.h"

@implementation Story

- (instancetype)init:(NSDictionary *)storyJSONDictionary
{
  self = [super init];
  if (self) {
    self.storyDictionary = storyJSONDictionary;
    self.userId = (NSString *)storyJSONDictionary[@"userId"];
    self.story = (NSString *)storyJSONDictionary[@"storyBody"];
    self.title = (NSString *)storyJSONDictionary[@"title"];
    self.lat = (NSString *)storyJSONDictionary[@"lat"];
    self.lng = (NSString *)storyJSONDictionary[@"lng"];
    self.latVal = [self.lat doubleValue];
    self.lngVal = [self.lng doubleValue];
    NSString *dateStr = (NSString *)storyJSONDictionary[@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    self.date = date;
    self.underscoreid = (NSString *)storyJSONDictionary[@"_id"];
  }
  return self;
}

+ (NSArray *)parseJsonIntoStories:(NSData *)rawJSONData {
  NSError *error;

  NSDictionary *topLevelItemFromJSON = [NSJSONSerialization JSONObjectWithData:rawJSONData options:NSJSONReadingAllowFragments error:&error];
  NSLog(@"Error in Story parse is: %@", error.localizedDescription);

  if ([topLevelItemFromJSON isKindOfClass: [NSArray class]]) {
    NSLog(@"Found object as array");
    NSArray *arrayOfStoryObjectsFromJSON = (NSArray *)topLevelItemFromJSON;
    NSMutableArray *storiesParsed = [[NSMutableArray alloc]init];
    for (NSDictionary *storyJSONDictionary in arrayOfStoryObjectsFromJSON) {
      Story *storyNew = [[Story alloc] init:storyJSONDictionary];
      [storiesParsed addObject:storyNew];
    }
    NSLog(@"Count of storeis parsed is %lu", (unsigned long)storiesParsed.count);
    return storiesParsed;
  } else { // Fail case ifJSON sturcture is not as expected [array of Stories]
    NSLog(@"FAIL: JSON Object item at key 'body' is not Array. Debug now.");
    NSArray *failArray = [[NSArray alloc] initWithObjects:@"FAIL CASE", @"FAIL CASE", @"FAIL CASE", nil];
    return failArray;
  }
}

@end