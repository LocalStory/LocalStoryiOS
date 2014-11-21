//
//  ViewingStoryViewController.h
//  LocalStory
//
//  Created by Randall Leung on 11/18/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"
#import <MapKit/MapKit.h>

@interface ViewingStoryViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *storyTitle;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *date;


@property CLLocationDegrees lat;
@property CLLocationDegrees lon;
@property (strong,nonatomic) Story *storyObject;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end
