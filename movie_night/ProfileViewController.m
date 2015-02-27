//
//  ProfileViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/16/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize settingsButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"segmentedControl: %@", _listSegment);
    
    SWRevealViewController *revealViewController = self.revealViewController;
    
    if (revealViewController) {
        //_settingsButton.target = self.revealViewController;
        //_settingsButton.action = @selector(revealToggle:);
    
       
        [self.settingsButton setTarget: self.revealViewController];
        [self.settingsButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    MovieClass *movie1 = [[MovieClass alloc] init];
    movie1.movie_title = @"Birdman";
    movie1.user_rating = @"5";
    movie1.movie_poster = @"birdman.jpg";
    movie1.movie_date = @"Dec 12, 2015";
    movie1.movie_director = @"Alejandro Inarritu";
    movie1.movie_cast = @"Michael Keaton";
    movie1.movie_plot_overview = @"A faded actor tries to reclaim industry respect by launching a Broadway play";
    
    MovieClass *movie2 = [[MovieClass alloc]init];
    movie2.movie_title = @"Whiplash";
    movie2.user_rating = @"4";
    movie2.movie_poster = @"whiplash.jpg";
    movie2.movie_date = @"Nov 23, 2014";
    movie2.movie_cast = @"J.K. Simmons";
    movie2.movie_plot_overview = @"A young drummer at a prestigeous conservatory tries to impress his difficult band leader";
    movie2.movie_director = @"Damian Chazelle";
    
    MovieClass *movie3 = [[MovieClass alloc]init];
    movie3.movie_title = @"Taken 3";
    movie3.user_rating = @"2";
    movie3.movie_poster = @"taken3.jpg";
    movie3.movie_date = @"Aug 14, 2014";
    movie3.movie_cast = @"Liam Nesson";
    movie3.movie_director = @"Olivier Megaton";
    movie3.movie_plot_overview = @"In this sequal Bryan is on the run after he is blamed for his wife's death";
    
    MovieClass *movie4 = [[MovieClass alloc]init];
    movie4.movie_title = @"American Sniper";
    movie4.user_rating = @"3";
    movie4.movie_poster = @"americansniper.jpg";
    movie4.movie_date = @"Dec 25, 2014";
    movie4.movie_plot_overview = @"Based on the book by Chris Kyle about his time as a sniper";
    movie4.movie_cast = @"Bradley Cooper";
    movie4.movie_director = @"Clint Eastwood";
    
    MovieClass *movie5 = [[MovieClass alloc]init];
    movie5.movie_title = @"Selma";
    movie5.user_rating = @"5";
    movie5.movie_poster = @"selma.jpg";
    movie5.movie_date = @"Dec 28, 2014";
    movie5.movie_director = @"Ava DuVernay";
    movie5.movie_cast = @"David Oyelowo";
    movie5.movie_plot_overview = @"Based on the true events surrounding the civil rights march from Selma";
    
    MovieClass *movie6 = [[MovieClass alloc]init];
    movie6.movie_title = @"Need for Speed";
    movie6.user_rating = @"1";
    movie6.movie_poster = @"Need_For_Speed_New_Oficial_Poster_JPosters.jpg";
    movie6.movie_date = @"Mar 12, 2014";
    movie6.movie_cast = @"Aaron Paul";
    movie6.movie_director = @"Scott Waugh";
    movie6.movie_plot_overview = @"An ex-racer fresh out of jail seeks to redeem himself in a high stakes race";
    
    MovieClass *movie7 = [[MovieClass alloc]init];
    movie7.movie_title = @"Back To The Future";
    movie7.user_rating = @"5";
    movie7.movie_poster = @"back-to-the-future.jpg";
    movie7.movie_date = @"Jun 22, 1985";
    movie7.movie_plot_overview = @"A young time traveler finds himself stranded in 1955 and he much make sure his parents get together to return to the future";
    movie7.movie_cast = @"Michael J Fox";
    movie7.movie_director = @"Robert Zemekis";
    
    MovieClass *movie8 = [[MovieClass alloc]init];
    movie8.movie_title = @"Gravity";
    movie8.user_rating = @"5";
    movie8.movie_poster = @"gravity.jpg";
    movie8.movie_date = @"Jul 12, 2013";
    movie8.movie_director = @"Alfonso Cuaron";
    movie8.movie_cast = @"Sandra Bullock";
    movie8.movie_plot_overview = @"When satellite depris destroys the space shuttle a stranded astronaut must survive in the cold of space";
    
    MovieClass *movie9 = [[MovieClass alloc]init];
    movie9.movie_title = @"Frozen";
    movie9.user_rating = @"4";
    movie9.movie_poster = @"frozen.jpg";
    movie9.movie_date = @"Nov 18, 2013";
    movie9.movie_cast = @"Kristen Bell";
    movie9.movie_plot_overview = @"A Disney classic about two sisters trying to find happiness when one has magical powers";
    movie9.movie_director = @"Chris Buck, Jennifer Lee";
    
    MovieClass *movie10 = [[MovieClass alloc]init];
    movie10.movie_title = @"The Lego Movie";
    movie10.user_rating = @"5";
    movie10.movie_poster = @"the-lego-movie-poster-full-photo.jpg";
    movie10.movie_date = @"Feb 12, 2014";
    movie10.movie_cast = @"Chris Pratt";
    movie10.movie_plot_overview = @"An all Lego animated movie about finding yourself in a big and complicated world";
    movie10.movie_director = @"Phil Lord";
    
    movieArray = [[NSMutableArray alloc]initWithObjects:movie1, movie2, movie3, movie4, movie5, movie6, movie7, movie8, movie9, movie10, nil];
    
    favoritesArray = [[NSMutableArray alloc]initWithObjects:movie9, movie6, movie1, movie8, movie2, movie4, movie10, movie5, movie3, movie7, nil];
    
    wantToSeeArray = [[NSMutableArray alloc]initWithObjects:movie3, movie9, movie6, movie10, movie2, movie8, movie4, movie7, movie5, movie1, nil];
    
    
}
-(void)segmentSelected:(id)sender {
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
        NSString *filledStar = @"star-48.png";
        NSString *emptyStar = @"star-50.png";
        
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
        UIImage *posterImage = [UIImage imageNamed:currentMovie.movie_poster];
        posterView.image = posterImage;
        
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
        titleLabel.text = currentMovie.movie_title;
        
        return cell;
    }
    return nil;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

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
}

@end
