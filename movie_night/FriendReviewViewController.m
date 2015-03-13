//
//  FriendReviewViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/23/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "FriendReviewViewController.h"
#import "MovieDetailViewController.h"
#import "FriendProfileViewController.h"
#import <Parse/Parse.h>

@interface FriendReviewViewController ()

@end

@implementation FriendReviewViewController
@synthesize scrollView, commentField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    commentArray = [[NSMutableArray alloc]init];
    [commentField setDelegate:self];
    [self registerForKeyboardNotifications];
    
    PFUser *currentUser = [PFUser currentUser];
    userId = currentUser.objectId;
    reviewId = self.selectedReview.user_review_objectId;
    
    if (self.selectedReview.movie_poster_file == nil) {
        [self getReviewWithoutPassedData];
    } else {
        [self getReviewWithPassedData];
    }
    
    //get current user data
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    NSArray *userArray = [query findObjects];
    NSLog(@"User: %@", [userArray firstObject]);
    NSDictionary *userDict = [userArray firstObject];
    username = [userDict objectForKey:@"username"];
    userImage = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"] getData]];
    
    [self getComments];
    
}
-(void)getReviewWithPassedData {
    //set friend profile pic
    UIImage *profilePicImage = self.selectedReview.user_photo_file;
    _profilePic.image = profilePicImage;
    
    //set poster
    UIImage *posterImage = self.selectedReview.movie_poster_file;
    if (posterImage != nil) {
        _posterView.image = posterImage;
    } else {
        _posterView.image = self.moviePosterPassed;
    }
    
    [_usernameButton setTitle:self.selectedReview.username forState:UIControlStateNormal];
    if (self.selectedReview.movie_title != nil) {
        [_movieTitleButton setTitle:self.selectedReview.movie_title forState:UIControlStateNormal];
    } else {
        [_movieTitleButton setTitle:self.movieTitlePassed forState:UIControlStateNormal];
    }
    _reviewField.text = self.selectedReview.user_review;
    
    //set stars
    NSString *rating = self.selectedReview.user_rating;
    
    NSString *filledStar = @"christmas_star-48.png";
    NSString *emptyStar = @"outline_star-48.png";
    
    UIImage *star1Image;
    UIImage *star2Image;
    UIImage *star3Image;
    UIImage *star4Image;
    UIImage *star5Image;
    
    if ([rating isEqual:@"1"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:emptyStar];
        star3Image = [UIImage imageNamed:emptyStar];
        star4Image = [UIImage imageNamed:emptyStar];
        star5Image = [UIImage imageNamed:emptyStar];
    } else if ([rating isEqual:@"2"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:filledStar];
        star3Image = [UIImage imageNamed:emptyStar];
        star4Image = [UIImage imageNamed:emptyStar];
        star5Image = [UIImage imageNamed:emptyStar];
    } else if ([rating isEqual:@"3"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:filledStar];
        star3Image = [UIImage imageNamed:filledStar];
        star4Image = [UIImage imageNamed:emptyStar];
        star5Image = [UIImage imageNamed:emptyStar];
        
    } else if ([rating isEqual:@"4"]) {
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
    _star1.image = star1Image;
    _star2.image = star2Image;
    _star3.image = star3Image;
    _star4.image = star4Image;
    _star5.image = star5Image;
}
-(void)getReviewWithoutPassedData {
    
    self.selectedReview.userID = userId;
    PFQuery *reviewQuery = [PFQuery queryWithClassName:@"Reviews"];
    [reviewQuery whereKey:@"objectId" equalTo:reviewId];
    
    [reviewQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {
        
        for (PFObject *object in reviews) {
            
            //set poster
            UIImage *posterImage = [UIImage imageWithData:[(PFFile *)object[@"moviePoster"]getData]];
            _posterView.image = posterImage;
            self.selectedReview.movie_TMDB_id = [object objectForKey:@"movieID"];
            
            PFQuery *user = [PFUser query];
            [user whereKey:@"objectId" equalTo:userId];
            NSArray *userArray = [user findObjects];
            NSDictionary *userDict = [userArray firstObject];
            
            //set friend profile pic
            UIImage *profilePicImage = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"]getData]];;
            _profilePic.image = profilePicImage;
            
            [_usernameButton setTitle:[userDict objectForKey:@"username"] forState:UIControlStateNormal];
            [_movieTitleButton setTitle:[object objectForKey:@"movieTitle"] forState:UIControlStateNormal];
            
            _reviewField.text = [object objectForKey:@"review"];
            
            //set stars
            NSNumber *ratingNum = [object objectForKey:@"rating"];
            NSString *rating = [NSString stringWithFormat:@"%@", ratingNum];
            
            NSString *filledStar = @"christmas_star-48.png";
            NSString *emptyStar = @"outline_star-48.png";
            
            UIImage *star1Image;
            UIImage *star2Image;
            UIImage *star3Image;
            UIImage *star4Image;
            UIImage *star5Image;
            
            if ([rating isEqual:@"1"]) {
                star1Image = [UIImage imageNamed:filledStar];
                star2Image = [UIImage imageNamed:emptyStar];
                star3Image = [UIImage imageNamed:emptyStar];
                star4Image = [UIImage imageNamed:emptyStar];
                star5Image = [UIImage imageNamed:emptyStar];
            } else if ([rating isEqual:@"2"]) {
                star1Image = [UIImage imageNamed:filledStar];
                star2Image = [UIImage imageNamed:filledStar];
                star3Image = [UIImage imageNamed:emptyStar];
                star4Image = [UIImage imageNamed:emptyStar];
                star5Image = [UIImage imageNamed:emptyStar];
            } else if ([rating isEqual:@"3"]) {
                star1Image = [UIImage imageNamed:filledStar];
                star2Image = [UIImage imageNamed:filledStar];
                star3Image = [UIImage imageNamed:filledStar];
                star4Image = [UIImage imageNamed:emptyStar];
                star5Image = [UIImage imageNamed:emptyStar];
                
            } else if ([rating isEqual:@"4"]) {
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
            _star1.image = star1Image;
            _star2.image = star2Image;
            _star3.image = star3Image;
            _star4.image = star4Image;
            _star5.image = star5Image;
            
        }
    }];
}
//get previous comments from parse
-(void)getComments {
    
    //get comments that contain this review id
    PFQuery *reviewsQuery = [PFQuery queryWithClassName:@"Activity"];
    [reviewsQuery whereKey:@"reviewId" equalTo:reviewId];
    [reviewsQuery whereKey:@"activityType" equalTo:@"comment"];
    [reviewsQuery orderByAscending:@"createdAt"];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {
        
        for (PFObject *object in reviews) {
            NSLog(@"Object: %@", object);
            
            NSString *prevComment = [object objectForKey:@"comment"];
            NSString *prevUserId = [object objectForKey:@"fromUser"];
            commenterId = [object objectForKey:@"fromUser"];
            
            //get info about user who left comment
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"objectId" equalTo:prevUserId];
            NSArray *usersArray = [userQuery findObjects];
            NSDictionary *userDict = [usersArray firstObject];
        
            NSString *prevUsername = [userDict objectForKey:@"username"];
            UIImage *image = [UIImage imageWithData:[(PFFile *)userDict[@"profile_pic"] getData]];

            //put comments in table
            NSDictionary *tmpDict = [[NSDictionary alloc]initWithObjectsAndKeys:prevComment, @"comment", prevUsername, @"username", image, @"profile_pic", commenterId, @"userId", nil];
            [commentArray addObject:tmpDict];
            [_commentTable reloadData];
        }
    }];
}
//set up textfield so return button closes keyboard
-(BOOL)textFieldShouldReturn:(UITextField*)textField {

    [textField resignFirstResponder];
    return NO;
}
//register keyboard to receive notifications
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
//call when keyboard is shown
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    //scroll view to bottem field so keyboard doesn't hide it
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, commentField.frame.origin) ) {
        
        [self.scrollView scrollRectToVisible:commentField.frame animated:YES];
    }
}
//when keyboard is hidden
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    //sroll view down when keyboard is hidden to regular dimensions
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}
//when user posts a comment
-(void)onPostComment:(id)sender {
    NSString *comment = [commentField text];
    [commentField resignFirstResponder];
    
    if (![comment isEqualToString:@""]) {
        
        
        //add to comment table
        NSDictionary *commentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", username, @"username", userImage, @"profile_pic", nil];
        [commentArray addObject:commentDict];
        [_commentTable reloadData];
        [commentField setText:@""];
    
        //save to parse
        PFObject *newComment = [PFObject objectWithClassName:@"Activity"];
        newComment[@"activityType"] = @"comment";
        newComment[@"fromUser"] = userId;
        newComment[@"toUser"] = self.selectedReview.userID;
        newComment[@"movieID"] = self.selectedReview.movie_TMDB_id;
        newComment[@"comment"] = comment;
        newComment[@"reviewId"] = reviewId;
        newComment[@"movieTitle"] = self.selectedReview.movie_title;
        [newComment saveInBackground];
    }
}
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [commentArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    NSDictionary *commentDict = [commentArray objectAtIndex:indexPath.row];
    
    if (cell != nil) {
        
        UIImageView *profilePicView = (UIImageView *) [cell viewWithTag:1];
        UIImage *profileImage = [commentDict objectForKey:@"profile_pic"];
        profilePicView.image = profileImage;
        
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:2];
        nameLabel.text = [commentDict objectForKey:@"username"];
        
        UILabel *commentLabel = (UILabel *) [cell viewWithTag:3];
        commentLabel.text = [commentDict objectForKey:@"comment"];

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
    
    //if segueing to movie detail controller
    if ([[segue identifier] isEqualToString:@"movieDetail"]) {
        MovieDetailViewController *mdvc = [segue destinationViewController];
        mdvc.passed_movie_id = self.selectedReview.movie_TMDB_id;
        mdvc.selectedMovie = self.selectedReview;
    }
    else if ([[segue identifier]isEqualToString:@"friendCommentProfile"]) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_commentTable indexPathForCell:cell];
        
        FriendProfileViewController *fpvc = [segue destinationViewController];
        fpvc.userIdPassed = [[commentArray objectAtIndex:indexPath.row]objectForKey:@"userId"];
    }
    //else segueing to friend profile page
    else {
        FriendProfileViewController *fpvc = [segue destinationViewController];
        fpvc.userIdPassed = self.selectedReview.userID;
        NSLog(@"User id : %@, Passed: %@", self.selectedReview.userID, fpvc.userIdPassed);
    }
    
}


@end
