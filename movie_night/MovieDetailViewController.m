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

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set default values for toggling favorites
    toggle = @"1";
    isFave = NO;
    
    [self refreshView];
}
-(void)refreshView {
    self.navBar.title = self.selectedMovie.movie_title;
    
    //set movie id
    movie_id = self.selectedMovie.movie_TMDB_id;
    
    
    if (movie_id == nil) {
        [_trailerButton setHidden:YES];
        UIImage *posterJPG = [UIImage imageNamed:self.selectedMovie.movie_poster];
        _poster_image.image = posterJPG;
        _movie_title_label.text = self.selectedMovie.movie_title;
        _plot_label.text = self.selectedMovie.movie_plot_overview;
        _director_label.text = [NSString stringWithFormat:@"Directed By: %@", self.selectedMovie.movie_director];
        _cast_label.text = [NSString stringWithFormat:@"Starring: %@",self.selectedMovie.movie_cast];
        _date_label.text = self.selectedMovie.movie_date;
        
    } else {
        
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
                _movie_title_label.font = [UIFont fontWithName:@"Quicksand-Bold" size:16];
                _plot_label.text = self.selectedMovie.movie_plot_overview;
                _plot_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                _genre_label.text = genreString;
                _genre_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                _date_label.text = self.selectedMovie.movie_date;
                _date_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                _director_label.text = [NSString stringWithFormat:@"Directed By: %@", self.selectedMovie.movie_director];
                _director_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                
                //join cast names array into string and set to label
                NSArray *movie_cast = [[NSArray alloc]initWithObjects:self.selectedMovie.movie_cast, nil];
                _cast_label.text = [NSString stringWithFormat:@"Starring: %@",[movie_cast componentsJoinedByString:@", "]];
                _cast_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                
                //get poster url and set to imageview
                NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", self.selectedMovie.movie_poster];
                UIImage *posterJPG = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
                _poster_image.image = posterJPG;
                //https://www.youtube.com/watch?v=SUXWAEX2jlg
                [self.view setNeedsDisplay];
                
            }
        }];
    }
    //check if user has left info for this movie
    PFUser *currentUser = [PFUser currentUser];
    NSString *userId = currentUser.objectId;
    NSString *movieIDStr = [NSString stringWithFormat:@"%@", movie_id];
    NSLog(@"User: %@, Movie: %@", userId, movie_id);
    [_reviewView setText:@"Review"];
    
    //query parse for movie data
    PFQuery *query2 = [PFQuery queryWithClassName:@"Reviews"];
    [query2 whereKey:@"userID" equalTo:userId];
    [query2 whereKey:@"movieID" equalTo:movieIDStr];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            NSString *rating = @"";
            NSString *review = @"";
            NSNumber *isFavorite;
            
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                
                //get object data returned
                rating = [object objectForKey:@"rating"];
                review = [object objectForKey:@"review"];
                isFavorite = [object objectForKey:@"isFavorite"];
                
                //check if favorite and set heart image accordingly
                if (isFavorite) {
                    toggle = @"0";
                    [self clickedFavorite:self];
                } else {
                    toggle = @"1";
                    [self clickedFavorite:self];
                }
                
                //set review text
                [_reviewView setText:review];
                
                //set star data
                int starsSaved = [rating intValue];
                UIImage *filledStar = [UIImage imageNamed:@"star-48.png"];
                UIImage *emptyStar = [UIImage imageNamed:@"star-50.png"];
                
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
                self.selectedMovie.user_review_objectId = object.objectId;
            }
        }
    }];
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

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
    return cell;
}
#pragma mark - Navigation
//refresh view when coming back from write review
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    [self refreshView];
}
//segue to write review and send movie object
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    WriteReviewViewController *wrvc = [segue destinationViewController];
    wrvc.movieID = movie_id;
    wrvc.moviePassed = self.selectedMovie;
}


@end
