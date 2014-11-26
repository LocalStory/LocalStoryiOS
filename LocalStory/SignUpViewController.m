//
//  SignUpViewController.m
//  LocalStory
//
//  Created by Randall Leung on 11/19/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "SignUpViewController.h"
#import "NetworkController.h"
#import "Story.h"
#import "HomeViewController.h"

@interface SignUpViewController () <UITextFieldDelegate>

@property (nonatomic,weak) NetworkController *networkController;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.networkController = [NetworkController sharedNetworkController];
    
    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmPasswordField.delegate = self;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginBackground"]];
    backgroundView.alpha = 0.8;
    [self.contentView insertSubview:backgroundView atIndex:0];
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    self.logo.layer.cornerRadius = 50;
    self.logo.clipsToBounds = YES;

}

#pragma mark Button Actions

- (IBAction)createAccountButton:(id)sender {
    BOOL inputCorrect = [self checkInput];
    if (inputCorrect == YES) {
        [self.networkController postAddNewUser:self.userNameField.text withPassword:self.passwordField.text withConfirmedPassword:self.confirmPasswordField.text];
        HomeViewController *homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self presentViewController:homeVC animated:true completion:nil];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark Form Helpers

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)checkInput {
    if ([self.userNameField.text isEqualToString:@""] && [self.passwordField.text  isEqualToString:@""] && [self.confirmPasswordField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please create a new Username and Password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
        return NO;
    } else if ([self.userNameField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please create a new Username" delegate:self cancelButtonTitle:@"Got IT" otherButtonTitles:nil];
        [message show];
        return NO;
    } else if ([self.passwordField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please create a new password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
        return NO;
    } else if ([self.confirmPasswordField.text isEqualToString:@""]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please confirm your password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
        return NO;
    } else if (![self.confirmPasswordField.text isEqual:self.passwordField.text]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Your passwords do not match" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,-65,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height);
    [UIView commitAnimations];
    
}

@end
