//
//  WriteReviewViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "WriteReviewViewController.h"
#import <Parse/Parse.h>
#import "MovieDetailViewController.h"

@interface WriteReviewViewController ()

@end

@implementation WriteReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    toggle = @"1";
    isFave = NO;
    
    if (![self.moviePassed.user_review isEqualToString:@""]) {
        [_reviewView setText:self.moviePassed.user_review];
    }
    if (![self.moviePassed.user_rating isEqualToString:@""]) {
        
        int reviewInt = [self.moviePassed.user_rating intValue];
        
        UIImage *filledStar = [UIImage imageNamed:@"star-48.png"];
        UIImage *emptyStar = [UIImage imageNamed:@"star-50.png"];
        
        //set star images
        switch (reviewInt) {
            case 1:
                numStars = @"1";
                [_star1Button setImage:filledStar forState:UIControlStateNormal];
                [_star2Button setImage:emptyStar forState:UIControlStateNormal];
                [_star3Button setImage:emptyStar forState:UIControlStateNormal];
                [_star4Button setImage:emptyStar forState:UIControlStateNormal];
                [_star5Button setImage:emptyStar forState:UIControlStateNormal];
                break;
            case 2:
                numStars = @"2";
                [_star1Button setImage:filledStar forState:UIControlStateNormal];
                [_star2Button setImage:filledStar forState:UIControlStateNormal];
                [_star3Button setImage:emptyStar forState:UIControlStateNormal];
                [_star4Button setImage:emptyStar forState:UIControlStateNormal];
                [_star5Button setImage:emptyStar forState:UIControlStateNormal];
                break;
            case 3:
                numStars = @"3";
                [_star1Button setImage:filledStar forState:UIControlStateNormal];
                [_star2Button setImage:filledStar forState:UIControlStateNormal];
                [_star3Button setImage:filledStar forState:UIControlStateNormal];
                [_star4Button setImage:emptyStar forState:UIControlStateNormal];
                [_star5Button setImage:emptyStar forState:UIControlStateNormal];
                break;
            case 4:
                numStars = @"4";
                [_star1Button setImage:filledStar forState:UIControlStateNormal];
                [_star2Button setImage:filledStar forState:UIControlStateNormal];
                [_star3Button setImage:filledStar forState:UIControlStateNormal];
                [_star4Button setImage:filledStar forState:UIControlStateNormal];
                [_star5Button setImage:emptyStar forState:UIControlStateNormal];
                break;
            case 5:
                numStars = @"5";
                [_star1Button setImage:filledStar forState:UIControlStateNormal];
                [_star2Button setImage:filledStar forState:UIControlStateNormal];
                [_star3Button setImage:filledStar forState:UIControlStateNormal];
                [_star4Button setImage:filledStar forState:UIControlStateNormal];
                [_star5Button setImage:filledStar forState:UIControlStateNormal];
                break;
            default:
                break;
        }

    }
    if (self.moviePassed.user_is_fave !=nil) {
        UIImage *heart;
        if ([self.moviePassed.user_is_fave intValue] == 0) {
            heart = [UIImage imageNamed:@"like_outline-48.png"];
        } else {
            heart = [UIImage imageNamed:@"hearts-48.png"];
        }
        _heartImageView.image = heart;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//save review to parse
-(IBAction)clickedSave:(id)sender {
    
    //get review from UI
    NSString *review = [_reviewView text];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MMM dd, yyyy"];
    NSDate *date = [df dateFromString:self.moviePassed.movie_date];
    NSLog(@"Movie id: %@", self.moviePassed.movie_TMDB_id);
    NSString *movieId = [NSString stringWithFormat:@"%@", self.moviePassed.movie_TMDB_id];
    
    //get current user
    PFUser *currentUser = [PFUser currentUser];
    
    //get poster and convert to PFFile for uploading
    NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", self.moviePassed.movie_poster];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];
    
    //check if review contains Parse object id, if not, save as new
    if ([self.moviePassed.user_review_objectId isEqualToString:@""]|| self.moviePassed.user_review_objectId == nil) {
    
        //save review
        PFObject *newReview = [PFObject objectWithClassName:@"Reviews"];
        newReview[@"review"] = review;
        newReview[@"rating"] = numStars;
        newReview[@"userID"] = currentUser.objectId;
        newReview[@"movieID"] = movieId;
        newReview[@"moviePoster"] = imageFile;
        newReview[@"dateReleased"] = date;
        newReview[@"movieTitle"] = self.moviePassed.movie_title;
        newReview[@"isFavorite"] =  [NSNumber numberWithBool:isFave];
        [newReview saveInBackground];
    }
    //if there is a previous Parse object id, update review
    else {
        PFQuery *query = [PFQuery queryWithClassName:@"Reviews"];
        
        // Retrieve the object by id and update
        [query getObjectInBackgroundWithId:self.moviePassed.user_review_objectId block:^(PFObject *updateReview, NSError *error) {

            updateReview[@"review"] = review;
            updateReview[@"rating"] = numStars;
            updateReview[@"userID"] = currentUser.objectId;
            updateReview[@"movieID"] = movieId;
            updateReview[@"moviePoster"] = imageFile;
            updateReview[@"dateReleased"] = date;
            updateReview[@"movieTitle"] = self.moviePassed.movie_title;
            updateReview[@"isFavorite"] =  [NSNumber numberWithBool:isFave] ;
            [updateReview saveInBackground];
            
        }];
    }
    //setting object for unwind segue back to detail view
    self.moviePassed.user_review = review;
    self.moviePassed.user_rating = numStars;
    self.moviePassed.user_is_fave = [NSNumber numberWithBool:isFave];
    [self performSegueWithIdentifier:@"unwindSegue" sender:self];
    
}
//clicked favorite button
-(void)clickedFavorite:(id)sender {
    
    UIImage *heart;
    
    //toggle image
    if ([toggle isEqualToString:@"0"]) {
        heart = [UIImage imageNamed:@"like_outline-48.png"];
        toggle = @"1";
        isFave = NO;
    } else {
        heart = [UIImage imageNamed:@"hearts-48.png"];
        toggle = @"0";
        isFave = YES;
    }
    //set image
    _heartImageView.image = heart;

}
//change star images based on which one was clicked
-(void)clickStar:(id)sender {
    UIImage *filledStar = [UIImage imageNamed:@"star-48.png"];
    UIImage *emptyStar = [UIImage imageNamed:@"star-50.png"];
    
    //set star images
    switch ([sender tag]) {
        case 1:
            numStars = @"1";
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:emptyStar forState:UIControlStateNormal];
            [_star3Button setImage:emptyStar forState:UIControlStateNormal];
            [_star4Button setImage:emptyStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 2:
            numStars = @"2";
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:emptyStar forState:UIControlStateNormal];
            [_star4Button setImage:emptyStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 3:
            numStars = @"3";
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:filledStar forState:UIControlStateNormal];
            [_star4Button setImage:emptyStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 4:
            numStars = @"4";
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:filledStar forState:UIControlStateNormal];
            [_star4Button setImage:filledStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 5:
            numStars = @"5";
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:filledStar forState:UIControlStateNormal];
            [_star4Button setImage:filledStar forState:UIControlStateNormal];
            [_star5Button setImage:filledStar forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieDetailViewController *mvc = [segue destinationViewController];
    mvc.selectedMovie = self.moviePassed;
}


@end
