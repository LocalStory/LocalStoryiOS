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
      NSLog(@"midLat > 0 : %f", midLat);

      NSLog(@"Value 1: %f", regionFor.center.latitude);
      NSLog(@"Value 2: %f", midLat);

      NSLog(@"halfLat = %f", halfLat);

      latMaxVal = [NSNumber numberWithDouble:(midLat + halfLat)];
      latMinVal = [NSNumber numberWithDouble:(midLat - halfLat)];

      if (latMinVal < latMaxVal) {
        NSLog(@"VALID VALUE CHECK: %@ < %@", latMinVal, latMaxVal);
      } else {
        NSLog(@"WARNING ------------------------ INVALID LATITUDE AREA");
        NSLog(@"--------- CHECK: %@ !< %@", latMinVal, latMaxVal);

      }

    } else {
      NSLog(@"midLat < 0 : %f", midLat);

      latMaxVal = [NSNumber numberWithDouble:(midLat - halfLat)];
      latMinVal = [NSNumber numberWithDouble:(midLat + halfLat)];

      if (latMinVal < latMaxVal) {
        NSLog(@"VALID VALUE CHECK: %@ < %@", latMinVal, latMaxVal);
      } else {
        NSLog(@"WARNING ------------------------ INVALID LATITUDE AREA");
        NSLog(@"--------- CHECK: %@ !< %@", latMinVal, latMaxVal);

      }

    }

    if (midLng < 0) {
            NSLog(@"midLng < 0 : %f", midLng);


      lngMaxVal = [NSNumber numberWithDouble:(midLng + halfLng)];
      lngMinVal = [NSNumber numberWithDouble:(midLng - halfLng)];

      if (lngMinVal < lngMaxVal) {
        NSLog(@"VALID VALUE CHECK: %@ < %@", lngMinVal, lngMaxVal);
      } else {
        NSLog(@"WARNING ------------------------ INVALID LONGITUDE AREA");
        NSLog(@"--------- CHECK: %@ !< %@", lngMinVal, lngMaxVal);

      }


    } else {
      NSLog(@"midLng > 0 : %f", midLng);


      lngMaxVal = [NSNumber numberWithDouble:(midLng - halfLng)];
      lngMinVal = [NSNumber numberWithDouble:(regionCenter.longitude + halfLng)];

      if (lngMinVal < lngMaxVal) {
        NSLog(@"VALID VALUE CHECK: %@ < %@", lngMinVal, lngMaxVal);
      } else {
        NSLog(@"WARNING ------------------------ INVALID LATITUDE AREA");
        NSLog(@"--------- CHECK: %@ !< %@", lngMinVal, lngMaxVal);

      }

    }
    self.latMax = [latMaxVal stringValue]; // @"50.0";
    self.latMin = [latMinVal stringValue]; // @"30.0";
    self.lngMax = [lngMaxVal stringValue]; // @"0.0";
    self.lngMin = [lngMinVal stringValue]; // @"-140.0";
  }
  return self;
}

@end