//
//  MovieDetailViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/15/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"
#import "TrailerViewController.h"

@interface MovieDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSString *toggle;
}

@property (nonatomic, strong) IBOutlet UILabel *movie_title_label;
@property (nonatomic, strong) IBOutlet MovieClass *selectedMovie;
@property (nonatomic, strong) IBOutlet UILabel *date_label;
@property (nonatomic, strong) IBOutlet UILabel *cast_label;
@property (nonatomic, strong) IBOutlet UILabel *director_label;
@property (nonatomic, strong) IBOutlet UITextView *plot_label;
@property (nonatomic, strong) IBOutlet UILabel *genre_label;
@property (nonatomic, strong) IBOutlet UIImageView *poster_image;
@property (nonatomic, strong) IBOutlet UINavigationItem *navBar;
@property (nonatomic, strong) IBOutlet UITableView *friendsReviewsTable;
@property (nonatomic, strong) IBOutlet UIButton *trailerButton;
@property (nonatomic, strong) IBOutlet UIButton *favButton;
@property (nonatomic, strong) IBOutlet UIImageView *heartImageView;

-(IBAction)clickedFavorite:(id)sender;
-(IBAction)clickedTariler:(id)sender;

@end
