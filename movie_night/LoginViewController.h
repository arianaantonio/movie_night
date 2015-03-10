//
//  LoginViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendFeedViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>


@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UIView *forgotPasswordView;
@property (nonatomic, strong) IBOutlet UITextField *emailField;

-(IBAction)loginWithFacebook:(id)sender;
-(IBAction)loginWithUsername:(id)sender;
-(IBAction)forgotPassword:(id)sender;
-(IBAction)resetPassword:(id)sender;

@end
