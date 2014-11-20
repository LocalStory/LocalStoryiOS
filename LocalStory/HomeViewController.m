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
#import "NetworkController.h"
#import "SearchArea.h"

@interface HomeViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) AppDelegate* appDelegate;
@property (nonatomic) CLLocationDegrees lat;
@property (nonatomic) CLLocationDegrees lon;
@property (nonatomic, strong) NSOperationQueue* operationQueue;
@property (nonatomic) BOOL isFirstLaunch;
@property (nonatomic, weak) NetworkController* networkController;
@property (nonatomic, strong) NSMutableArray* stories;

@end

@implementation HomeViewController

#pragma mark - lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.homeMapView.delegate = self;
  self.networkController = [NetworkController sharedNetworkController];
  self.isFirstLaunch = YES;
  
  self.appDelegate = [[UIApplication sharedApplication] delegate];

  [self.locationManager requestWhenInUseAuthorization];
  [self statusSwitcher];
  [self.locationManager startUpdatingLocation];
  self.homeMapView.showsUserLocation = true;
  [self fetchStoriesForRegion];
}

- (void)viewWillAppear:(BOOL)animated {
  [self fetchStoriesSinceLastLoaded];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.lastObject != nil) {
        CLLocation *newLoc = locations.lastObject;
        self.lat = newLoc.coordinate.latitude;
        self.lon = newLoc.coordinate.longitude;
    }
}

#pragma mark - mapview delegate methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKUserLocation class]]) {
    return nil;
  }
  else {
    MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"STORY"];
    annotationView.animatesDrop = true;
    annotationView.canShowCallout = true;
    //Customize annotation.
    
    return annotationView;
  }
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
  for (MKPinAnnotationView* annotationView in views) {
    MKPointAnnotation* thisView = annotationView.annotation;
    if ([thisView isKindOfClass:[MKUserLocation class]]) {
      [self.operationQueue addOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.4];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
          [mapView selectAnnotation:thisView animated:true];
        }];
      }];
    }  
  }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  if (self.isFirstLaunch) {
    CLLocationDegrees startLat = self.homeMapView.region.span.latitudeDelta / 3000;
    CLLocationDegrees startLong = self.homeMapView.region.span.longitudeDelta / 3000;
    MKCoordinateSpan startSpan = MKCoordinateSpanMake(startLat, startLong);
    MKCoordinateRegion startRegion = MKCoordinateRegionMake(self.homeMapView.userLocation.coordinate, startSpan);
    [self.homeMapView setRegion: startRegion animated:true];
    
    self.isFirstLaunch = NO;
  }
}

#pragma mark - other functions

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

- (void) fetchStoriesForRegion {
  SearchArea* searchArea = [[SearchArea alloc] init: self.homeMapView.region];
  [self.networkController getStoriesInView:searchArea completionHandler:^(NSArray *stories) {
    NSMutableArray* tempArray = [[NSMutableArray alloc] initWithArray:stories];
    self.stories = tempArray;
  }];
}

- (void) fetchStoriesSinceLastLoaded {
  NSDate* date = [self findLatestStoryDate];
  //TODO: Talk to JS guys about this.
}

- (IBAction)addNewStory:(id)sender {
  StoryViewController *storyVC = [[StoryViewController alloc] initWithNibName:@"StoryViewController" bundle:nil];
  storyVC.lat = self.lat;
  storyVC.lon = self.lon;
  [self presentViewController:storyVC animated:true completion:nil];
}

- (IBAction)centerOnUser:(id)sender {
  [self.homeMapView setCenterCoordinate:self.homeMapView.userLocation.coordinate animated:true];
}

#pragma mark keeping this thing around just to be safe

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSDate *)findLatestStoryDate {
  Story *tempStory = [[Story alloc] init];
  
  for (Story *placeholder in self.stories) {
    if (![tempStory.date laterDate:placeholder.date]) {
      tempStory = placeholder;
    }
  }
  return tempStory.date;
}




@end
