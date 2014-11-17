//
//  StoryViewController.h
//  LocalStory
//
//  Created by Randall Leung on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoryViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
