//
//  Story.h
//  LocalStory
//
//  Created by Nathan Birkholz on 11/16/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "User.h"
#import <UIKit/UIKit.h>


@interface Story : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *story;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;
@property (nonatomic, strong) User *user;

@end
