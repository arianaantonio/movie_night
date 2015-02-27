//
//  FriendFeedViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/16/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "FriendFeedViewController.h"

@interface FriendFeedViewController ()

@end

@implementation FriendFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_night_logo.png"]];
    
    MovieClass *friend1 = [[MovieClass alloc]init];
    friend1.username = @"lttl32";
    friend1.user_review = @"Really loved this movie";
    friend1.user_rating = @"5";
    friend1.movie_poster = @"gravity.jpg";
    friend1.movie_title = @"Gravity";
    friend1.user_photo = @"profilepic1.jpg";
    
    MovieClass *friend2 = [[MovieClass alloc]init];
    friend2.username = @"beccagirl";
    friend2.user_rating = @"2";
    friend2.user_photo = @"profilepic3.jpg";
    friend2.user_review = @"Not worth the price of the ticket";
    friend2.movie_title = @"Taken 3";
    friend2.movie_poster = @"taken3.jpg";
    
    MovieClass *friend3 = [[MovieClass alloc]init];
    friend3.username = @"jason33";
    friend3.user_rating = @"2";
    friend3.user_photo = @"profilepic2.jpg";
    friend3.user_review = @"Not great but not terrible either. Liam is fun.";
    friend3.movie_title = @"Non-Stop";
    friend3.movie_poster = @"nonstop.jpg";
    
    MovieClass *friend4 = [[MovieClass alloc]init];
    friend4.username = @"faeryqueen21";
    friend4.user_rating = @"3";
    friend4.user_photo = @"profilepic6.jpg";
    friend4.user_review = @"Not worth the price of the ticket";
    friend4.movie_title = @"Need For Speed";
    friend4.movie_poster = @"Need_For_Speed_New_Oficial_Poster_JPosters.jpg";
    
    MovieClass *friend5 = [[MovieClass alloc]init];
    friend5.username = @"ryanmovieguy";
    friend5.user_rating = @"5";
    friend5.user_photo = @"profilepic4.jpg";
    friend5.user_review = @"Loved it!! Great action flick with lots of intensity.";
    friend5.movie_title = @"Taken 3";
    friend5.movie_poster = @"taken3.jpg";
    
    MovieClass *friend6 = [[MovieClass alloc]init];
    friend6.username = @"beccagirl";
    friend6.user_rating = @"5";
    friend6.user_photo = @"profilepic3.jpg";
    friend6.user_review = @"Best movie ever! Can't get the music out of my head!";
    friend6.movie_title = @"Frozen";
    friend6.movie_poster = @"frozen.jpg";
    
    MovieClass *friend7 = [[MovieClass alloc]init];
    friend7.username = @"filmbuff24";
    friend7.user_rating = @"3";
    friend7.user_photo = @"profilepic5.jpg";
    friend7.user_review = @"Acting was good but found the movie a bit overrated. And what's with the fake baby?!";
    friend7.movie_title = @"Americna Sniper";
    friend7.movie_poster = @"americansniper.jpg";
    
    MovieClass *friend8 = [[MovieClass alloc]init];
    friend8.username = @"jason33";
    friend8.user_rating = @"4";
    friend8.user_photo = @"profilepic2.jpg";
    friend8.user_review = @"Really enjoyable movie and surpsingly funny! Left with a big smile on my face.";
    friend8.movie_title = @"The Lego Movie";
    friend8.movie_poster = @"the-lego-movie-poster-full-photo.jpg";
    
    MovieClass *friend9 = [[MovieClass alloc]init];
    friend9.username = @"faeryqueen21";
    friend9.user_rating = @"4";
    friend9.user_photo = @"profilepic6.jpg";
    friend9.user_review = @"Great movie with excellant acting but by the end I was really OVER drumming.";
    friend9.movie_title = @"Whiplash";
    friend9.movie_poster = @"whiplash.jpg";
    
    MovieClass *friend10 = [[MovieClass alloc]init];
    friend10.username = @"ryanmovieguy";
    friend10.user_rating = @"5";
    friend10.user_photo = @"profilepic5.jpg";
    friend10.user_review = @"Such a classic! One of my favorite movies ever.";
    friend10.movie_title = @"Back To The Future";
    friend10.movie_poster = @"back-to-the-future.jpg";
    
    feedArray = [[NSArray alloc]initWithObjects:friend1, friend10, friend2, friend3, friend4, friend5, friend6, friend7, friend8, friend9, nil];
    
    
    
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
        UIImage *posterImage = [UIImage imageNamed:currentMovie.movie_poster];
        posterView.image = posterImage;
        
        UILabel *titleLabel = (UILabel *) [cell viewWithTag:2];
        titleLabel.text = [NSString stringWithFormat:@"%@ rated %@:", currentMovie.username, currentMovie.movie_title];
        
        UIImageView *profilePicView = (UIImageView *) [cell viewWithTag:1];
        UIImage *picImage = [UIImage imageNamed:currentMovie.user_photo];
        profilePicView.image = picImage;
        
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
