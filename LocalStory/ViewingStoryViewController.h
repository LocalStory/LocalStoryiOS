//
//  ViewingStoryViewController.h
//  LocalStory
//
//  Created by Randall Leung on 11/18/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"

@interface ViewingStoryViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;

@property (strong,nonatomic) Story *storyObject;

-(void)downloadImageForStory:(NSString *)url completionHandler:(void(^)(UIImage *image))completionHandler;

@end
