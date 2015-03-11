//
//  MovieDetailViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/15/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"
#import "HCYoutubeParser.h"



@interface MovieDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString *numStars;
    NSString *toggle;
    BOOL isFave;
    NSString *userId;
    NSString *movie_id;
    NSMutableArray *friendsReviews;
    MovieClass *friendReviewData;
    NSString *movie_title;
    UIImage *movie_poster_image;
    BOOL userHasReviewed;
    BOOL isWantToSee;
    NSString *reviewId;
}

@property (nonatomic, strong) IBOutlet UILabel *movie_title_label;
@property (nonatomic, strong) IBOutlet MovieClass *selectedMovie;
@property (nonatomic, strong) IBOutlet NSString *passed_movie_id;
@property (nonatomic, strong) IBOutlet UILabel *date_label;
@property (nonatomic, strong) IBOutlet UILabel *cast_label;
@property (nonatomic, strong) IBOutlet UILabel *director_label;
@property (nonatomic, strong) IBOutlet UITextView *plot_label;
@property (nonatomic, strong) IBOutlet UITextView *reviewView;
@property (nonatomic, strong) IBOutlet UILabel *genre_label;
@property (nonatomic, strong) IBOutlet UIImageView *poster_image;
@property (nonatomic, strong) IBOutlet UINavigationItem *navBar;
@property (nonatomic, strong) IBOutlet UITableView *friendsReviewsTable;
@property (nonatomic, strong) IBOutlet UIButton *trailerButton;
@property (nonatomic, strong) IBOutlet UIButton *favButton;
@property (nonatomic, strong) IBOutlet UIImageView *heartImageView;
@property (nonatomic, strong) IBOutlet UIButton *star1Button;
@property (nonatomic, strong) IBOutlet UIButton *star2Button;
@property (nonatomic, strong) IBOutlet UIButton *star3Button;
@property (nonatomic, strong) IBOutlet UIButton *star4Button;
@property (nonatomic, strong) IBOutlet UIButton *star5Button;
@property (nonatomic, strong) IBOutlet UIButton *wantToSeeButton;
@property (nonatomic, strong) IBOutlet UIImageView *totalStar1View;
@property (nonatomic, strong) IBOutlet UIImageView *totalStar2View;
@property (nonatomic, strong) IBOutlet UIImageView *totalStar3View;
@property (nonatomic, strong) IBOutlet UIImageView *totalStar4View;
@property (nonatomic, strong) IBOutlet UIImageView *totalStar5View;
@property (nonatomic, strong) IBOutlet UILabel *notEnoughLabel;


-(IBAction)clickedFavorite:(id)sender;
-(IBAction)clickedTariler:(id)sender;
-(IBAction)clickedWantToSee:(id)sender;

@end
