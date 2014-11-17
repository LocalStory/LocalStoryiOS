//
//  Location.h
//  LocalStory
//
//  Created by Nathan Birkholz on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "NetworkController.m"
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject

@property (nonatomic) CLLocationCoordinate2D locationOfDevice;
@property (nonatomic, strong) NSString *latString;
@property (nonatomic, strong) NSString *lngString;



@end