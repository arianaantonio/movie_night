//
//  FriendFeedViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/16/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"
#import "FriendReviewViewController.h"

@interface FriendFeedViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *feedArray;
    UIView *refreshLoadingView;
    UIView *refreshColorView;
    UIImageView *compass_spinner;
    BOOL isRefreshIconsOverlap;
    BOOL isRefreshAnimating;
}

@property (nonatomic, strong) IBOutlet UITableView *feedTableView;

@property (nonatomic, strong) NSString *browse;

@end
