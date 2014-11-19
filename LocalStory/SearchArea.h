//
//  SearchArea.h
//  LocalStory
//
//  Created by Nathan Birkholz on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchArea : NSObject

@property (nonatomic, strong) NSString *latMin;
@property (nonatomic, strong) NSString *latMax;
@property (nonatomic, strong) NSString *lngMin;
@property (nonatomic, strong) NSString *lngMax;

- (instancetype)init:(MKCoordinateRegion)coordinateRegion;

@end
