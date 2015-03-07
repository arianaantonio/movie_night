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
    
    
    [self refreshFeed];
    [self setupRefreshControl];
    
}
#pragma mark - Refreshing
//refresh the friend feed
-(void)refreshFeed {
    
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
            
            //add to array
            [feedArray addObject:tmpMovie];
            
            //reload table
            [_feedTableView reloadData];
            }];
        }
    }];
}
- (void)setupRefreshControl
{
    // Programmatically inserting a UIRefreshControl
    self.refreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"Refreshing Reviews..."];
    self.refreshControl.attributedTitle = refreshString;
    
    
    // Setup the loading view, which will hold the moving graphics
    refreshLoadingView = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    refreshLoadingView.backgroundColor = [UIColor clearColor];
    
    // Create the graphic image views

    compass_spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moviereelSpinner.png"]];
    compass_spinner.contentMode = UIViewContentModeScaleAspectFit;
    compass_spinner.contentMode = UIViewContentModeCenter;
   
   // CGFloat center = self.refreshControl.frame.origin.x/2;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width/2;
  
    [compass_spinner setFrame:CGRectMake(screenWidth-25, self.refreshControl.frame.origin.y+5, compass_spinner.frame.size.width, compass_spinner.frame.size.height)];
     UILabel *refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(screenWidth-125, compass_spinner.frame.origin.y+55, 250.0f, 40.0f)];
    refreshLabel.text = @"Refreshing Reviews...";
    refreshLabel.textColor = [UIColor whiteColor];
  //  compass_spinner.frame = CGRectMake(refreshLoadingView.bounds.size.height, refreshLoadingView.bounds.size.width/2, 50.0f, 50.0f);
    /*
    if (compass_spinner.bounds.size.width > ((UIImage*)imagesArray[i]).size.width && compass_spinner.bounds.size.height > ((UIImage*)imagesArray[i]).size.height) {
        compass_spinner.contentMode = UIViewContentModeScaleAspectFit;
    }*/
    
    // Add the graphics to the loading view
   // [refreshLoadingView addSubview:compass_background];
    [refreshLoadingView addSubview:compass_spinner];
    // Clip so the graphics don't stick out
    refreshLoadingView.clipsToBounds = YES;
    // Hide the original spinner icon
   // self.refreshControl.tintColor = [UIColor clearColor];
  // [refreshLoadingView addSubview:refreshLabel];
    [self.refreshControl addSubview:refreshLoadingView];
    // Initalize flags
    isRefreshIconsOverlap = NO;
    isRefreshAnimating = NO;
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}
- (void)refresh:(id)sender{
    
    // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
    // This is where you'll make requests to an API, reload data, or process information
    [self animateRefreshView];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"DONE");
        // When done requesting/reloading/processing invoke endRefreshing, to close the control
        [self.refreshControl endRefreshing];
    });
    // -- FINISHED SOMETHING AWESOME, WOO! --
}
- (void)animateRefreshView
{
   
    // Flag that we are animating
    isRefreshAnimating = YES;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [compass_spinner setTransform:CGAffineTransformRotate(compass_spinner.transform, M_PI_2)];
                     }
                     completion:^(BOOL finished) {
                         // If still refreshing, keep spinning, else reset
                         if (self.refreshControl.isRefreshing) {
                             [self animateRefreshView];
                         }else{
                            // [self resetAnimation];
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
        
        NSString *filledStar = @"star-48.png";
        NSString *emptyStar = @"star-50.png";
        
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
