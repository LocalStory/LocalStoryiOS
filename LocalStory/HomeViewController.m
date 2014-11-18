//
//  HomeViewController.m
//  LocalStory
//
//  Created by Jacob Hawken on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "HomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
@interface HomeViewController ()

@property CLLocationManager* locationManager;
@property NSFetchedResultsController* fetchedResultsController;
@property NSManagedObjectContext* managedObjectContext;
@property AppDelegate* appDelegate;

@end

@implementation HomeViewController

#pragma mark - lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
  self.homeMapView.delegate = self;  //I have no idea what it doesn't like about this.
  self.appDelegate = [[UIApplication sharedApplication] delegate];
  [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(storyAdded) name: @"STORY_ADDED" object:nil];
  
  [self statusSwitcher];
  [self.locationManager startUpdatingLocation];
  self.homeMapView.showsUserLocation = true;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - other functions

- (void) fetchStoriesForSpan {
  //TODO: NetworkController call to fetch Stories, based on current map span.
}

- (void) storyAdded {
  //TODO: Add new annotation to map.
}

- (IBAction)addNewStory:(id)sender {
  //TODO: Instantiate the StoryVC with current location data.
}

- (void) statusSwitcher {
  
  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusAuthorizedAlways:
      [self.locationManager startUpdatingLocation];
      [self.homeMapView showsUserLocation];
      self.homeMapView.centerCoordinate = self.homeMapView.userLocation.coordinate;
      break;
    case kCLAuthorizationStatusNotDetermined:
      NSLog(@"Location not determined");
      [self.locationManager requestAlwaysAuthorization];
    case kCLAuthorizationStatusRestricted:
      NSLog(@"Location restricted.");
    case kCLAuthorizationStatusDenied:
      NSLog(@"Location denied.");
    default:
      break;
  }
}

#pragma mark keeping this thing around just to be safe

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
