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
#import "StoryViewController.h"

@interface HomeViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property CLLocationManager* locationManager;
@property NSFetchedResultsController* fetchedResultsController;
@property NSManagedObjectContext* managedObjectContext;
@property AppDelegate* appDelegate;
@property CLLocationDegrees lat;
@property CLLocationDegrees lon;

@end

@implementation HomeViewController

#pragma mark - lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.homeMapView.delegate = self;
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(storyAdded) name: @"STORY_ADDED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createStory) name:@"CREATE_STORY" object:nil];

    [self.locationManager requestWhenInUseAuthorization];
    [self statusSwitcher];
    [self.locationManager startUpdatingLocation];
    self.homeMapView.showsUserLocation = true;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.lastObject != nil) {
        CLLocation *newLoc = locations.lastObject;
        self.lat = newLoc.coordinate.latitude;
        self.lon = newLoc.coordinate.longitude;
    }
}

#pragma mark - other functions

- (void) fetchStoriesForSpan {
  //TODO: NetworkController call to fetch Stories, based on current map span.
}

- (void) storyAdded {
  //TODO: Add new annotation to map.
}

-(void)createStory {
    
}

- (IBAction)addNewStory:(id)sender {
  StoryViewController *storyVC = [[StoryViewController alloc] initWithNibName:@"StoryViewController" bundle:nil];
  storyVC.lat = self.lat;
  storyVC.lon = self.lon;
  [self presentViewController:storyVC animated:true completion:nil];
}

- (void) statusSwitcher {
  switch ([CLLocationManager authorizationStatus]) {
    case kCLAuthorizationStatusAuthorizedAlways:
          NSLog(@"Authorized");
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
