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
  }
  return self;
}

@end
