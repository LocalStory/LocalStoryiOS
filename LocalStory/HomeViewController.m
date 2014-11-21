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
#import "StoryPin.h"
#import "ViewingStoryViewController.h"

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
@property (weak, nonatomic) IBOutlet UILabel *howToAddStoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *signInToAddStoriesLabel;
@property (nonatomic, strong) NSTimer* refreshTimer;

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
  
  UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action: @selector(didLongPressOnMap)];
  [self.homeMapView addGestureRecognizer: longPress];
  
  self.appDelegate = [[UIApplication sharedApplication] delegate];

  [self.locationManager requestWhenInUseAuthorization];
  [self statusSwitcher];
  [self.locationManager startUpdatingLocation];
  self.homeMapView.showsUserLocation = true;
  
  self.refreshTimer = [[NSTimer alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
  if (self.isFirstLaunch == NO) {
    [self fetchStoriesForCurrentRegion];
  }
}

#pragma mark - location manager delegate methods

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
    UIButton* viewStoryButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = viewStoryButton;
    
    return annotationView;
  }
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
  for (MKPinAnnotationView* annotationView in views) {
    StoryPin* thisView = annotationView.annotation;
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
    self.howToAddStoryLabel.alpha = 0;
    self.howToAddStoryLabel.hidden = false;
    [UIView animateWithDuration: 1 animations:^{
      self.howToAddStoryLabel.alpha = 1;
    }];
    [self fetchStoriesForCurrentRegion];
    self.isFirstLaunch = NO;
  }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  ViewingStoryViewController* storyDetailVC = [[ViewingStoryViewController alloc] initWithNibName:@"ViewingStoryViewController" bundle:nil];
  StoryPin* myPin = (StoryPin*)view.annotation;
  storyDetailVC.storyObject = myPin.story;
  [self presentViewController: storyDetailVC animated:true completion:nil];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  [self.refreshTimer invalidate];
  self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval: 1.5
                                   target: self
                                 selector: @selector(fetchStoriesForCurrentRegion)
                                 userInfo: nil
                                  repeats: NO];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  MKCircleRenderer* renderer = [[MKCircleRenderer alloc] initWithOverlay: overlay];
  renderer.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.15];
  renderer.strokeColor = [UIColor redColor];
  renderer.lineWidth = 1.0;
  
  return renderer;
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

- (void) fetchStoriesForCurrentRegion {
  self.refreshTimer = nil;
  SearchArea* searchArea = [[SearchArea alloc] init: self.homeMapView.region];
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  [self.networkController getStoriesInView:searchArea completionHandler:^(NSArray *stories) {
    if ([[stories firstObject]  isEqual: @"tooMany"]) {
      [self.stories removeAllObjects];
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    else {
      NSMutableArray* tempArray = [[NSMutableArray alloc] initWithArray:stories];
      [self.stories removeAllObjects];
      self.stories = tempArray;
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
  }];
  [self addStoryAnnotationsToMapForDate: [NSDate date] andOnlyLoadStoriesAfterDate: false];
}

- (void) fetchStoriesSinceLastLoaded {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  NSDate* date = [self findLatestStoryDate];
  
  //TODO: Work with JS guys and Nate to get this implemented. THIS IS A STRETCH GOAL. NOT NECESSARY FOR MVP.
  //Remember to turn off network activity indicator.
  
  [self addStoryAnnotationsToMapForDate: date andOnlyLoadStoriesAfterDate: true];
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

- (void) addStoryAnnotationsToMapForDate: (NSDate*) date andOnlyLoadStoriesAfterDate: (BOOL) isRestricted {
  NSMutableArray* storiesForAnnotations = [[NSMutableArray alloc] init];
  [self.homeMapView removeOverlays:self.homeMapView.overlays];
  if (isRestricted) {
    for (Story* story in self.stories) {
      if (![story.date laterDate:date]) {
        [storiesForAnnotations addObject:story];
      }
    }
  }
  else {
    [self removeAllPinsButUserLocation];
    storiesForAnnotations = self.stories;
  }
  
  if (self.stories.count == 0) {
    MKCircle* tooManyStories = [MKCircle circleWithCenterCoordinate:self.homeMapView.centerCoordinate radius:self.homeMapView.region.span.longitudeDelta];
    tooManyStories.title = @"Too many stories to view. Zoom in to view individual stories.";
    [self.homeMapView addOverlay: tooManyStories];
  }
  else {
    for (Story* story in storiesForAnnotations) {
      StoryPin* newPin = [[StoryPin alloc] init];
      double latVal = story.latVal;
      double lngVal = story.lngVal;
      CLLocationCoordinate2D pinCoordinate = CLLocationCoordinate2DMake(latVal, lngVal);
      newPin.coordinate = pinCoordinate;
      newPin.title = [NSString stringWithFormat:@"%@", story.title];
      newPin.story = story;
      [self.homeMapView addAnnotation: newPin];
    }
  }
}

- (void) removeAllPinsButUserLocation
{
  id userLocation = [self.homeMapView userLocation];
  NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.homeMapView annotations]];
  if ( userLocation != nil ) {
    [pins removeObject:userLocation]; // avoid removing user location off the map
  }
  
  [self.homeMapView removeAnnotations:pins];
  pins = nil;
}

- (void) didLongPressOnMap {
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"jwt"]) {
    StoryViewController *storyVC = [[StoryViewController alloc] initWithNibName:@"StoryViewController" bundle:nil];
    storyVC.lat = self.lat;
    storyVC.lon = self.lon;
    [self presentViewController:storyVC animated:true completion:nil];
    self.howToAddStoryLabel.hidden = true;
  }
  else {
    //Flashes the promt to sign in if the user wants to add a story.
    self.signInToAddStoriesLabel.alpha = 0;
    self.signInToAddStoriesLabel.hidden = NO;
    [UIView animateWithDuration: 0.5 animations:^{
      self.signInToAddStoriesLabel.alpha = 1;
    }];
    [NSThread sleepForTimeInterval:2];
    [UIView animateWithDuration: 0.5 animations:^{
      self.signInToAddStoriesLabel.alpha = 0;
    }];
  }
}

#pragma mark - IBActions

- (IBAction)centeringButtonPressed:(id)sender {
  [self.homeMapView setCenterCoordinate: self.homeMapView.userLocation.coordinate animated:true];
}

- (IBAction)refreshStoriesButtonPressed:(id)sender {
  [self fetchStoriesForCurrentRegion];
}

#pragma mark - keeping this thing around just to be safe

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
