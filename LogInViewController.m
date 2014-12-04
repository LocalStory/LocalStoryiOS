//
//  LogInViewController.m
//  LocalStory
//
//  Created by Randall Leung on 11/19/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "LogInViewController.h"
#import "HomeViewController.h"
#import "SignUpViewController.h"
#import "NetworkController.h"

@interface LogInViewController ()

@property (nonatomic,weak) NetworkController *networkController;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.networkController = [NetworkController sharedNetworkController];

    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginBackground"]];
    backgroundView.alpha = 0.8;
    [self.view insertSubview:backgroundView atIndex:0];
}

#pragma mark Action Methods

- (IBAction)signInButton:(id)sender {
    BOOL inputCorrect = [self checkInput];
    if (inputCorrect == YES) {
        HomeViewController *homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        [self presentViewController:homeVC animated:true completion:^{
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Welcome! Discover Stories around you." message:nil delegate:self cancelButtonTitle:@"Got It!" otherButtonTitles:nil];
            [message show];
        }];
    }
}

- (IBAction)signUpButton:(id)sender {
    SignUpViewController *loginVC = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
    [self presentViewController:loginVC animated:true completion:nil];
}

- (IBAction)justBrowseButton:(id)sender {
    HomeViewController *homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    [self presentViewController:homeVC animated:true completion:^{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Just Browsing ..." message:@"Be sure to sign up to post your stories!" delegate:self cancelButtonTitle:@"Got It!" otherButtonTitles:nil];
        [message show];
    }];
}

#pragma mark Form Helpers

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)checkInput {
    if ([self.userNameField.text isEqualToString:@""] && [self.passwordField.text  isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please enter your username and password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
        return NO;
    } else if ([self.userNameField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please enter you username" delegate:self cancelButtonTitle:@"Got IT" otherButtonTitles:nil];
        [message show];
        return NO;
    } else if ([self.passwordField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please enter your password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
        return NO;
    }
    return YES;
}






@end
