//
//  LoginViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FriendFeedViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize usernameField, passwordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //initialize facebook with Parse
    [PFFacebookUtils initializeFacebook];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
//login with Facebook
-(void)loginWithFacebook:(id)sender {
    //set permissions for facebook account
    NSArray *permissionsArray = @[ @"public_profile", @"user_friends", @"email"];
    
    //login user using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            //user cancelled facebook login
            if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
                errorMessage = @"The user cancelled the Facebook login.";
            } else {
                NSLog(@"An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error on Log in"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            //user logged in
            if (user.isNew) {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"Please choose a username" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alert show];
                
                NSLog(@"user signed up and logged in w/Facebook");
            } else {
                NSLog(@"user logged in w/Facebook");
       
                [self performSegueWithIdentifier:@"tabSegue" sender:self];
            }
            
            //getting profile pic and upload file to parse
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" equalTo:user.objectId];
            NSArray *userReturned = [query findObjects];
            NSLog(@"User: %@", [userReturned firstObject]);
            NSDictionary *userDict = [userReturned firstObject];
            NSString *facebookID = [userDict objectForKey:@"fbId"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];
            
            //get image from facebook
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:
             ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                 if (connectionError == nil && data != nil) {
                     //set profile pic
                
                     //save image to parse as PFFile
                     UIImage *image = [UIImage imageWithData:data];
                     NSData *imageData = UIImagePNGRepresentation(image);
                     PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];
                     [[PFUser currentUser]setObject:imageFile forKey:@"profile_pic"];
                     [[PFUser currentUser]saveInBackground];
                     
                 }
             }];
        }
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Entered: %@",[[alertView textFieldAtIndex:0] text]);
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[[alertView textFieldAtIndex:0] text]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number > 0) {
            NSLog(@"Username exists");
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username already exists. Please choose a new one." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Submit", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        } else {
            //segue to tabViewController
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                    // Store the Facebook Id
                    [[PFUser currentUser]setObject:me.objectID forKey:@"fbId"];
                    [[PFUser currentUser]setObject:me.name forKey:@"full_name"];
                    [[PFUser currentUser]setObject:[me objectForKey:@"email"] forKey:@"email"];
                    [[PFUser currentUser]setObject:[[alertView textFieldAtIndex:0]text] forKey:@"username"];
                    [[PFUser currentUser] saveInBackground];
                    [self performSegueWithIdentifier:@"tabSegue" sender:self];
                }
            }];
        }
    }];
}
//login with username and password
-(IBAction)loginWithUsername:(id)sender {
    
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];
    
    //if user hasn't entered a username
    if ([[usernameField text]isEqualToString:@""]) {
        [self.usernameField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [usernameField setPlaceholder:@"Please Enter a Username"];
        
    //if user hasn't entered a password
    } else if ([[passwordField text]isEqualToString:@""]) {
        [self.passwordField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        [passwordField setPlaceholder:@"Please Enter a Password"];
        
    //log user in
    } else {
        [PFUser logInWithUsernameInBackground:username password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                // Do stuff after successful login.
                                                NSLog(@"Logged in");
                                                [self performSegueWithIdentifier:@"tabSegue" sender:self];
                                            } else {
                                                // The login failed. Check error to see why.
                                                NSLog(@"Not logged in");
                                            }
                                        }];

    }
    
}
/*
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}*/
@end
