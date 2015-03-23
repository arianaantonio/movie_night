//
//  AddFriendsFromSettingsViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/4/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "AddFriendsFromSettingsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddFriendsFromSettingsViewController ()

@end

@implementation AddFriendsFromSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    friendsArray = [[NSMutableArray alloc]init];
    toAddArray = [[NSMutableArray alloc]init];
    
    //initialize facebook
    [PFFacebookUtils initializeFacebook];
    
    PFUser *currentUser = [PFUser currentUser];
    currentUserId = currentUser.objectId;
    
    //grab selected search type button
    if ([self.searchType isEqualToString:@"contacts"]) {
        [self findContacts];
    } else {
        [self findfacebookFriends];
    }

    
}
#pragma mark - Search By
//find friends via contacts
-(void)findContacts {
    
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
        CFIndex nPeople = CFArrayGetCount(allPeople);
        // CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
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
        NSMutableArray *userToCheckArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < [items count]; i++) {
            NSLog(@"%@",[items objectAtIndex:i]);
            NSLog(@"%@", [[items objectAtIndex:i]objectForKey:@"contactEmail"]);
            if (![[[items objectAtIndex:i]objectForKey:@"contactEmail"]isEqualToString:@""]) {
                [hasEmailsArray addObject:[[items objectAtIndex:i]objectForKey:@"contactEmail"]];
                [userToCheckArray addObject:[items objectAtIndex:i]];
                
            }
        }
        NSLog(@"Array: %@", hasEmailsArray);
        PFQuery *friendsQuery = [PFUser query];
        [friendsQuery whereKey:@"email" containedIn:hasEmailsArray];
        [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                
                for (PFObject *object in objects) {
                    NSLog(@"%@", object.objectId);
                    NSLog(@"You have a friend: %@", [object objectForKey:@"username"]);
                    for (int i = 0; i < [hasEmailsArray count]; i++) {
                        NSLog(@"Email 1 :%@", [[userToCheckArray objectAtIndex:i]objectForKey:@"contactEmail"]);
                        NSLog(@"Email 2: %@", [object objectForKey:@"email"]);
                        if ([[[userToCheckArray objectAtIndex:i]objectForKey:@"contactEmail"]isEqualToString:[object objectForKey:@"email"]]) {
                            
                            NSString *fullName = [NSString stringWithFormat:@"%@ %@", [[userToCheckArray objectAtIndex:i]objectForKey:@"firstName"], [[userToCheckArray objectAtIndex:i]objectForKey:@"lastName"]];
                            NSString *userID = object.objectId;
                            NSDictionary *user = [[NSDictionary alloc]initWithObjectsAndKeys:fullName, @"full_name", userID, @"userID", nil];
                            if (![userID isEqualToString:currentUserId]) {
                                [friendsArray addObject:user];
                            }
                            [_friendsTable reloadData];
                        }
                    }
                    
                }
            }
        }];
        
    } else {
        NSLog(@"Cannot fetch Contacts :( ");
        
    }
}
//find friends via facebook
-(void)findfacebookFriends {
    
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    //get users facebook friends
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        //list of friends
        NSArray *friends = result[@"data"];
        
        //loop through friends
        for (NSDictionary<FBGraphUser>* friend in friends) {
            
            NSLog(@"Found a friend: %@ - %@", friend.name, friend.objectID);
            
            //query Parse for users with same facebook id
            PFQuery *query = [PFUser query];
            [query whereKey:@"fbId" equalTo:friend.objectID];
            NSArray *userArray = [query findObjects];
            if (userArray !=nil) {
                
                //get returned user info
                NSString *full_name = [[userArray firstObject]objectForKey:@"full_name"];
                if (full_name == nil) {
                    full_name = friend.name;
                }
                NSString *userID = [[userArray firstObject]objectId];
                NSDictionary *tmpDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:full_name, @"full_name", userID, @"userID", nil];
                
                //pass it to the tableview array
                [friendsArray addObject:tmpDictionary];
            }
            NSLog(@"Friend array: %@", friendsArray);
            //reload tableview
            [_friendsTable reloadData];
        }
        
    }];
}

#pragma mark - Actions
//user clicked to add a particular contact
-(void)addContacts:(id)sender {
    
    //add that friend to an array and change the button text color
    [toAddArray addObject:[[friendsArray objectAtIndex:[sender tag]]objectForKey:@"userID"]];
    [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    PFObject *newComment = [PFObject objectWithClassName:@"Activity"];
    newComment[@"activityType"] = @"follow";
    newComment[@"fromUser"] = currentUserId;
    newComment[@"toUser"] = [[friendsArray objectAtIndex:[sender tag]]objectForKey:@"userID"];
    [newComment saveInBackground];
}
//clicked done
-(IBAction)clickedDone:(id)sender {
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:currentUserId];
    NSMutableArray *userArray = [[[query findObjects]firstObject]objectForKey:@"friends"];
    
    [toAddArray addObjectsFromArray:userArray];
    
    //add the friends in the array to the users parse account
    [[PFUser currentUser]setObject:toAddArray forKey:@"friends"];
    [[PFUser currentUser]saveInBackground];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friendsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    UILabel *fullName = (UILabel *) [cell viewWithTag:1];
    fullName.text = [[friendsArray objectAtIndex:indexPath.row]objectForKey:@"full_name"];
    UIButton *cellButton = (UIButton *) [cell viewWithTag:2];
    cellButton.tag = indexPath.row;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
