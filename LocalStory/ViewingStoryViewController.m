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
    
    //CALL NETWORK TO POPULATE THE INFORMATION
    self.networkController = [NetworkController sharedNetworkController];
    

    [self populateInfo];
    
}

-(void)populateInfo {
//    self.title =
//    self.descLabel.text =
//    self.imageView.image =
}


@end
