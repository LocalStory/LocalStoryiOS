//
//  ViewingStoryViewController.m
//  LocalStory
//
//  Created by Randall Leung on 11/18/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "ViewingStoryViewController.h"
#import "NetworkController.h"

@interface ViewingStoryViewController ()

@property (nonatomic,weak) NetworkController *networkController;

@end

@implementation ViewingStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.networkController = [NetworkController sharedNetworkController];
    self.storyTitle.text = self.storyObject.title;
    self.descLabel.text = self.storyObject.story;
    [self downloadImage];
    
    self.lat = [self.storyObject.lat doubleValue];
    self.lon = [self.storyObject.lng doubleValue];
    [self findLocationOnMap];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a - MM/dd/yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:self.storyObject.date];
    
    self.date.text = stringFromDate;
}

#pragma mark - Image Functions

-(void)downloadImage {
    [self.networkController getUIImageForStory:self.storyObject withCompletionHandler:^(UIImage *imageForStory) {
        [self.activityIndicator startAnimating];
        self.imageView.image = imageForStory;
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = true;
    }];
    
}

#pragma mark - Location Functions

-(void)findLocationOnMap {
    CLLocationDegrees latDelta = 0.01;
    CLLocationDegrees lonDelta = 0.01;
    MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
    CLLocationCoordinate2D loc2D = CLLocationCoordinate2DMake(self.lat, self.lon);
    MKCoordinateRegion region = MKCoordinateRegionMake(loc2D, span);
    [[self mapView] setRegion:region];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = loc2D;
    [[self mapView] addAnnotation:annotation];
}

#pragma mark - Action Functions

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
