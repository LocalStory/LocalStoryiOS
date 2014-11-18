//
//  Story.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Story.h"

@implementation Story

- (instancetype)init:(NSDictionary *)storyJSONDictionary
{
  self = [super init];
  if (self) {
    self.storyDictionary = storyJSONDictionary;
    self.userId = (NSString *)storyJSONDictionary[@"userId"];
    self.story = (NSString *)storyJSONDictionary[@"story"];
    self.title = (NSString *)storyJSONDictionary[@"title"];
    self.lat = (NSString *)storyJSONDictionary[@"lat"];
    self.lng = (NSString *)storyJSONDictionary[@"lng"];
    self.latVal = [self.lat doubleValue];
    self.lngVal = [self.lng doubleValue];
  }
  return self;
}

+ (NSArray *)parseJsonIntoStories:(NSData *)rawJSONData {
  NSError *error;
  NSLog(@"Error is: %@", error.localizedDescription);

  NSDictionary *topLevelObjectFromJSON = [NSJSONSerialization JSONObjectWithData:rawJSONData options:NSJSONReadingAllowFragments error:&error];

  if ([topLevelObjectFromJSON[@"items"] isKindOfClass: [NSArray class]]) {
    NSArray *arrayOfStoryObjectsFromJSON = (NSArray *)topLevelObjectFromJSON[@"items"];
    NSMutableArray *storiesParsed = [[NSMutableArray alloc]init];

    for (NSDictionary *storyJSONDictionary in arrayOfStoryObjectsFromJSON) {
      Story *storyNew = [[Story alloc] init:storyJSONDictionary];
      [storiesParsed addObject:storyNew];
    }
    return storiesParsed;

  } else { // Fail case ifJSON sturcture is not as expected {items key:[array of Stories]}
    NSLog(@"FAIL: JSON Object item at key 'items' is not Array. Debug now.");
    NSArray *failArray = [[NSArray alloc] initWithObjects:@"FAIL CASE", @"FAIL CASE", @"FAIL CASE", nil];
    return failArray;
  }

}

@end