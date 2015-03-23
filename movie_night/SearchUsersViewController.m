//
//  SearchUsersViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/7/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "SearchUsersViewController.h"
#import <Parse/Parse.h>
#import "FriendProfileViewController.h"

@interface SearchUsersViewController ()

@end

@implementation SearchUsersViewController
@synthesize userData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_searchBar setDelegate:self];
    usersArray = [[NSMutableArray alloc]init];
    toAddArray = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  - Search
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *userSearched = [_searchBar text];
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" equalTo:userSearched];
    
    PFQuery *emailQuery = [PFUser query];
    [emailQuery whereKey:@"email" equalTo:userSearched];
    
    PFQuery *fullNameQuery = [PFUser query];
    [fullNameQuery whereKey:@"full_name" containsString:userSearched];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[usernameQuery,emailQuery,fullNameQuery]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if ([results count] > 0) {
            NSString *username = @"";
            NSString *userID = @"";
            UIImage *profilePic;
            NSString *fullName = @"";
            
            for (int i = 0; i < [results count]; i++) {
                NSLog(@"Results: %@", [results objectAtIndex:i]);
                
                NSDictionary *friendDict = [results objectAtIndex:i];
                username = [[results objectAtIndex:i]objectForKey:@"username"];
                userID = [[results objectAtIndex:i]objectId];
                profilePic = [[results objectAtIndex:i]objectForKey:@"profile_pic"];
                fullName = [[results objectAtIndex:i]objectForKey:@"full_name"];
                profilePic = [UIImage imageWithData:[(PFFile *)friendDict[@"profile_pic"]getData]];
                userData = [[MovieClass alloc]init];
                userData.username = username;
                userData.userID = userID;
                userData.user_photo_file = profilePic;
                userData.user_full_name = fullName;
                
                [usersArray addObject:userData];
                [_userTable reloadData];
            }
        }
    }];
}
#pragma mark - Actions
-(IBAction)addUser:(id)sender {
    //add that friend to an array and change the button text color
    [toAddArray addObject:[[usersArray objectAtIndex:[sender tag]]userID]];
    [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    PFObject *newComment = [PFObject objectWithClassName:@"Activity"];
    newComment[@"activityType"] = @"follow";
    newComment[@"fromUser"] = [PFUser currentUser].objectId;
    newComment[@"toUser"] = [[usersArray objectAtIndex:[sender tag]]userID];
    [newComment saveInBackground];
    
    PFQuery *query = [PFUser query];
    NSString *currentUserId = [PFUser currentUser].objectId;
    [query whereKey:@"objectId" equalTo:currentUserId];
    NSMutableArray *userArray = [[[query findObjects]firstObject]objectForKey:@"friends"];
    
    [toAddArray addObjectsFromArray:userArray];
    
    //add the friends in the array to the users parse account
    [[PFUser currentUser]setObject:toAddArray forKey:@"friends"];
    [[PFUser currentUser]saveInBackground];
}
-(IBAction)clickedDone:(id)sender {
    /*
    PFQuery *query = [PFUser query];
    NSString *currentUserId = [PFUser currentUser].objectId;
    [query whereKey:@"objectId" equalTo:currentUserId];
    NSMutableArray *userArray = [[[query findObjects]firstObject]objectForKey:@"friends"];
    
    [toAddArray addObjectsFromArray:userArray];
    
    //add the friends in the array to the users parse account
    [[PFUser currentUser]setObject:toAddArray forKey:@"friends"];
    [[PFUser currentUser]saveInBackground];*/
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [usersArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    MovieClass *currentUser = [usersArray objectAtIndex:indexPath.row];
    if (cell != nil) {
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:2];
        usernameLabel.text = currentUser.username;
        UILabel *fullNameLabel = (UILabel *) [cell viewWithTag:3];
        fullNameLabel.text = currentUser.user_full_name;
        UIImageView *profilePic = (UIImageView *) [cell viewWithTag:1];
        profilePic.image = currentUser.user_photo_file;
        
        UIButton *cellButton = (UIButton *) [cell viewWithTag:4];
        cellButton.tag = indexPath.row;
        
        return cell;
    }
    return nil;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = (UITableViewCell*)sender;
    NSIndexPath *indexPath = [_userTable indexPathForCell:cell];
    
    MovieClass *currentUser = [usersArray objectAtIndex:indexPath.row];
    FriendProfileViewController *fpvc = [segue destinationViewController];
    fpvc.userIdPassed = currentUser.userID;
    
}


@end
