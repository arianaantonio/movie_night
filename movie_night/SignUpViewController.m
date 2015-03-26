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
@synthesize usernameField, passwordField, password2Field, emailField, fullNameField, errorLabel, scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [password2Field setDelegate:self];
    [self.view endEditing:YES];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self registerForKeyboardNotifications];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//set up textfield so return button puts focus on the next textfield
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    //responder to next responder until reaching the last, then resign
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}
//register keyboard to receive notifications
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
//call when keyboard is shown
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    //scroll view to bottem field so keyboard doesn't hide it
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, password2Field.frame.origin) ) {
        
        [self.scrollView scrollRectToVisible:password2Field.frame animated:YES];
    }
}
//when keyboard is hidden
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    //sroll view down when keyboard is hidden to regular dimensions
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
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
        UIImage *image = [UIImage imageNamed:@"Ninja.png"];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];

        PFUser *user = [PFUser user];
        user.username = [usernameField text];
        user.password = [passwordField text];
        user.email = [emailField text];
        user[@"profile_pic"] = imageFile;
        
        if (![fullName isEqualToString:@""]) {
            user[@"full_name"] = fullName;
        }
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                //Send user to main app
                [self performSegueWithIdentifier:@"addContactsSegue" sender:self];
            } else {
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Error: %@", errorString);
                //if username already in use
                if ([error code] == 202) {
                    [errorLabel setText:@"Username already in use"];
                } else if ([error code] == 203) {
                    [errorLabel setText:@"Email already in use"];
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

@end
