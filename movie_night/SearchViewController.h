//
//  ViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/14/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MovieClass.h"
#import "MovieDetailViewController.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *movieSearchArray;
}
@property (nonatomic, strong) IBOutlet UIImageView *tablePoster;
@property (nonatomic, strong) IBOutlet UILabel *tableTitle;
@property (nonatomic, strong) IBOutlet UILabel *tableDate;
@property (nonatomic, strong) IBOutlet UITableView *searchTable;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

//-(IBAction)onSearch:(id)sender;
-(IBAction)onMovieSelected:(id)sender;
@end

