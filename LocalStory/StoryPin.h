//
//  StoryPin.h
//  LocalStory
//
//  Created by Jacob Hawken on 11/20/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Constants.h"
#import <MapKit/MapKit.h>
#import "Story.h"

@interface StoryPin : MKPointAnnotation

@property (nonatomic, strong) Story* story;

@end