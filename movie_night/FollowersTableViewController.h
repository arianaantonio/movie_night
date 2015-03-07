//
//  FollowersTableViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 3/6/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowersTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *followersArray;
}

@property (nonatomic, strong) IBOutlet UITableView *followersTable;
@end
