//
//  MovieDetailViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/15/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h> 
#import "WriteReviewViewController.h"
#import "FriendReviewViewController.h"

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set default values for toggling favorites
    toggle = @"1";
    isFave = NO;
    friendsReviews = [[NSMutableArray alloc]init];
    PFUser *currentUser = [PFUser currentUser];
    userId = currentUser.objectId;
    [_notEnoughLabel setHidden:YES];
    
    if (userId != nil) {
        [_guestLabel setHidden:YES];
        [_wantToSeeButton setHidden:NO];
        [self getMovieData];
        [self refreshView];
    } else {
        [_guestLabel setHidden:NO];
        [_wantToSeeButton setHidden:YES];
        [self getMovieData];
    }
}
-(void)viewDidAppear:(BOOL)animated {
    if (userId != nil) {
        [_guestLabel setHidden:YES];
        [self getMovieData];
        [self checkForNewActivity];
    } else {
        [_guestLabel setHidden:NO];
        [self getMovieData];
    }
}
-(void)checkForNewActivity {
    
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MMM dd, yyyy, hh:mm"];
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
    [updateQuery orderByDescending:@"createdAt"];
    [updateQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            if (count > 0) {
              //  [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%i", count]];
            } else {
                [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
            }
        } else {
            // The request failed
        }
    }];
    
    [defaults setObject:date forKey:@"lastUpdate"];
}
-(void)getMovieData {
    self.navBar.title = self.selectedMovie.movie_title;
    
    //set movie id
    movie_id = self.selectedMovie.movie_TMDB_id;
    
    ///----GETTING MOVIE INFO====///
    //get the movie details from the API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@?api_key=086941b3fdbf6f475d06a19773f6eb65&append_to_response=credits,videos", movie_id]];
    
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        
        if (data != nil) {
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            self.selectedMovie.movie_imdb_id = [returnedDict objectForKey:@"imdb_id"];
            self.selectedMovie.movie_plot_overview = [returnedDict objectForKey:@"overview"];
            
            // NSLog(@"Cast: %@", [returnedDict objectForKey:@"credits"]);
            
            //get cast and set to array of names
            NSArray *castArray = [[returnedDict objectForKey:@"credits"] objectForKey:@"cast"];
            NSString *castString = @"";
            if ([castArray count] !=0) {
                for (int i =0; i < [castArray count]; i++) {
                    
                    if (i == 4) {
                        castString = [castString stringByAppendingString:[NSString stringWithFormat:@"%@", [[castArray objectAtIndex:i]objectForKey:@"name"]]];
                    } else {
                        if (i < 4) {
                            castString = [castString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [[castArray objectAtIndex:i]objectForKey:@"name"]]];
                        }
                    }
                    
                }
            }
            // NSLog(@"Cast: %@", castString);
            
            //get crew and pull out director, then set to label
            self.selectedMovie.movie_cast = castString;
            NSArray *crewArray = [[returnedDict objectForKey:@"credits"] objectForKey:@"crew"];
            if ([crewArray count] != 0) {
                for (int i =0; i < [crewArray count]; i++) {
                    NSString *director = [[crewArray objectAtIndex:i]objectForKey:@"job"];
                    if ([director isEqualToString:@"Director"]) {
                        self.selectedMovie.movie_director = [[crewArray objectAtIndex:i]objectForKey:@"name"];
                        NSLog(@"Director: %@", [[crewArray objectAtIndex:i]objectForKey:@"name"]);
                    }
                }
            }
            //get genre and set to lavel
            NSArray *genreArray = [returnedDict objectForKey:@"genres"];
            NSString *genreString = @"";
            if ([genreArray count] != 0) {
                for (int i =0; i < [genreArray count]; i++) {
                    genreString = [genreString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [[genreArray objectAtIndex:i]objectForKey:@"name"]]];
                }
            }
            
            //iterate through videos and grab the trailer
            NSArray *videosArray = [[returnedDict objectForKey:@"videos"]objectForKey:@"results"];
            NSString *youTubeUrl = @"";
            for (int i =0; i < [videosArray count];i++) {
                NSString *videoType = [[videosArray objectAtIndex:i]objectForKey:@"type"];
                if ([videoType isEqualToString:@"Trailer"]) {
                    youTubeUrl = [[videosArray objectAtIndex:i]objectForKey:@"key"];
                }
            }
            //hide the trailer button if there is no trailer
            if ([youTubeUrl isEqualToString:@""]) {
                [_trailerButton setHidden:YES];
            } else {
                //build the youtube url
                NSLog(@"YouTube Key: %@", youTubeUrl);
                youTubeUrl = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", youTubeUrl];
                self.selectedMovie.movie_trailer = youTubeUrl;
            }
            
            //set labels from returned data
            // NSLog(@"%@", returnedDict);
            _movie_title_label.text = self.selectedMovie.movie_title;
            movie_title = self.selectedMovie.movie_title;
            _movie_title_label.font = [UIFont fontWithName:@"Quicksand-Bold" size:16];
            _plot_label.text = self.selectedMovie.movie_plot_overview;
            _plot_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
            _genre_label.text = genreString;
            _genre_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
            NSString *dateString = [returnedDict objectForKey:@"release_date"];
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd"];
            NSDate *date = [df dateFromString:dateString];
            [df setDateFormat:@"MMM dd, yyyy"];
            dateString = [df stringFromDate:date];
            self.selectedMovie.movie_date = dateString;
            _date_label.text = self.selectedMovie.movie_date;
            _date_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
            _director_label.text = [NSString stringWithFormat:@"Directed By: %@", self.selectedMovie.movie_director];
            _director_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
            
            //join cast names array into string and set to label
            NSArray *movie_cast = [[NSArray alloc]initWithObjects:self.selectedMovie.movie_cast, nil];
            _cast_label.text = [NSString stringWithFormat:@"Starring: %@",[movie_cast componentsJoinedByString:@", "]];
            _cast_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
            
            //get poster url and set to imageview
            self.selectedMovie.movie_poster = [returnedDict objectForKey:@"poster_path"];
            NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", self.selectedMovie.movie_poster];
            UIImage *posterJPG = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
            _poster_image.image = posterJPG;
            friendReviewData.movie_poster_file = posterJPG;
            //https://www.youtube.com/watch?v=SUXWAEX2jlg
            [self.view setNeedsDisplay];
            
        }
    }];
    
    ///----COLLATING MOVIE RATINGS====///
    //get all ratings for this movie
    NSString *movieIDStr = [NSString stringWithFormat:@"%@", movie_id];
    PFQuery *ratingsQuery = [PFQuery queryWithClassName:@"Reviews"];
    [ratingsQuery whereKey:@"movieID" equalTo:movieIDStr];
    
    [ratingsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {
        
        NSString *ratings = @"";
        NSNumber *ratingsNum;
        NSMutableArray *ratingsArray = [[NSMutableArray alloc]init];
        
        //get info about friends review
        for (PFObject *object in reviews) {
            
            ratings = [object objectForKey:@"rating"];
            
            //convert rating to a number so it can be added
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            nf.numberStyle = NSNumberFormatterDecimalStyle;
            ratingsNum = [nf numberFromString:ratings];
            [ratingsArray addObject:ratingsNum];
        }
        int ratingsInt = 0;
        
        //make sure there are at least 10 ratings to be more accurate
        if ([ratingsArray count] > 9) {
            
            //loop through ratings and add them together
            for (int i = 0; i < [ratingsArray count]; i++) {
                ratingsInt += [[ratingsArray objectAtIndex:i]intValue];
            }
            
            //divide for average and round result
            int ratingsTotal = (int)roundf(ratingsInt/[ratingsArray count]);
            NSLog(@"Rating total: %i, Average: %i", ratingsInt,ratingsTotal);
            UIImage *filledStar = [UIImage imageNamed:@"christmas_star-48.png"];
            UIImage *emptyStar = [UIImage imageNamed:@"outline_star-48.png"];
            
            //set stars
            switch (ratingsTotal) {
                case 1:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = emptyStar;
                    _totalStar3View.image = emptyStar;
                    _totalStar4View.image = emptyStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 2:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = emptyStar;
                    _totalStar4View.image = emptyStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 3:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = filledStar;
                    _totalStar4View.image = emptyStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 4:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = filledStar;
                    _totalStar4View.image = filledStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 5:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = filledStar;
                    _totalStar4View.image = filledStar;
                    _totalStar5View.image = filledStar;
                    break;
                default:
                    break;
            }
            
        } else {
            //if not enough reviews, show not enough label
            [_notEnoughLabel setHidden:NO];
        }
    }];

}
//refresh the view with passed over data
-(void)refreshView {
    /*
    self.navBar.title = self.selectedMovie.movie_title;
    
    //set movie id
    movie_id = self.selectedMovie.movie_TMDB_id;
    
        ///----GETTING MOVIE INFO====///
        //get the movie details from the API
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@?api_key=086941b3fdbf6f475d06a19773f6eb65&append_to_response=credits,videos", movie_id]];
        
        [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
            
            if (data != nil) {
                NSError *error;
                NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                self.selectedMovie.movie_imdb_id = [returnedDict objectForKey:@"imdb_id"];
                self.selectedMovie.movie_plot_overview = [returnedDict objectForKey:@"overview"];
                
                // NSLog(@"Cast: %@", [returnedDict objectForKey:@"credits"]);
                
                //get cast and set to array of names
                NSArray *castArray = [[returnedDict objectForKey:@"credits"] objectForKey:@"cast"];
                NSString *castString = @"";
                if ([castArray count] !=0) {
                    for (int i =0; i < [castArray count]; i++) {
                        
                        if (i == 4) {
                            castString = [castString stringByAppendingString:[NSString stringWithFormat:@"%@", [[castArray objectAtIndex:i]objectForKey:@"name"]]];
                        } else {
                            if (i < 4) {
                                castString = [castString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [[castArray objectAtIndex:i]objectForKey:@"name"]]];
                            }
                        }
                        
                    }
                }
                // NSLog(@"Cast: %@", castString);
                
                //get crew and pull out director, then set to label
                self.selectedMovie.movie_cast = castString;
                NSArray *crewArray = [[returnedDict objectForKey:@"credits"] objectForKey:@"crew"];
                if ([crewArray count] != 0) {
                    for (int i =0; i < [crewArray count]; i++) {
                        NSString *director = [[crewArray objectAtIndex:i]objectForKey:@"job"];
                        if ([director isEqualToString:@"Director"]) {
                            self.selectedMovie.movie_director = [[crewArray objectAtIndex:i]objectForKey:@"name"];
                            NSLog(@"Director: %@", [[crewArray objectAtIndex:i]objectForKey:@"name"]);
                        }
                    }
                }
                //get genre and set to lavel
                NSArray *genreArray = [returnedDict objectForKey:@"genres"];
                NSString *genreString = @"";
                if ([genreArray count] != 0) {
                    for (int i =0; i < [genreArray count]; i++) {
                        genreString = [genreString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [[genreArray objectAtIndex:i]objectForKey:@"name"]]];
                    }
                }
                
                //iterate through videos and grab the trailer
                NSArray *videosArray = [[returnedDict objectForKey:@"videos"]objectForKey:@"results"];
                NSString *youTubeUrl = @"";
                for (int i =0; i < [videosArray count];i++) {
                    NSString *videoType = [[videosArray objectAtIndex:i]objectForKey:@"type"];
                    if ([videoType isEqualToString:@"Trailer"]) {
                        youTubeUrl = [[videosArray objectAtIndex:i]objectForKey:@"key"];
                    }
                }
                //hide the trailer button if there is no trailer
                if ([youTubeUrl isEqualToString:@""]) {
                    [_trailerButton setHidden:YES];
                } else {
                    //build the youtube url
                    NSLog(@"YouTube Key: %@", youTubeUrl);
                    youTubeUrl = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", youTubeUrl];
                    self.selectedMovie.movie_trailer = youTubeUrl;
                }
                
                //set labels from returned data
                // NSLog(@"%@", returnedDict);
                _movie_title_label.text = self.selectedMovie.movie_title;
                movie_title = self.selectedMovie.movie_title;
                _movie_title_label.font = [UIFont fontWithName:@"Quicksand-Bold" size:16];
                _plot_label.text = self.selectedMovie.movie_plot_overview;
                _plot_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                _genre_label.text = genreString;
                _genre_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                NSString *dateString = [returnedDict objectForKey:@"release_date"];
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [df dateFromString:dateString];
                [df setDateFormat:@"MMM dd, yyyy"];
                dateString = [df stringFromDate:date];
                self.selectedMovie.movie_date = dateString;
                _date_label.text = self.selectedMovie.movie_date;
                _date_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                _director_label.text = [NSString stringWithFormat:@"Directed By: %@", self.selectedMovie.movie_director];
                _director_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                
                //join cast names array into string and set to label
                NSArray *movie_cast = [[NSArray alloc]initWithObjects:self.selectedMovie.movie_cast, nil];
                _cast_label.text = [NSString stringWithFormat:@"Starring: %@",[movie_cast componentsJoinedByString:@", "]];
                _cast_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                
                //get poster url and set to imageview
                self.selectedMovie.movie_poster = [returnedDict objectForKey:@"poster_path"];
                NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", self.selectedMovie.movie_poster];
                UIImage *posterJPG = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
                _poster_image.image = posterJPG;
                friendReviewData.movie_poster_file = posterJPG;
                //https://www.youtube.com/watch?v=SUXWAEX2jlg
                [self.view setNeedsDisplay];
                
            }
        }];*/
   
    ///----GETTING USER REVIEW INFO====///
    //check if user has left info for this movie
    NSString *movieIDStr = [NSString stringWithFormat:@"%@", movie_id];
    NSLog(@"User: %@, Movie: %@", userId, movie_id);
    [_reviewView setText:@"Write Review:"];
    
    UIImage *filledStar = [UIImage imageNamed:@"christmas_star-48.png"];
    UIImage *emptyStar = [UIImage imageNamed:@"outline_star-48.png"];
    
    //query parse for movie data
    PFQuery *query2 = [PFQuery queryWithClassName:@"Reviews"];
    [query2 whereKey:@"userID" equalTo:userId];
    [query2 whereKey:@"movieID" equalTo:movieIDStr];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            NSString *rating = @"";
            NSString *review = @"";
            NSNumber *isFavorite;
            NSString *objectID = @"";
            NSNumber *doesWantToSee;
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                if ([objects count] > 0) {
                    userHasReviewed = YES;
                }
                
                //get object data returned
                rating = [object objectForKey:@"rating"];
                review = [object objectForKey:@"review"];
                isFavorite = [object objectForKey:@"isFavorite"];
                doesWantToSee = [object objectForKey:@"isWantToSee"];
                objectID = object.objectId;
                reviewId = object.objectId;
                isWantToSee = [object objectForKey:@"isWantToSee"];
                
                if ([rating isEqualToString:@""] && ![self.selectedMovie.user_review isEqualToString:@""]) {
                    rating = self.selectedMovie.user_rating;
                    review = self.selectedMovie.user_review;
                    isFavorite = self.selectedMovie.user_is_fave;
                }
                //check if favorite and set heart image accordingly
                if ([isFavorite intValue] == 1) {
                    toggle = @"1";
                    [self clickedFavorite:self];
                } else {
                    toggle = @"0";
                    [self clickedFavorite:self];
                }
                //check if user has clicked want to see before
                if ([doesWantToSee intValue] == 1) {
                    [_wantToSeeButton setImage:[UIImage imageNamed:@"blueButton.png"] forState:UIControlStateNormal];
                } else {
                    [_wantToSeeButton setImage:[UIImage imageNamed:@"grayButton.png"] forState:UIControlStateNormal];
                }
                
                //set review text
                [_reviewView setText:review];
                
                //set star data
                int starsSaved = [rating intValue];
                
                //set stars based on reviews
                switch (starsSaved) {
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
                //set data to be passed over
                self.selectedMovie.user_review = review;
                self.selectedMovie.user_rating = rating;
                self.selectedMovie.user_is_fave = isFavorite;
                self.selectedMovie.user_review_objectId = objectID;
            }
            
        }
    }];
    ///----GETTING USER FRIEND REVIEW INFO====///
    //get current users friends
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userId];
    NSArray *userArray = [query findObjects];
    NSDictionary *userDict = [userArray firstObject];
    NSArray *friendsArray = [[NSArray alloc]initWithArray:[userDict objectForKey:@"friends"]];
    
    [friendsReviews removeAllObjects];
    
    //get reviews that contain friends userIDs and current movie id
    PFQuery *reviewsQuery = [PFQuery queryWithClassName:@"Reviews"];
    [reviewsQuery whereKey:@"userID" containedIn:friendsArray];
    [reviewsQuery whereKey:@"movieID" equalTo:movieIDStr];
    [reviewsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {
        
        NSString *friendID = @"";
        NSString *friendRating = @"";
        NSString *friendReview = @"";
        
        //get info about friends review
        for (PFObject *object in reviews) {
            NSLog(@"Object : %@", object);
            
            //Get friend review info
            friendID = [object objectForKey:@"userID"];
            friendRating = [object objectForKey:@"rating"];
            friendReview = [object objectForKey:@"review"];
            
            //Get friend user info
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"objectId" equalTo:friendID];
            NSArray *friendUserArray = [friendQuery findObjects];
            NSDictionary *friendUserDict = [friendUserArray firstObject];
            NSLog(@"Friend array: %@, Friend Dict: %@", friendUserArray, friendUserDict);
            NSString *friendUsername = [friendUserDict objectForKey:@"username"];
            UIImage *friendProfilePic = [UIImage imageWithData:[(PFFile *)friendUserDict[@"profile_pic"]getData]];
            
            friendReviewData = [[MovieClass alloc]init];
            friendReviewData.userID = friendID;
            friendReviewData.user_rating = friendRating;
            friendReviewData.user_review = friendReview;
            friendReviewData.username = friendUsername;
            friendReviewData.user_photo_file = friendProfilePic;
            friendReviewData.movie_TMDB_id = self.selectedMovie.movie_TMDB_id;
          //  friendReviewData.movie_title = movie_title;
          //  friendReviewData.movie_poster_file = movie_poster_image;
            
            [friendsReviews addObject:friendReviewData];
            [_friendsReviewsTable reloadData];
        }
    }];
    /*
    ///----COLLATING MOVIE RATINGS====///
    //get all ratings for this movie
    PFQuery *ratingsQuery = [PFQuery queryWithClassName:@"Reviews"];
    [ratingsQuery whereKey:@"movieID" equalTo:movieIDStr];
    
    [ratingsQuery findObjectsInBackgroundWithBlock:^(NSArray *reviews, NSError *error) {

        NSString *ratings = @"";
        NSNumber *ratingsNum;
        NSMutableArray *ratingsArray = [[NSMutableArray alloc]init];
        
        //get info about friends review
        for (PFObject *object in reviews) {
            
            ratings = [object objectForKey:@"rating"];
            
            //convert rating to a number so it can be added
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            nf.numberStyle = NSNumberFormatterDecimalStyle;
            ratingsNum = [nf numberFromString:ratings];
            [ratingsArray addObject:ratingsNum];
        }
        int ratingsInt = 0;
        
        //make sure there are at least 10 ratings to be more accurate
        if ([ratingsArray count] > 9) {
            
            //loop through ratings and add them together
            for (int i = 0; i < [ratingsArray count]; i++) {
                ratingsInt += [[ratingsArray objectAtIndex:i]intValue];
            }
            
            //divide for average and round result
            int ratingsTotal = (int)roundf(ratingsInt/[ratingsArray count]);
            NSLog(@"Rating total: %i, Average: %i", ratingsInt,ratingsTotal);
            
            //set stars
            switch (ratingsTotal) {
                case 1:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = emptyStar;
                    _totalStar3View.image = emptyStar;
                    _totalStar4View.image = emptyStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 2:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = emptyStar;
                    _totalStar4View.image = emptyStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 3:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = filledStar;
                    _totalStar4View.image = emptyStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 4:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = filledStar;
                    _totalStar4View.image = filledStar;
                    _totalStar5View.image = emptyStar;
                    break;
                case 5:
                    _totalStar1View.image = filledStar;
                    _totalStar2View.image = filledStar;
                    _totalStar3View.image = filledStar;
                    _totalStar4View.image = filledStar;
                    _totalStar5View.image = filledStar;
                    break;
                default:
                    break;
            }
            
        } else {
            //if not enough reviews, show not enough label
            [_notEnoughLabel setHidden:NO];
        }
    }];*/
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
//set heart image when clicked
-(void)clickedFavorite:(id)sender {
    
    UIImage *heart;
    
    //toggle heart image
    if ([toggle isEqualToString:@"0"]) {
       heart = [UIImage imageNamed:@"like_outline-48.png"];
        toggle = @"1";
    } else {
        heart = [UIImage imageNamed:@"hearts-48.png"];
        toggle = @"0";
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Reviews"];
    // Retrieve the object by id and update
    [query getObjectInBackgroundWithId:reviewId block:^(PFObject *updateReview, NSError *error) {
        
        updateReview[@"isFavorite"] =  [NSNumber numberWithBool:toggle];
        [updateReview saveInBackground];
    }];
    _heartImageView.image = heart;
}
//play movie trailer
-(void)clickedTariler:(id)sender {
    
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:self.selectedMovie.movie_trailer]];
    
    // Presents a MoviePlayerController with the youtube video
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videos objectForKey:@"medium"]]];
    [self presentViewController:mp animated:YES completion:nil];

}
//change star images based on which one was clicked
-(void)clickStar:(id)sender {
    UIImage *filledStar = [UIImage imageNamed:@"christmas_star-48.png"];
    UIImage *emptyStar = [UIImage imageNamed:@"outline_star-48.png"];
    
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
    PFQuery *query = [PFQuery queryWithClassName:@"Reviews"];
    
    // Retrieve the object by id and update
    [query getObjectInBackgroundWithId:reviewId block:^(PFObject *updateReview, NSError *error) {
        
        updateReview[@"rating"] =  numStars;
        [updateReview saveInBackground];
    }];
}
-(IBAction)clickedWantToSee:(id)sender {
    if (!isWantToSee) {
        [_wantToSeeButton setImage:[UIImage imageNamed:@"blueButton.png"] forState:UIControlStateNormal];
        isWantToSee = YES;
    } else {
        [_wantToSeeButton setImage:[UIImage imageNamed:@"grayButton.png"] forState:UIControlStateNormal];
        isWantToSee = NO;
    }
    
    if (userHasReviewed) {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Reviews"];
        
        // Retrieve the object by id and update
        [query getObjectInBackgroundWithId:reviewId block:^(PFObject *updateReview, NSError *error) {
            
            updateReview[@"isWantToSee"] =  [NSNumber numberWithBool:isWantToSee];
            [updateReview saveInBackground];
            
        }];
        
    } else {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"MMM dd, yyyy"];
        NSDate *date = [df dateFromString:self.selectedMovie.movie_date];
        NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", self.selectedMovie.movie_poster];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];
        
        PFObject *newWant = [PFObject objectWithClassName:@"Reviews"];
        newWant[@"isWantToSee"] =  [NSNumber numberWithBool:isWantToSee];
        newWant[@"userID"] = userId;
        newWant[@"movieID"] = [NSString stringWithFormat:@"%@", movie_id];
        newWant[@"moviePoster"] = imageFile;
        newWant[@"dateReleased"] = date;
        newWant[@"movieTitle"] = self.selectedMovie.movie_title;
        [newWant saveInBackground];
    }
    
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [friendsReviews count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
    MovieClass *tmpDict = [friendsReviews objectAtIndex:indexPath.row];
    if (cell != nil)
    {
        
        UILabel *reviewLabel = (UILabel *) [cell viewWithTag:8];
        reviewLabel.text = [tmpDict user_review];
        
        UIImageView *profilePicView = (UIImageView *) [cell viewWithTag:1];
        profilePicView.image = [tmpDict user_photo_file];
        
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:2];
        usernameLabel.text = [NSString stringWithFormat:@"%@ Rated:", [tmpDict username]];
        
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
        
        if ([[tmpDict user_rating] isEqual:@"1"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:emptyStar];
            star3Image = [UIImage imageNamed:emptyStar];
            star4Image = [UIImage imageNamed:emptyStar];
            star5Image = [UIImage imageNamed:emptyStar];
        } else if ([[tmpDict user_rating] isEqual:@"2"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:filledStar];
            star3Image = [UIImage imageNamed:emptyStar];
            star4Image = [UIImage imageNamed:emptyStar];
            star5Image = [UIImage imageNamed:emptyStar];
        } else if ([[tmpDict user_rating] isEqual:@"3"]) {
            star1Image = [UIImage imageNamed:filledStar];
            star2Image = [UIImage imageNamed:filledStar];
            star3Image = [UIImage imageNamed:filledStar];
            star4Image = [UIImage imageNamed:emptyStar];
            star5Image = [UIImage imageNamed:emptyStar];
            
        } else if ([[tmpDict user_rating] isEqual:@"4"]) {
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
//refresh view when coming back from write review
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    //[self refreshView];
    NSString *rating = self.selectedMovie.user_rating;
    NSString *review = self.selectedMovie.user_review;
    NSNumber *isFavorite = self.selectedMovie.user_is_fave;

    //check if favorite and set heart image accordingly
    if ([isFavorite intValue] == 1) {
        toggle = @"1";
        [self clickedFavorite:self];
    } else {
        toggle = @"0";
        [self clickedFavorite:self];
    }
    
    //set review text
    [_reviewView setText:review];
    
    //set button to grey since user reviewed movie
    [_wantToSeeButton setImage:[UIImage imageNamed:@"grayButton.png"] forState:UIControlStateNormal];
    
    //set star data
    int starsSaved = [rating intValue];
    UIImage *filledStar = [UIImage imageNamed:@"christmas_star-48.png"];
    UIImage *emptyStar = [UIImage imageNamed:@"outline_star-48.png"];
    
    //set stars based on reviews
    switch (starsSaved) {
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
//segue to write review and send movie object
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier]isEqualToString:@"review"]) {
        WriteReviewViewController *wrvc = [segue destinationViewController];
        wrvc.movieID = [NSString stringWithFormat:@"%@", movie_id];
        wrvc.moviePassed = self.selectedMovie;
    } else {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_friendsReviewsTable indexPathForCell:cell];
        
        NSString *movieTitleToPass = _movie_title_label.text;
        UIImage *moviePosterToPass = _poster_image.image;
        FriendReviewViewController *frvc = [segue destinationViewController];
        frvc.selectedReview = [friendsReviews objectAtIndex:indexPath.row];
        frvc.moviePosterPassed = moviePosterToPass;
        frvc.movieTitlePassed = movieTitleToPass;
        
    }
}


@end
