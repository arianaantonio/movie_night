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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize usernameField, passwordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [passwordField setDelegate:self];
    
    /*
    CFErrorRef *error = nil;
    
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    
    
    if (accessGranted) {
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:nPeople];
        
        
        for (int i = 0; i < nPeople; i++) {
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            NSString *firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString * lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!firstNames) {
                firstNames = @"";
            }
            if (!lastNames) {
                lastNames = @"";
            }
            
            //get Contact email
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSString *contactEmail = @"";
            NSDictionary *contacts;
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                contactEmail = (__bridge NSString *)contactEmailRef;
                //[contactEmails addObject:contactEmail];
                contacts = [[NSDictionary alloc]initWithObjectsAndKeys: firstNames, @"firstName", lastNames, @"lastName", contactEmail, @"contactEmail", nil];
                
                [items addObject:contacts];
            }
            NSLog(@"Person is: %@", firstNames);
            NSLog(@"Email is:%@", contactEmails);
            
        }
        NSMutableArray *hasEmailsArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < [items count]; i++) {
            NSLog(@"%@",[items objectAtIndex:i]);
            NSLog(@"%@", [[items objectAtIndex:i]objectForKey:@"contactEmail"]);
            if (![[[items objectAtIndex:i]objectForKey:@"contactEmail"]isEqualToString:@""]) {
                [hasEmailsArray addObject:[[items objectAtIndex:i]objectForKey:@"contactEmail"]];
            }
        }
        NSLog(@"Array: %@", hasEmailsArray);
        PFQuery *friendsQuery = [PFUser query];
        [friendsQuery whereKey:@"email" containedIn:hasEmailsArray];
        [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                NSString *movieTitle = @"";
                NSString *rating = @"";
                
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                    NSLog(@"You have a friend: %@", [object objectForKey:@"username"]);

                }
            }
        }];

        
        
        
    } else {
        NSLog(@"Cannot fetch Contacts :( ");
        
    }*/
    
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
    return NO;
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
                [self performSegueWithIdentifier:@"tabSegue" sender:self];
            }
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
                    
                    PFUser *user = [PFUser currentUser];
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
