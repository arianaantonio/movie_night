//
//  ProfileViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/16/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "FollowersTableViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize settingsButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_uploadPhoto setHidden:YES];
    
    //init reveal controller for settings
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {

        [self.settingsButton setTarget: self.revealViewController];
        [self.settingsButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    wantToSeeArray = [[NSMutableArray alloc]init];
    favoritesArray = [[NSMutableArray alloc]init];
    movieArray = [[NSMutableArray alloc]init];

}
-(void)refreshView {
    
    [movieArray removeAllObjects];
    [favoritesArray removeAllObjects];
    [wantToSeeArray removeAllObjects];
    
    //get user reviews
    PFQuery *query2 = [PFQuery queryWithClassName:@"Reviews"];
    [query2 whereKey:@"userID" equalTo:userId];
    [query2 orderByDescending:@"createdAt"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            NSString *movieTitle = @"";
            NSString *rating = @"";
            NSNumber *isFave;
            UIImage *moviePoster;
            NSString *movieID = @"";
            NSNumber *isWantToSee;
            NSDate *dateReleased;
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                
                //get object data returned
                rating = [object objectForKey:@"rating"];
                moviePoster = [UIImage imageWithData:[(PFFile *)object[@"moviePoster"]getData]];
                movieTitle = [object objectForKey:@"movieTitle"];
                isFave = [object objectForKey:@"isFavorite"];
                movieID = [object objectForKey:@"movieID"];
                isWantToSee = [object objectForKey:@"isWantToSee"];
                dateReleased = [object objectForKey:@"dateReleased"];
                MovieClass *tmpMovie = [[MovieClass alloc]init];
                tmpMovie.movie_title = movieTitle;
                tmpMovie.user_rating = rating;
                tmpMovie.movie_poster_file = moviePoster;
                tmpMovie.movie_TMDB_id = movieID;
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"MMM dd, yyyy"];
                NSString *date = [df stringFromDate:dateReleased];
                tmpMovie.movie_date = date;
                [movieArray addObject:tmpMovie];
                if ([isFave intValue] == 1) {
                    [favoritesArray addObject:tmpMovie];
                }
                if ([isWantToSee intValue] ==1) {
                    [wantToSeeArray addObject:tmpMovie];
                }
                [_listTableView reloadData];
            }
        }
    }];
}
//load and refresh data whenever we come back to the profile screen
-(void)viewDidAppear:(BOOL)animated {
    //check for current user
    PFUser *currentUser = [PFUser currentUser];
    userId = currentUser.objectId;
    
    [self refreshView];
    
    if (currentUser &&
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self loadData];
    } else if (currentUser) {
        [self loadData];
    }
}

//load user data to populate UI
-(void)loadData {

    //get current user data
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"Object id: %@", currentUser.objectId);
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    NSArray *userArray = [query findObjects];
    NSLog(@"User: %@", [userArray firstObject]);
    NSDictionary *userDict = [userArray firstObject];
    NSString *username = [userDict objectForKey:@"username"];
    NSString *fullName = [userDict objectForKey:@"full_name"];
    friendsArray = [[NSArray alloc]initWithArray:[userDict objectForKey:@"friends"]];
    [_followingButton setTitle:[NSString stringWithFormat:@"Following: %lu", (unsigned long)[friendsArray count]] forState:UIControlStateNormal];
  //  [_friendsCountLabel setText:[NSString stringWithFormat:@"Friends: %lu", (unsigned long)[friendsArray count]]];
    UIImage *image = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"] getData]];
    
    __block int reviewsCount;
    PFQuery *countQuery = [PFQuery queryWithClassName:@"Reviews"];
    [countQuery whereKey:@"userID" equalTo:currentUser.objectId];
    [countQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            reviewsCount = count;
        } else {
            reviewsCount = 0;
        }
        [_reviewsCountLabel setText:[NSString stringWithFormat:@"Reviews: %i", reviewsCount]];
    }];
    if (image == nil) {
        _profilePicView.image = [UIImage imageNamed:@"Ninja.png"];
        [_uploadPhoto setHidden:NO];
    } else {
        _profilePicView.image = image;
        [_uploadPhoto setHidden:YES];
    }
    
    //set uielements
    [_nameLabel setText:fullName];
    self.navBar.title = username;
    
    PFQuery *followersQuery = [PFUser query];
    [followersQuery whereKey:@"friends" equalTo:userId];
    NSArray *followersFoundArray = [followersQuery findObjects];
    NSLog(@"Followers: %@", followersFoundArray);
    [_followersButton setTitle:[NSString stringWithFormat:@"Followers: %lu", (unsigned long)[followersFoundArray count]] forState:UIControlStateNormal];

}
//upload a profile pic
-(IBAction)uploadPhoto:(id)sender {
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera &&UIImagePickerControllerSourceTypePhotoLibrary;
    //[self.navigationController presentModalViewController:imgPicker animated:YES];
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Close the image picker
    //[picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];

    UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
    _profilePicView.image = image;
    [_uploadPhoto setHidden:YES];
 
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];
    [[PFUser currentUser]setObject:imageFile forKey:@"profile_pic"];
    [[PFUser currentUser]saveInBackground];
}
- (void)logoutButtonAction:(id)sender  {
    [PFUser logOut]; // Log out
    
    // Return to Login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)segmentSelected:(id)sender {
    [_listTableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        NSString *filledStar = @"christmas_star-48.png";
        NSString *emptyStar = @"outline_star-48.png";
        
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
    } else {
        FollowersTableViewController *fvc = [segue destinationViewController];
        fvc.selectionType = @"followers";
    }
}

@end
