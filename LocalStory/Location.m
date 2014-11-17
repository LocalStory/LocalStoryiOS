//
//  Location.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Location.h"


@implementation Location

- (instancetype)init:(CLLocationCoordinate2D )coordinateFromMethod;
{ // Whereever we register the button press to create a new story, we should initialize a Location object with this init
  self = [super init];
  if (self) {
    self.locationOfDevice = coordinateFromMethod;
    NSNumber *latNumber = [NSNumber numberWithDouble:coordinateFromMethod.latitude];
    NSNumber *lngNumber = [NSNumber numberWithDouble:coordinateFromMethod.longitude];
    self.latString = [latNumber stringValue];
    self.lngString = [lngNumber stringValue];
  }
  return self;
}



@end
