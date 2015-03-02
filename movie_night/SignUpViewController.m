//
//  SignUpViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController
@synthesize usernameField, passwordField, password2Field, emailField, fullNameField, errorLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//clicked sign up
-(IBAction)signUpClicked:(id)sender {
    
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];
    NSString *passwordConfirm = [password2Field text];
    NSString *email = [emailField text];
    NSString *fullName = [fullNameField text];
    [errorLabel setText:@""];
    
    //check if username empty
    if ([username isEqualToString:@""]) {
        [self.usernameField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [errorLabel setText:@"Please Enter a Username"];
    }
    //check if password empty
    else if ([password isEqualToString:@""]){
        [self.passwordField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [errorLabel setText:@"Please Enter Your Password"];
    }
    //check if password empty
    else if ([passwordConfirm isEqualToString:@""]) {
        [self.password2Field setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [errorLabel setText:@"Please Confirm Your Password"];
    }
    //check if email is empty or invalid
    else if ([email isEqualToString:@""] || ![self validateEmail:email]) {
        [self.emailField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [errorLabel setText:@"Please Enter A Valid Email Address"];
    }
    //check if password and password confirm match
    else if (![password isEqualToString:passwordConfirm]) {
        [errorLabel setText:@"Passwords Did Not Match"];
    }
    //sign up user
    else {
        PFUser *user = [PFUser user];
        user.username = [usernameField text];
        user.password = [passwordField text];
        user.email = [emailField text];
        
        if (![fullName isEqualToString:@""]) {
            user[@"full_name"] = fullName;
        }
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //Send user to main app
                [self performSegueWithIdentifier:@"signUpSegue" sender:self];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Error: %@", errorString);
                //if username already in use
                if ([error code] == 202) {
                    [errorLabel setText:@"Username already in use"];
                }
            }
        }];
    }
}
//validate email entered
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
