//
//  SearchArea.m
//  LocalStory
//
//  Created by Nathan Birkholz on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved
//

#import "SearchArea.h"

@implementation SearchArea

- (instancetype)init:(MKCoordinateRegion)coordinateRegion
{
  self = [super init];
  if (self) {
    MKCoordinateRegion regionFor = coordinateRegion;
    CLLocationCoordinate2D regionCenter = regionFor.center;

    double midLat = regionFor.center.latitude;
    double midLng = regionFor.center.longitude;

    double halfLat = regionFor.span.latitudeDelta / 2;
    double halfLng = regionFor.span.longitudeDelta / 2;

    NSNumber *latMaxVal = [[NSNumber alloc] init];
    NSNumber *latMinVal = [[NSNumber alloc] init];
    NSNumber *lngMaxVal = [[NSNumber alloc] init];
    NSNumber *lngMinVal = [[NSNumber alloc] init];

    if (midLat > 0) {

      latMaxVal = [NSNumber numberWithDouble:(regionCenter.latitude + halfLat)];
      latMinVal = [NSNumber numberWithDouble:(regionCenter.latitude - halfLat)];

    } else {

      latMaxVal = [NSNumber numberWithDouble:(regionCenter.latitude - halfLat)];
      latMinVal = [NSNumber numberWithDouble:(regionCenter.latitude + halfLat)];

    }

    if (midLng > 0) {

      lngMaxVal = [NSNumber numberWithDouble:(regionCenter.longitude + halfLng)];
      lngMinVal = [NSNumber numberWithDouble:(regionCenter.longitude - halfLng)];

    } else {

      lngMaxVal = [NSNumber numberWithDouble:(regionCenter.longitude - halfLng)];
      lngMinVal = [NSNumber numberWithDouble:(regionCenter.longitude + halfLng)];

    }

    self.latMax = [latMaxVal stringValue];
    self.latMin = [latMinVal stringValue];
    self.lngMax = [lngMaxVal stringValue];
    self.lngMin = [lngMinVal stringValue];
  }
  return self;
}

@end