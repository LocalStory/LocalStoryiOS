//
//  Constants.h
//  LocalStory
//
//  Created by Nathan Birkholz on 12/9/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

#ifdef DEBUG

#else
#define NSLog(...)
#endif

@end
