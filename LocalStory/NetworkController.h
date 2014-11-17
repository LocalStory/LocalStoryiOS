//
//  NetworkController.h
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "Story.h"
#import "User.h"
#import <UIKit/UIKit.h>

@interface NetworkController : NSObject{
  NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;

+ (id)sharedNetworkController;

@end
