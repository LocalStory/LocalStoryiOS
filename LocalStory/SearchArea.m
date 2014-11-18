//
//  SearchArea.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "SearchArea.h"

@implementation SearchArea

- (instancetype)init:(MKCoordinateRegion)coordinateRegion
{
  self = [super init];
  if (self) {
    MKCoordinateRegion regionFor = coordinateRegion;
    CLLocationCoordinate2D regionCenter = regionFor.center;

    double halfLat = regionFor.span.latitudeDelta / 2;
    double halfLng = regionFor.span.longitudeDelta / 2;

    NSNumber *latMaxVal = [NSNumber numberWithDouble:(regionCenter.latitude + halfLat)];
    NSNumber *latMinVal = [NSNumber numberWithDouble:(regionCenter.latitude - halfLat)];
    NSNumber *lngMaxVal = [NSNumber numberWithDouble:(regionCenter.longitude + halfLng)];
    NSNumber *lngMinVal = [NSNumber numberWithDouble:(regionCenter.longitude - halfLng)];

    self.latMax = [latMaxVal stringValue];
    self.latMin = [latMinVal stringValue];
    self.lngMax = [lngMaxVal stringValue];
    self.lngMin = [lngMinVal stringValue];
  }
  return self;
}

@end