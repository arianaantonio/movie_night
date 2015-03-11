//
//  AddContactsViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/3/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "AddContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Parse/Parse.h>

@interface AddContactsViewController ()

@end

@implementation AddContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFUser *currentUser = [PFUser currentUser];
    currentUserId = currentUser.objectId;
    
    
    contactArray = [[NSMutableArray alloc]init];
    toAddArray = [[NSMutableArray alloc]init];
    
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
                            NSDictionary *user = [[NSDictionary alloc]initWithObjectsAndKeys:fullName, @"fullName", userID, @"userID", nil];
                            if (![userID isEqualToString:currentUserId]) {
                                [contactArray addObject:user];
                            }
                            [_contactsTable reloadData];
                        }
                    }
                    
                }
            }
        }];
        
    } else {
        NSLog(@"Cannot fetch Contacts :( ");
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)addContacts:(id)sender {
    
    [toAddArray addObject:[[contactArray objectAtIndex:[sender tag]]objectForKey:@"userID"]];
    [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    PFObject *newActivity = [PFObject objectWithClassName:@"Activity"];
    newActivity[@"activityType"] = @"follow";
    newActivity[@"fromUser"] = currentUserId;
    newActivity[@"toUser"] = [[contactArray objectAtIndex:[sender tag]]objectForKey:@"userID"];
    [newActivity saveInBackground];
}
-(IBAction)clickedDone:(id)sender {
   
    [[PFUser currentUser]setObject:toAddArray forKey:@"friends"];
    [[PFUser currentUser]saveInBackground];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contactArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    UILabel *fullName = (UILabel *) [cell viewWithTag:1];
    fullName.text = [[contactArray objectAtIndex:indexPath.row]objectForKey:@"fullName"];
    UIButton *cellButton = (UIButton *) [cell viewWithTag:2];
    cellButton.tag = indexPath.row;
    
    return cell;
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
