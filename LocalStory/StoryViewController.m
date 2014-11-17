//
//  StoryViewController.m
//  LocalStory
//
//  Created by Randall Leung on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "StoryViewController.h"

@interface StoryViewController ()

@property (nonatomic,strong) UIImagePickerController *imagePicker;

@end

@implementation StoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"StoryViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = true;
    self.imagePicker.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:imageTap];

}

-(void)imageTapped:(UITapGestureRecognizer *)sender {
    NSLog(@"IMAGE TAPPED");
    [self openAlertController];
}

-(void)openAlertController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Add a Photo" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[[UIDevice currentDevice] model] isEqual: @"iPhone Simulator"]) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:self.imagePicker animated:true completion:nil];
    }];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:true completion:nil];
    }];
    
    [alertController addAction:cameraAction];
    [alertController addAction:photoLibraryAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:true completion:nil];
}





@end
