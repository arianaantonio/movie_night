//
//  ProfileViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/16/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"
#import "MovieDetailViewController.h"
#import "SWRevealViewController.h"

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *movieArray;
    NSMutableArray *wantToSeeArray;
    NSMutableArray *favoritesArray;
}

@property (nonatomic, strong) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *listSegment;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *settingsButton;

-(IBAction)segmentSelected:(id)sender;

@end
