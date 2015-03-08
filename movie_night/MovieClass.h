//
//  MovieClass.h
//  movie_night
//
//  Created by Ariana Antonio on 2/15/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MovieClass : NSObject

@property (nonatomic, strong) NSString *movie_title;
@property (nonatomic, strong) NSString *movie_date;
@property (nonatomic, strong) NSString *movie_TMDB_id;
@property (nonatomic, strong) NSString *movie_poster;
@property (nonatomic, strong) NSString *movie_genre;
@property (nonatomic, strong) NSString *movie_imdb_id;
@property (nonatomic, strong) NSString *movie_plot_overview;
@property (nonatomic, strong) NSString *movie_director;
@property (nonatomic, strong) NSString *movie_trailer;
@property (nonatomic, strong) NSString *movie_cast;
@property (nonatomic, strong) NSString *global_rating;
@property (nonatomic, strong) NSString *user_rating;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *user_review;
@property (nonatomic, strong) NSString *user_photo;
@property (nonatomic, strong) UIImage *user_photo_file;
@property (nonatomic, strong) NSNumber *user_is_fave;
@property (nonatomic, strong) NSString *user_review_objectId;
@property (nonatomic, strong) UIImage *movie_poster_file;
@property (nonatomic, strong) NSString *userID;

@end
