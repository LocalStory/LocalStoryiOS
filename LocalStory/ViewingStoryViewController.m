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
//    check if image exists, then downloadimage
//    self.imageView.image = storyImage;
}

-(void)downloadImageForStory:(NSString *)url completionHandler:(void(^)(UIImage *image))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *contentsOfURL = [[NSURL alloc] initWithString:url];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:contentsOfURL];
        UIImage *storyImage = [[UIImage alloc] initWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(storyImage);
        });
    });
    
}


@end
