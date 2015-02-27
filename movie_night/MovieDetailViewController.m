//
//  MovieDetailViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/15/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "AppDelegate.h"

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*QuicksandDash-Regular
     Quicksand-Italic
     QuicksandDash-Regular
     Quicksand-LightItalic
     Quicksand-Light
     Quicksand-BoldItalic
     Quicksand-Bold
     Quicksand-Regular */
    
    // Do any additional setup after loading the view.
    
    toggle = @"";
   // NSLog(@"Selected: %@", self.selectedMovie.movie_title);
    self.navBar.title = self.selectedMovie.movie_title;
    
    NSString *movie_id = self.selectedMovie.movie_TMDB_id;
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
    
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/movie/%@?api_key=086941b3fdbf6f475d06a19773f6eb65&append_to_response=credits,videos", movie_id]];
        
        [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
            
            if (data != nil) {
                NSError *error;
                NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                self.selectedMovie.movie_imdb_id = [returnedDict objectForKey:@"imdb_id"];
                self.selectedMovie.movie_plot_overview = [returnedDict objectForKey:@"overview"];
                
               // NSLog(@"Cast: %@", [returnedDict objectForKey:@"credits"]);
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
                NSArray *genreArray = [returnedDict objectForKey:@"genres"];
                NSString *genreString = @"";
                if ([genreArray count] != 0) {
                    for (int i =0; i < [genreArray count]; i++) {
                        genreString = [genreString stringByAppendingString:[NSString stringWithFormat:@"%@, ", [[genreArray objectAtIndex:i]objectForKey:@"name"]]];
                    }
                }
                
                NSArray *videosArray = [[returnedDict objectForKey:@"videos"]objectForKey:@"results"];
                NSString *youTubeUrl = @"";
                for (int i =0; i < [videosArray count];i++) {
                    NSString *videoType = [[videosArray objectAtIndex:i]objectForKey:@"type"];
                    if ([videoType isEqualToString:@"Trailer"]) {
                        youTubeUrl = [[videosArray objectAtIndex:i]objectForKey:@"key"];
                    }
                }
                if ([youTubeUrl isEqualToString:@""]) {
                    [_trailerButton setHidden:YES];
                } else {
                    NSLog(@"YouTube Key: %@", youTubeUrl);
                    youTubeUrl = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", youTubeUrl];
                    self.selectedMovie.movie_trailer = youTubeUrl;
                }
                
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
                NSArray *movie_cast = [[NSArray alloc]initWithObjects:self.selectedMovie.movie_cast, nil];
                _cast_label.text = [NSString stringWithFormat:@"Starring: %@",[movie_cast componentsJoinedByString:@", "]];
                _cast_label.font = [UIFont fontWithName:@"Quicksand-Regular" size:14];
                
                NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", self.selectedMovie.movie_poster];
                UIImage *posterJPG = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
                _poster_image.image = posterJPG;
                //https://www.youtube.com/watch?v=SUXWAEX2jlg
                [self.view setNeedsDisplay];
                
            }
        }];
    }
    //https://www.youtube.com/watch?v=SUXWAEX2jlg
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Actions
-(void)clickedFavorite:(id)sender {
    
    UIImage *heart;
    
    if ([toggle isEqualToString:@"0"]) {
       heart = [UIImage imageNamed:@"like_outline-48.png"];
        toggle = @"1";
    } else {
        heart = [UIImage imageNamed:@"hearts-48.png"];
        toggle = @"0";
    }
    
    _heartImageView.image = heart;
    //[_favButton setImage:[UIImage imageNamed:@"hearts-48.png"] forState:UIControlStateNormal];
}
-(void)clickedTariler:(id)sender {
    
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:self.selectedMovie.movie_trailer]];
    
    // Presents a MoviePlayerController with the youtube quality medium
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videos objectForKey:@"medium"]]];
    [self presentModalViewController:mp animated:YES];
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell" forIndexPath:indexPath];
    //cell.textLabel.text = @"Titanic";
    //cell.detailTextLabel.text = @"Loved it!";
    return cell;
}
#pragma mark - Navigation
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"trailer"]) {
        TrailerViewController *detailViewController = segue.destinationViewController;
        
        if (detailViewController != nil) {
            
            detailViewController.trailerURL = self.selectedMovie.movie_trailer;
        }
    }

}


@end
