//
//  ViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/14/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }*/
    
    movieSearchArray = [[NSMutableArray alloc]init];
    [_searchBar setDelegate:self];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_night_logo.png"]];

    /*
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/search/movie?api_key=086941b3fdbf6f475d06a19773f6eb65&query=%@", @"the+lord+of+the+rings"]];
    //http://api.themoviedb.org/3/search/movie?api_key=###&query=The+Hobbit:+The+Desolation+of+Smaug

    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        // Check if any data returned.
        if (data != nil) {
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           // NSLog(@"%@", returnedDict);
            NSArray *array = [returnedDict objectForKey:@"results"];
            for (int i = 0; i < [array count]; i++) {
                
                MovieClass *newMovie = [[MovieClass alloc]init];
                newMovie.movie_title = [[array objectAtIndex:i]objectForKey:@"title"];
                NSString *dateString = [[array objectAtIndex:i]objectForKey:@"release_date"];
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [df dateFromString:dateString];
                [df setDateFormat:@"MMM dd, yyyy"];
                dateString = [df stringFromDate:date];
                
                newMovie.movie_date = dateString;
                newMovie.movie_poster = [[array objectAtIndex:i]objectForKey:@"poster_path"];
                newMovie.movie_TMDB_id = [[array objectAtIndex:i]objectForKey:@"id"];
                
                [movieSearchArray addObject:newMovie];
                [_searchTable reloadData];
            }
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
    }];*/
}
#pragma mark  - API Call
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"Searched1: %@", [_searchBar text]);
    NSString *string = [_searchBar text];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/search/movie?api_key=086941b3fdbf6f475d06a19773f6eb65&query=%@", string]];
    
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {

        [movieSearchArray removeAllObjects];
        if (data != nil) {
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           // NSLog(@"%@", returnedDict);
            NSArray *array = [returnedDict objectForKey:@"results"];
           // NSLog(@"%@", array);
            for (int i = 0; i < [array count]; i++) {
          
                MovieClass *newMovie = [[MovieClass alloc]init];
                newMovie.movie_title = [[array objectAtIndex:i]objectForKey:@"title"];
                NSString *dateString = [[array objectAtIndex:i]objectForKey:@"release_date"];
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd"];
                NSDate *date = [df dateFromString:dateString];
                [df setDateFormat:@"MMM dd, yyyy"];
                dateString = [df stringFromDate:date];
            
                newMovie.movie_date = dateString;
                newMovie.movie_poster = [[array objectAtIndex:i]objectForKey:@"poster_path"];
                newMovie.movie_TMDB_id = [[array objectAtIndex:i]objectForKey:@"id"];
                
                [movieSearchArray addObject:newMovie];
            }
            [_searchTable reloadData];

            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }
    }];

}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [movieSearchArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    MovieClass *currentMovie = [movieSearchArray objectAtIndex:indexPath.row];
    if (cell != nil)
    {
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
        titleLabel.text = currentMovie.movie_title;
        UILabel *dateLabel = (UILabel *) [cell viewWithTag:3];
        dateLabel.text = currentMovie.movie_date;
        UIImageView *poster = (UIImageView *) [cell viewWithTag:4];
        //https://image.tmdb.org/t/p/w185/50LoR9gJhbWZ5PpoHgi8MNTYgzd.jpg
        NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", currentMovie.movie_poster];
        UIImage *posterJPG = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
        poster.image = posterJPG;

       return cell;
    }
    return nil;
}
-(IBAction)onMovieSelected:(id)sender {
   // NSLog(@"Selected movie: %@", [_searchTable ])
    [self performSegueWithIdentifier: @"MySegue" sender: self];
}
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MovieDetailViewController *detailViewController = segue.destinationViewController;
    
    if (detailViewController != nil) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_searchTable indexPathForCell:cell];
        
        MovieClass *currentMovie = [movieSearchArray objectAtIndex:indexPath.row];

        detailViewController.selectedMovie = currentMovie;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
