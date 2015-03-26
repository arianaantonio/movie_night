//
//  FriendProfileViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/6/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "MovieClass.h"
#import <Parse/Parse.h>
#import "FollowersTableViewController.h"
#import "MovieDetailViewController.h"

@interface FriendProfileViewController ()

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    movieArray = [[NSMutableArray alloc]init];
    wantToSeeArray = [[NSMutableArray alloc]init];
    favoritesArray = [[NSMutableArray alloc]init];
    friendsArray = [[NSMutableArray alloc]init];
    currentFriendsArray = [[NSMutableArray alloc]init];
    
    [self loadUserInfo];
}
-(void)loadUserInfo {
    PFUser *currentUser = [PFUser currentUser];
    userId = currentUser.objectId;
    
    //check if current user is following selected user
    PFQuery *currentUserQuery = [PFUser query];
    [currentUserQuery whereKey:@"objectId" equalTo:userId];
    NSArray *returnedArray = [currentUserQuery findObjects];
    NSDictionary *userInfo = [returnedArray firstObject];
    currentFriendsArray = [userInfo objectForKey:@"friends"];

    //set button title based on whether user has the option to follow or unfollow user
    if ([currentFriendsArray containsObject:self.userIdPassed]) {
        [_followUserButton setTitle:@"Unfollow" forState:UIControlStateNormal];
    } else {
        [_followUserButton setTitle:@"Follow" forState:UIControlStateNormal];
        
    }
    
    //get user selected data
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:self.userIdPassed];
    NSArray *userArray = [query findObjects];
    NSLog(@"User: %@", [userArray firstObject]);
    NSDictionary *userDict = [userArray firstObject];
    NSString *username = [userDict objectForKey:@"username"];
    NSString *fullName = [userDict objectForKey:@"full_name"];
    friendsArray = [[NSArray alloc]initWithArray:[userDict objectForKey:@"friends"]];
    [_followingButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[friendsArray count]] forState:UIControlStateNormal];
    UIImage *image = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"] getData]];
    
    //set profile pic
    if (image == nil) {
        _profilePicView.image = [UIImage imageNamed:@"Ninja.png"];
    } else {
        _profilePicView.image = image;
    }
    
    //set uielements
    [_nameLabel setText:fullName];
    self.navBar.title = @"Profile";
    [_usernameLabel setText:username];
    
    //get count of followers
    PFQuery *followersQuery = [PFUser query];
    [followersQuery whereKey:@"friends" equalTo:self.userIdPassed];
    NSArray *followersFoundArray = [followersQuery findObjects];
    NSLog(@"Followers: %@", followersFoundArray);
    [_followersButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[followersFoundArray count]] forState:UIControlStateNormal];
    
    //pull reviews for user
    PFQuery *query2 = [PFQuery queryWithClassName:@"Reviews"];
    [query2 whereKey:@"userID" equalTo:self.userIdPassed];
    [query2 orderByDescending:@"createdAt"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            NSString *movieTitle = @"";
            NSString *rating = @"";
            NSNumber *isFave;
            UIImage *moviePoster;
            NSString *movieID = @"";
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                
                //get object data returned
                rating = [object objectForKey:@"rating"];
                moviePoster = [UIImage imageWithData:[(PFFile *)object[@"moviePoster"]getData]];
                movieTitle = [object objectForKey:@"movieTitle"];
                isFave = [object objectForKey:@"isFavorite"];
                movieID = [object objectForKey:@"movieID"];
                MovieClass *tmpMovie = [[MovieClass alloc]init];
                tmpMovie.movie_title = movieTitle;
                tmpMovie.user_rating = rating;
                tmpMovie.movie_poster_file = moviePoster;
                tmpMovie.movie_TMDB_id = movieID;
                [movieArray addObject:tmpMovie];
                if ([isFave intValue] == 1) {
                    [favoritesArray addObject:tmpMovie];
                }
            }
            [_reviewsCountButton setTitle:[NSString stringWithFormat:@"%lu", [movieArray count]] forState:UIControlStateNormal];
            [_listTableView reloadData];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  - Actions
//switching segments
-(IBAction)segmentSelected:(id)sender {
    [_listTableView reloadData];
}
//pop to reviews
-(void)clickedReviews:(id)sender {
    [_listSegment setSelectedSegmentIndex:0];
    [_listTableView reloadData];
}
//clicked to follow user
-(IBAction)followUserClicked:(id)sender {

    UIButton *resultButton = (UIButton *)sender;
    
    if ([resultButton.currentTitle isEqual:@"Follow"]) {
        if (![currentFriendsArray containsObject:self.userIdPassed]) {
            [currentFriendsArray addObject:self.userIdPassed];
            [_followUserButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
    } else {
        [currentFriendsArray removeObject:self.userIdPassed];
        [_followUserButton setTitle:@"Follow" forState:UIControlStateNormal];
        
    }
    //add user to friends
    [[PFUser currentUser]setObject:currentFriendsArray forKey:@"friends"];
    [[PFUser currentUser]saveInBackground];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_listSegment selectedSegmentIndex] == 0) {
        return [movieArray count];
    } else if ([_listSegment selectedSegmentIndex] == 1) {
        return [favoritesArray count];
    } else if ([_listSegment selectedSegmentIndex] == 2) {
        return [wantToSeeArray count];
    }
    return [movieArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    
    MovieClass *currentMovie;
    
    switch ([_listSegment selectedSegmentIndex]) {
        case 0:
            currentMovie = [movieArray objectAtIndex:indexPath.row];
            break;
        case 1:
            currentMovie = [favoritesArray objectAtIndex:indexPath.row];
            break;
        case 2:
            currentMovie = [wantToSeeArray objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    if (cell != nil)
    {
        NSString *filledStar = @"star-48.png";
        NSString *emptyStar = @"star-50.png";
        
        UIImageView *star1 = (UIImageView *) [cell viewWithTag:3];
        UIImageView *star2 = (UIImageView *) [cell viewWithTag:4];
        UIImageView *star3 = (UIImageView *) [cell viewWithTag:5];
        UIImageView *star4 = (UIImageView *) [cell viewWithTag:6];
        UIImageView *star5 = (UIImageView *) [cell viewWithTag:7];
        
        UIImage *star1Image;
        UIImage *star2Image;
        UIImage *star3Image;
        UIImage *star4Image;
        UIImage *star5Image;
        
        UILabel *ratingLabel = (UILabel *) [cell viewWithTag:8];
        
        if ([currentMovie.user_rating isEqual:@"1"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:emptyStar];
            star3Image = [UIImage imageNamed:emptyStar];
            star4Image = [UIImage imageNamed:emptyStar];
            star5Image = [UIImage imageNamed:emptyStar];
        } else if ([currentMovie.user_rating isEqual:@"2"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:filledStar];
            star3Image = [UIImage imageNamed:emptyStar];
            star4Image = [UIImage imageNamed:emptyStar];
            star5Image = [UIImage imageNamed:emptyStar];
        } else if ([currentMovie.user_rating isEqual:@"3"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:filledStar];
            star3Image = [UIImage imageNamed:filledStar];
            star4Image = [UIImage imageNamed:emptyStar];
            star5Image = [UIImage imageNamed:emptyStar];
            
        } else if ([currentMovie.user_rating isEqual:@"4"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:filledStar];
            star3Image = [UIImage imageNamed:filledStar];
            star4Image = [UIImage imageNamed:filledStar];
            star5Image = [UIImage imageNamed:emptyStar];
            
        } else {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:filledStar];
            star3Image = [UIImage imageNamed:filledStar];
            star4Image = [UIImage imageNamed:filledStar];
            star5Image = [UIImage imageNamed:filledStar];
            
        }
        
        if ([_listSegment selectedSegmentIndex] == 0) {
            star1.image = star1Image;
            star2.image = star2Image;
            star3.image = star3Image;
            star4.image = star4Image;
            star5.image = star5Image;
            ratingLabel.text = @"My Rating";
        } else if ([_listSegment selectedSegmentIndex] == 1) {
            star1.image = star1Image;
            star2.image = star2Image;
            star3.image = star3Image;
            star4.image = star4Image;
            star5.image = star5Image;
            ratingLabel.text = @"My Rating";
        } else if ([_listSegment selectedSegmentIndex] == 2) {
            ratingLabel.text = currentMovie.movie_date;
            star1.image = nil;
            star2.image = nil;
            star3.image = nil;
            star4.image = nil;
            star5.image = nil;
        }
        
        UIImageView *posterView = (UIImageView *) [cell viewWithTag:1];
        UIImage *posterImage = currentMovie.movie_poster_file;
        posterView.image = posterImage;
        
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
        titleLabel.text = currentMovie.movie_title;
        
        return cell;
    }
    return nil;
}
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier]isEqualToString:@"movieDetail"]) {
        MovieDetailViewController *vc = [segue destinationViewController];
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_listTableView indexPathForCell:cell];
        
        MovieClass *currentMovie;
        switch ([_listSegment selectedSegmentIndex]) {
            case 0:
                currentMovie = [movieArray objectAtIndex:indexPath.row];
                break;
            case 1:
                currentMovie = [favoritesArray objectAtIndex:indexPath.row];
                break;
            case 2:
                currentMovie = [wantToSeeArray objectAtIndex:indexPath.row];
                break;
            default:
                currentMovie = [movieArray objectAtIndex:indexPath.row];
                break;
        }
        vc.selectedMovie = currentMovie;
    } else if ([[segue identifier]isEqualToString:@"following"]) {
        FollowersTableViewController *fvc = [segue destinationViewController];
        fvc.selectionType = @"following";
        fvc.passedUserId = self.userIdPassed;
    } else {
        FollowersTableViewController *fvc = [segue destinationViewController];
        fvc.selectionType = @"followers";
        fvc.passedUserId = self.userIdPassed;
    }
}
@end
