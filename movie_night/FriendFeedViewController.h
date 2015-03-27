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
#import "Reachability.h"

@interface FriendFeedViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *feedArray;
    UIView *refreshLoadingView;
    UIImageView *spinningIcon;
    BOOL isRefreshIconsOverlap;
    BOOL isRefreshAnimating;
    NSString *userId;
    Reachability *reachGoogle;
    NetworkStatus checkNetworkStatus;
}

@property (nonatomic, strong) IBOutlet UITableView *feedTableView;

@property (nonatomic, strong) NSString *browse;
-(void)checkForNewActivity;

@end
