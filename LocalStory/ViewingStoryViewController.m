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
}

-(void)downloadImage {
    [self.networkController getUIImageForStory:self.storyObject withCompletionHandler:^(UIImage *imageForStory) {
        self.imageView.image = imageForStory;
    }];
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}



@end
