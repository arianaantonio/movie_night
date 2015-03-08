//
//  SearchUsersViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 3/7/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"

@interface SearchUsersViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UISearchBarDelegate>
{
    NSMutableArray *usersArray;
    NSMutableArray *toAddArray;
}

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *userTable;
@property (nonatomic, strong) MovieClass *userData;

-(IBAction)addUser:(id)sender;
-(IBAction)clickedDone:(id)sender;

@end
