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
    
    //init reveal controller for settings
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {

        [self.settingsButton setTarget: self.revealViewController];
        [self.settingsButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    _usernameField.delegate = self;
    _nameField.delegate = self;
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
                
                if ([isFave intValue] == 1) {
                    [favoritesArray addObject:tmpMovie];
    
                }
                if ([isWantToSee intValue] ==1) {
                    [wantToSeeArray addObject:tmpMovie];
                } else {
                    [movieArray addObject:tmpMovie];
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
    
    
    if (currentUser != nil) {
        [self loadData];
        [self refreshView];
        [_guestView setHidden:YES];
    } else {
        [_guestView setHidden:NO];
        [self.settingsButton setAction:nil];
    }
}
//set up textfield so return button puts focus on the next textfield
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    
    if (userId != nil) {
        [textField resignFirstResponder];
        if ([textField tag] == 10) {
            //update username
            [[PFUser currentUser]setObject:[_usernameField text] forKey:@"username"];
            [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    NSLog(@"Error: %@", errorString);
                    //if username already in use
                    if ([error code] == 202) {
           
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Username already in use" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:okAction];
                        [self presentViewController:alertController animated:YES completion:nil];
                    }
                    [_usernameField setText:oldUsername];
                }
            }];
        } else if ([textField tag] == 11) {
            //update name
            [[PFUser currentUser]setObject:[_nameField text] forKey:@"full_name"];
            [[PFUser currentUser]saveInBackground];
        }
    }
    return YES;
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
    [_followingButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[friendsArray count]] forState:UIControlStateNormal];
    UIImage *image = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"] getData]];
    
    //get number of revies
    __block int reviewsCount;
    PFQuery *countQuery = [PFQuery queryWithClassName:@"Reviews"];
    [countQuery whereKey:@"userID" equalTo:currentUser.objectId];
    [countQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            reviewsCount = count;
        } else {
            reviewsCount = 0;
        }
        [_reviewsCountButton setTitle:[NSString stringWithFormat:@"%i", reviewsCount] forState:UIControlStateNormal];
    }];
   //make sure we aren't refreshing after uploading a new photo, parse won't have saved it yet
    if (!newPic) {
        _profilePicView.image = image;
    } else {
        newPic = NO;
    }
    
    //set uielements
    [_nameLabel setText:fullName];
    oldUsername = username;
    self.navBar.title = @"My Profile";
    [_nameField setText:fullName];
    [_usernameField setText:username];
    
    //get number of followers
    PFQuery *followersQuery = [PFUser query];
    [followersQuery whereKey:@"friends" equalTo:userId];
    NSArray *followersFoundArray = [followersQuery findObjects];
    NSLog(@"%@", followersFoundArray);
    [_followersButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)[followersFoundArray count]] forState:UIControlStateNormal];

}
#pragma mark - Change Photo
//upload a profile pic
-(IBAction)uploadPhoto:(id)sender {
    
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES;
    
    //open action sheet to choose photo type
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController * view=   [UIAlertController
                                     alertControllerWithTitle:@"Upload Photo"
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction* camera = [UIAlertAction
                                 actionWithTitle:@"Take Photo With Camera"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     //display camera
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                     imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                     [self presentViewController:imgPicker animated:YES completion:nil];
                                     
                                 }];
        UIAlertAction* album = [UIAlertAction
                                actionWithTitle:@"Choose Existing Photo"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {
                                    //display photo album
                                    [view dismissViewControllerAnimated:YES completion:nil];
                                    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                    [self presentViewController:imgPicker animated:YES completion:nil];
                                    
                                }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [view dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        
        [view addAction:camera];
        [view addAction:album];
        [view addAction:cancel];
        [self presentViewController:view animated:YES completion:nil];
    } else {
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // close the image picker
    [picker dismissViewControllerAnimated:YES completion:nil];

    //set the image on the ui
    UIImage *image = (UIImage *)info[UIImagePickerControllerOriginalImage];
    _profilePicView.image = image;
    newPic = YES;
    
    //save image to parse
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];
    [[PFUser currentUser]setObject:imageFile forKey:@"profile_pic"];
    [[PFUser currentUser]saveInBackground];
}
#pragma mark - Actions
- (void)logoutButtonAction:(id)sender  {
    
    //log user out of notifications
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [[PFInstallation currentInstallation] removeObjectForKey:currentInstallation.installationId];
    [[PFInstallation currentInstallation] saveInBackground];
    [PFUser logOut]; // Log out
    
    // Return to Login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//reload table when user selects segment
-(void)segmentSelected:(id)sender {
    [_listTableView reloadData];
}
//if clicks reviews, pop to reviews table
-(void)clickedReviews:(id)sender {
    [_listSegment setSelectedSegmentIndex:0];
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
    
    //switch out data based on which segment is selected
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
    } else if ([[segue identifier]isEqualToString:@"followers"]){
        FollowersTableViewController *fvc = [segue destinationViewController];
        fvc.selectionType = @"followers";
    } else {
        
    }
}

@end
