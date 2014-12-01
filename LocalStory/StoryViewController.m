//
//  StoryViewController.m
//  LocalStory
//
//  Created by Randall Leung on 11/17/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved..
//

#import "StoryViewController.h"
#import "NetworkController.h"
#import "Story.h"

@interface StoryViewController ()

@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic,weak) NetworkController *networkController;

@end

@implementation StoryViewController
@synthesize coordinate;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = true;
    self.imagePicker.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.networkController = [NetworkController sharedNetworkController];
    
    CGRect frameRect = self.descTextView.frame;
    frameRect.size.height = 53;
    self.descTextView.frame = frameRect;

    self.titleField.delegate = self;
    self.descTextView.delegate = self;
    
    self.descTextView.text = @"Description";
    self.descTextView.textColor = [UIColor lightGrayColor];
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouched:)];
    [self.imageView addGestureRecognizer:imageTap];
    
    self.cameraImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraTouched:)];
    [self.cameraImage addGestureRecognizer:tgr];
    
    [self findLocationOnMap];
    [self reverseGeoCode];
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

-(void)reverseGeoCode {
    //Maybe do some geoCoding?
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.lat longitude:self.lon];
    
    CLGeocoder *geoCode = [[CLGeocoder alloc] init];
    [geoCode reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark * p = [[CLPlacemark alloc] initWithPlacemark:placemarks[0]];
            NSLog(@"%@", p);
            self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", p.subAdministrativeArea, p.subLocality];
        }
    }];
}

#pragma mark - Action Functions

-(void)imageTouched:(UITapGestureRecognizer *)tapGestureRecongizer {
    NSLog(@"IMAGE TAPPED");
    [self openAlertController];
}

-(void)cameraTouched:(UITapGestureRecognizer *)tapGestureRecongizer {
    NSLog(@"CAMERA TAPPED");
    [self openAlertController];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
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
    
    [self.imageView setClipsToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = info[UIImagePickerControllerEditedImage];
    if (self.imageView.image == info[UIImagePickerControllerEditedImage]) {
        self.mapView.hidden = true;
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)done:(id)sender {
    NSLog(@"Done");
    NSLog(@"TITLE: %@", self.titleField.text);
    NSLog(@"DESCRIPTION: %@", self.descTextView.text);
    NSLog(@"LAT: %f", self.lat);
    NSLog(@"LONG: %f", self.lon);
    
    //NEED USERID
    
    [self generateThumbnail];
    
    NSDictionary *newStoryDict = @{
                                   @"storyBody": self.descTextView.text,
                                   @"title": self.titleField.text,
                                   @"lat": [[NSNumber alloc] initWithDouble:self.lat],
                                   @"lng": [[NSNumber alloc] initWithDouble:self.lon]
                                   };
    
    Story *newStory = [[Story alloc] init:newStoryDict];
    [self.networkController postNewStoryToForm:newStory withImage:self.imageView.image];
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Keyboard Interations

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-130,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [self.titleField.text length] + [string length] - range.length;
    return (newLength >= 30) ? NO : YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-130,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    
    if ([self.descTextView.text isEqualToString:@"Description"]) {
        self.descTextView.text = @"";
        self.descTextView.textColor = [UIColor blackColor];
    }
    [self.descTextView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *characterCount = [NSString stringWithFormat:@"%lu", (unsigned long)self.descTextView.text.length];
    
    self.characterLabel.text = [NSString stringWithFormat:@"%@ /140",characterCount];
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return textView.text.length + (text.length - range.length) <= 140;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    
    if ([self.descTextView.text isEqualToString:@""]) {
        self.descTextView.text = @"Description";
        self.descTextView.textColor = [UIColor lightGrayColor];
    }
    [self.descTextView resignFirstResponder];
}

-(void)generateThumbnail {
    NSData *imgData = UIImageJPEGRepresentation(self.imageView.image, 0);
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[imgData length]);
    
    CGSize destinationSize = CGSizeMake(500, 500);
    UIGraphicsBeginImageContext(destinationSize);
    [self.imageView.image drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *newImgData = UIImageJPEGRepresentation(self.imageView.image, 0);
    NSLog(@"Size of Image(bytes):%lu",(unsigned long)[newImgData length]);
}

@end
