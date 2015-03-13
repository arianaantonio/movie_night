//
//  FriendFeedViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/16/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "FriendFeedViewController.h"
#import <Parse/Parse.h>

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_night_logo.png"]];
    
    feedArray = [[NSMutableArray alloc]init];
    PFUser *currentUser = [PFUser currentUser];
    userId = currentUser.objectId;
    
    //make sure notifications are set to logged in user
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentUser) {
        [currentInstallation setObject:currentUser forKey:@"user"];
        currentInstallation.channels = @[currentUser.objectId];
    }
    
    reachGoogle = [Reachability reachabilityWithHostName:@"www.google.com"];
    checkNetworkStatus = [reachGoogle currentReachabilityStatus];
    
    if (checkNetworkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please connect to a network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    if (currentUser == nil) {
        
    } else {
        [self refreshFeed];
        [self setupRefreshControl];
    }
    //[self checkForNewActivity];
    
}
-(void)viewDidAppear:(BOOL)animated {
    if (userId != nil) {
        [self checkForNewActivity];
    }
}
-(void)checkForNewActivity {
    
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MMM dd, yyyy, hh:mm:ss"];
    NSString *timeStamp = [df stringFromDate:date];
    date = [df dateFromString:timeStamp];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdate = [defaults objectForKey:@"lastUpdate"];
  
    if (lastUpdate == nil) {
        lastUpdate = date;
    }
    
    PFQuery *updateQuery = [PFQuery queryWithClassName:@"Activity"];
    [updateQuery whereKey:@"toUser" equalTo:userId];
    [updateQuery whereKey:@"createdAt" greaterThan:lastUpdate];
    [updateQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            if (count > 0) {
                [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%i", count]];
            } else {
                [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
            }
        } else {
            // The request failed
        }
    }];
    
    [defaults setObject:date forKey:@"lastUpdate"];
}
#pragma mark - Refreshing
//refresh the friend feed
-(void)refreshFeed {
    [feedArray removeAllObjects];
    
    PFUser *currentUser = [PFUser currentUser];
    
    //get users friends
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    NSArray *userArray = [query findObjects];
    NSDictionary *userDict = [userArray firstObject];
    NSArray *friendsArray = [[NSArray alloc]initWithArray:[userDict objectForKey:@"friends"]];
    
    //get reviews that contain friends userIDs
    PFQuery *reviewsQuery = [PFQuery queryWithClassName:@"Reviews"];
    [reviewsQuery whereKey:@"userID" containedIn:friendsArray];
    [reviewsQuery orderByDescending:@"createdAt"];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {
        
        for (PFObject *object in reviews) {
            
            //get user info
            PFQuery *userInfo = [PFUser query];
            [userInfo whereKey:@"objectId" equalTo:[object objectForKey:@"userID"]];
            [userInfo findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
                
                
                //NSArray *friendArray = [userInfo findObjects];
                NSDictionary *friendDict = [friends firstObject];
                NSString *friendName = [friendDict objectForKey:@"username"];
                UIImage *profilePic = [UIImage imageWithData:[(PFFile *)friendDict[@"profile_pic"]getData]];
                NSLog(@"Friend: %@", friendDict);
                NSString *friendID = [object objectForKey:@"userID"];
                
                //get review info
                NSString *userReview = [object objectForKey:@"review"];
                NSString *userRating = [object objectForKey:@"rating"];
                NSString *movieTitle = [object objectForKey:@"movieTitle"];
                UIImage *moviePoster = [UIImage imageWithData:[(PFFile *)object[@"moviePoster"]getData]];
                NSString *movieID = [object objectForKey:@"movieID"];
                
                //set to tmp class
                MovieClass *tmpMovie = [[MovieClass alloc]init];
                tmpMovie.username = friendName;
                tmpMovie.user_photo_file = profilePic;
                tmpMovie.user_review = userReview;
                tmpMovie.user_rating = userRating;
                tmpMovie.movie_title = movieTitle;
                tmpMovie.movie_poster_file = moviePoster;
                tmpMovie.movie_TMDB_id = movieID;
                tmpMovie.userID = friendID;
                tmpMovie.user_review_objectId = object.objectId;
                
                //add to array
                [feedArray addObject:tmpMovie];
            
                //reload table
                [_feedTableView reloadData];
                [self.refreshControl endRefreshing];
            }];
        }
    }];
}
- (void)setupRefreshControl
{
    //Create refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Reviews..."];
    self.refreshControl.attributedTitle = refreshString;
    
    //Create view for image
    refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    //Create image and center it in view
    spinningIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moviereelSpinner.png"]];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width/2;
    [spinningIcon setFrame:CGRectMake(screenWidth-25, self.refreshControl.frame.origin.y+5, spinningIcon.frame.size.width, spinningIcon.frame.size.height)];
    
    //add image to view
    [refreshLoadingView addSubview:spinningIcon];
    refreshLoadingView.clipsToBounds = YES;
   
   // self.refreshControl.tintColor = [UIColor clearColor];
    [self.refreshControl addSubview:refreshLoadingView];
    
    //Set flags
    isRefreshIconsOverlap = NO;
    isRefreshAnimating = NO;
    
    //Set refresh selector
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}
- (void)refresh:(id)sender{
    
    [self animateRefreshView];
    [self refreshFeed];
}
- (void)animateRefreshView
{
    //Set to animating
    isRefreshAnimating = YES;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the icon
                         [spinningIcon setTransform:CGAffineTransformRotate(spinningIcon.transform, M_PI_2)];
                     }
                     completion:^(BOOL finished) {
                         //refresh until call is done
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
                         }
                     }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [feedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendCell" forIndexPath:indexPath];
    
    MovieClass *currentMovie = [feedArray objectAtIndex:indexPath.row];
    if (cell != nil)
    {
        
        UIImageView *posterView = (UIImageView *) [cell viewWithTag:9];
        //UIImage *posterImage = [UIImage imageNamed:currentMovie.movie_poster];
        posterView.image = currentMovie.movie_poster_file;
        
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
        titleLabel.text = [NSString stringWithFormat:@"%@ rated %@:", currentMovie.username, currentMovie.movie_title];
        
        UIImageView *profilePicView = (UIImageView *) [cell viewWithTag:1];
       // UIImage *picImage = [UIImage imageNamed:currentMovie.user_photo];
        profilePicView.image = currentMovie.user_photo_file;
        
        UILabel *reviewLabel = (UILabel *) [cell viewWithTag:8];
        reviewLabel.text = currentMovie.user_review;
        
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
        
        NSString *filledStar = @"christmas_star-48.png";
        NSString *emptyStar = @"outline_star-48.png";
        
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
        star1.image = star1Image;
        star2.image = star2Image;
        star3.image = star3Image;
        star4.image = star4Image;
        star5.image = star5Image;
        
        return cell;
    }
    return nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    FriendReviewViewController *vc = [segue destinationViewController];
    if (vc != nil) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_feedTableView indexPathForCell:cell];
        
        MovieClass *currentMovie = [feedArray objectAtIndex:indexPath.row];
        vc.selectedReview = currentMovie;
    }
        
}


@end
