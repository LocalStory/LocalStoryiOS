//
//  LogInViewController.m
//  LocalStory
//
//  Created by Randall Leung on 11/19/14.
//  Copyright (c) 2014 Jacob Hawken. All rights reserved.
//

#import "LogInViewController.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userNameField.delegate = self;
    self.passwordField.delegate = self;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginBackground"]];
    backgroundView.alpha = 0.5;
    [self.view addSubview:backgroundView];
    //[self.view insertSubview:backgroundView belowSubview:self.view];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)signInButton:(id)sender {
    [self checkInput];
    
}

-(void)checkInput {
    if ([self.userNameField.text isEqualToString:@""] && [self.passwordField.text  isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please create a new Username and Password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
    } else if ([self.userNameField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please create a new Username" delegate:self cancelButtonTitle:@"Got IT" otherButtonTitles:nil];
        [message show];
    } else if ([self.passwordField.text isEqualToString:@""]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Uh-Oh" message:@"Please create a new password" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles:nil];
        [message show];
    }
}

- (IBAction)signUpButton:(id)sender {
    
}


@end
