//
//  HomeViewController.h
//  LocalStory
//
//  Created by Jacob Hawken on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *addStoryButton;
@property (weak, nonatomic) IBOutlet MKMapView *homeMapView;
@property (weak, nonatomic) IBOutlet UIButton *centeringButton;

@end
