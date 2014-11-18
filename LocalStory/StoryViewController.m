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


- (void)viewWillAppear:(BOOL)animated {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.allowsEditing = true;
    self.imagePicker.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frameRect = self.descTextView.frame;
    frameRect.size.height = 53;
    self.descTextView.frame = frameRect;

    self.titleField.delegate = self;
    self.descTextView.delegate = self;
    
    self.descTextView.text = @"Description";
    self.descTextView.textColor = [UIColor lightGrayColor];
    
    self.imageView.userInteractionEnabled = true;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.imageView addGestureRecognizer:imageTap];
    
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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

#pragma mark - Keyboard Interations

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-70,self.view.frame.size.width,self.view.frame.size.height);
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
    self.view.frame = CGRectMake(0,-70,self.view.frame.size.width,self.view.frame.size.height);
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

- (IBAction)done:(id)sender {
    //Send to Sever
    NSLog(@"Done");
    NSLog(@"%@", self.titleField.text);
    NSLog(@"%@", self.descTextView.text);
    NSLog(@"%f", self.lat);
    NSLog(@"%f", self.lon);
}




@end
