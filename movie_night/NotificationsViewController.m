//
//  NotificationsViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/10/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "NotificationsViewController.h"
#import <Parse/Parse.h>
#import "FriendProfileViewController.h"
#import "FriendReviewViewController.h"

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *currentUser = [PFUser currentUser];
    userId = currentUser.objectId;
    notifArray = [[NSMutableArray alloc]init];
    
    //clear any badge notifications
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];    
}
-(void)viewDidAppear:(BOOL)animated {
    [self getNewActivity];
}
//get all activity for user
-(void)getNewActivity {
    
    [notifArray removeAllObjects];
    
    //get activity to current user
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"toUser" equalTo:userId];
    [activityQuery orderByDescending:@"createdAt"];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        
        NSString *fromUserId = @"";
        NSString *comment = @"";
        NSString *reviewId = @"";
        NSString *activityType = @"";
        NSString *movieTitle = @"";
        NSString *fromUsername = @"";
       // NSString *activityLabel = @"";
        UIImage *userImage;
        
        for (PFObject *activity in activities) {
            activityUser = [[MovieClass alloc]init];
            
            //get user info
            fromUserId = [activity objectForKey:@"fromUser"];
            
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"objectId" equalTo:fromUserId];
            NSArray *userArray = [userQuery findObjects];
            NSDictionary *userDict = [userArray firstObject];
            fromUsername = [userDict objectForKey:@"username"];
            userImage = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"]getData]];
            activityUser.username = fromUsername;
            activityUser.userID = fromUserId;
            activityUser.user_photo_file = userImage;
            
            //check if activity type is follow or comment left
            activityType = [activity objectForKey:@"activityType"];
            
            if ([activityType isEqualToString:@"comment"]) {
                comment = [activity objectForKey:@"comment"];
                reviewId = [activity objectForKey:@"reviewId"];
                movieTitle = [activity objectForKey:@"movieTitle"];
                activityUser.user_review = @"has commented on your review:";
                activityUser.movie_title = movieTitle;
                activityUser.user_review_objectId = reviewId;
                
            } else if ([activityType isEqualToString:@"follow"]) {
                activityUser.user_review = @"has begun following you";
            }
            [notifArray addObject:activityUser];
        }
        [_notifTable reloadData];
    }];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [notifArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityCell"];
    MovieClass *currentActivity = [notifArray objectAtIndex:indexPath.row];
    
    if (cell != nil) {
        
        UIImageView *profile_pic = (UIImageView *) [cell viewWithTag:1];
        profile_pic.image = currentActivity.user_photo_file;
        
        UIButton *usernameButton = (UIButton *) [cell viewWithTag:2];
        usernameButton.tag = indexPath.row;
        [usernameButton setTitle:currentActivity.username forState:UIControlStateNormal];
        
        UILabel *activityLabel = (UILabel *) [cell viewWithTag:3];
        activityLabel.text = currentActivity.user_review;
        
        UIButton *movieButton = (UIButton *) [cell viewWithTag:4];
        movieButton.tag = indexPath.row;
        if (![currentActivity.movie_title isEqualToString:@""]) {
            [movieButton setTitle:currentActivity.movie_title forState:UIControlStateNormal];
            [movieButton setHidden:NO];
        } else {
            [movieButton setHidden:YES];
        }
        
        return cell;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UITableViewCell *cell = (UITableViewCell*)sender;
    MovieClass *selectedCell = [notifArray objectAtIndex:[cell tag]];
    
    if ([[segue identifier]isEqualToString:@"userProfile"]) {
        FriendProfileViewController *fpvc = [segue destinationViewController];
        fpvc.userIdPassed = selectedCell.userID;
    } else {
        FriendReviewViewController *frvc = [segue destinationViewController];
        frvc.selectedReview = selectedCell;
    }
}


@end
