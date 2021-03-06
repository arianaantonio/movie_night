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
@synthesize userData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    movieSearchArray = [[NSMutableArray alloc]init];
    usersArray = [[NSMutableArray alloc]init];
    [_searchBar setDelegate:self];
    [_searchBar resignFirstResponder];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_night_logo.png"]];
    
    //get now playing movies from API
    [self getNowPlaying];
}
//get now playing movies from API
-(void)getNowPlaying {
    
    //if search by movies is selected
    if ([_segmentControl selectedSegmentIndex] == 0) {
        //http://api.themoviedb.org/3/movie/now_playing
        NSURL *url = [NSURL URLWithString:@"http://api.themoviedb.org/3/movie/now_playing?api_key=086941b3fdbf6f475d06a19773f6eb65"];
        
        //query the API
        [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
            
            [movieSearchArray removeAllObjects];
            if (data != nil) {
                NSError *error;
                NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                // NSLog(@"%@", returnedDict);
                NSArray *array = [returnedDict objectForKey:@"results"];
                NSLog(@"Array: %@", array);
                
                for (int i = 0; i < [array count]; i++) {
                    
                    //set movies to object
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
                    
                    //add to array
                    [movieSearchArray addObject:newMovie];
                }
                [_searchTable reloadData];
                
                if (error != nil) {
                    NSLog(@"%@", [error localizedDescription]);
                }
            }
        }];
    }
}
#pragma mark  - API Call
//search based on which segment is selected
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [_searchBar resignFirstResponder];
    
    //search movies
    if ([_segmentControl selectedSegmentIndex] == 0) {
        [self searchMovies];
    }
    //search users
    else {
        [self searchUsers];
    }
}
//search movies API
-(void)searchMovies {
    
    //get movie searched
    [movieSearchArray removeAllObjects];
    [_searchBar resignFirstResponder];
    NSLog(@"Searched1: %@", [_searchBar text]);
    NSString *string = [_searchBar text];
    
    if (![string isEqualToString:@""]) {
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.themoviedb.org/3/search/movie?api_key=086941b3fdbf6f475d06a19773f6eb65&query=%@", string]];
    
    //query API for movie searched
    [AppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        
        [movieSearchArray removeAllObjects];
        
        if (data != nil) {
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            // NSLog(@"%@", returnedDict);
            NSArray *array = [returnedDict objectForKey:@"results"];
       
            //get movies returned and set to table
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
    } else {
        [self getNowPlaying];
    }
}
//search for users
-(void)searchUsers {
    
    //check if current user is following selected user
    PFQuery *currentUserQuery = [PFUser query];
    [currentUserQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    NSArray *returnedArray = [currentUserQuery findObjects];
    NSDictionary *userInfo = [returnedArray firstObject];
    NSMutableArray *currentFriendsArray = [[NSMutableArray alloc]init];
    currentFriendsArray = [userInfo objectForKey:@"friends"];
    
    [usersArray removeAllObjects];
    
    //get users that match username, full name, or email address
    NSString *userSearched = [_searchBar text];
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" equalTo:userSearched];
    
    PFQuery *emailQuery = [PFUser query];
    [emailQuery whereKey:@"email" equalTo:userSearched];
    
    PFQuery *fullNameQuery = [PFUser query];
    [fullNameQuery whereKey:@"full_name" containsString:userSearched];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[usernameQuery,emailQuery,fullNameQuery]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        
        if ([results count] > 0) {
            NSString *username = @"";
            NSString *userID = @"";
            UIImage *profilePic;
            NSString *fullName = @"";
            NSString *isFollowing = @"";
            
            for (int i = 0; i < [results count]; i++) {
                NSLog(@"Results: %@", [results objectAtIndex:i]);
                
                //set results to object and table
                NSDictionary *friendDict = [results objectAtIndex:i];
                username = [[results objectAtIndex:i]objectForKey:@"username"];
                userID = [[results objectAtIndex:i]objectId];
                profilePic = [[results objectAtIndex:i]objectForKey:@"profile_pic"];
                fullName = [[results objectAtIndex:i]objectForKey:@"full_name"];
                profilePic = [UIImage imageWithData:[(PFFile *)friendDict[@"profile_pic"]getData]];
                userData = [[MovieClass alloc]init];
                userData.username = username;
                userData.userID = userID;
                userData.user_photo_file = profilePic;
                userData.user_full_name = fullName;
                
                //if current user is already following returned user, set label to Following
                if ([currentFriendsArray containsObject:userID]) {
                    isFollowing = @"Following";
                } else {
                    isFollowing = @"";
                }
                userData.movie_date = isFollowing;
                
                [usersArray addObject:userData];
                [_searchTable reloadData];
            }
        }
    }];
    [_searchTable reloadData];
}
//search based on which segment is selected
-(void)segmentSelected:(id)sender {
    
    if ([_segmentControl selectedSegmentIndex] == 0) {
        [_searchBar setPlaceholder:@"Movie Title"];
        [self searchMovies];
    } else {
        [_searchBar setPlaceholder:@"Username, Email Address, Full Name"];
        [self searchUsers];
    }
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_segmentControl selectedSegmentIndex] == 0) {
    return [movieSearchArray count];
    } else {
       return [usersArray count];
    }
    return  [movieSearchArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"movieCell" forIndexPath:indexPath];
    MovieClass *currentMovie ;
    
    if (cell != nil)
    {
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
        UILabel *dateLabel = (UILabel *) [cell viewWithTag:3];
        UIImageView *poster = (UIImageView *) [cell viewWithTag:4];
        UIImage *posterJPG;
        
        if ([_segmentControl selectedSegmentIndex] == 0) {
            currentMovie = [movieSearchArray objectAtIndex:indexPath.row];
            titleLabel.text = currentMovie.movie_title;
            dateLabel.text = currentMovie.movie_date;
            //https://image.tmdb.org/t/p/w185/50LoR9gJhbWZ5PpoHgi8MNTYgzd.jpg
            NSString *posterURL = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w185%@", currentMovie.movie_poster];
            posterJPG = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:posterURL]]];
        } else {
            currentMovie = [usersArray objectAtIndex:indexPath.row];
            titleLabel.text = currentMovie.username;
            dateLabel.text = currentMovie.movie_date;
            posterJPG = currentMovie.user_photo_file;
        }
    
        poster.image = posterJPG;

       return cell;
    }
    return nil;
}
//one item selected in table, perform segue to appropriate screen
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_segmentControl selectedSegmentIndex] == 0) {
        
        [self performSegueWithIdentifier: @"MovieSegue" sender: self];
    } else {
        [self performSegueWithIdentifier:@"UserSegue" sender:self];
    }
}
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [_searchTable indexPathForSelectedRow];
    
    if ([_segmentControl selectedSegmentIndex] == 0) {
        MovieDetailViewController *detailViewController = segue.destinationViewController;
        
        if (detailViewController != nil) {
            
            MovieClass *currentMovie = [movieSearchArray objectAtIndex:indexPath.row];
            detailViewController.selectedMovie = currentMovie;
        }
    } else {
        FriendProfileViewController *fpvc = segue.destinationViewController;
        
        if (fpvc != nil) {

            MovieClass *currentMovie = [usersArray objectAtIndex:indexPath.row];
            
            fpvc.userIdPassed = currentMovie.userID;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
