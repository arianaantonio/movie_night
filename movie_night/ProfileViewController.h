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

@interface ProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *movieArray;
    NSMutableArray *wantToSeeArray;
    NSMutableArray *favoritesArray;
    NSString *userId;
    NSArray *friendsArray;
}

@property (nonatomic, strong) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *listSegment;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, strong) IBOutlet UINavigationItem *navBar;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profilePicView;
@property (nonatomic, strong) IBOutlet UIButton *uploadPhoto;
@property (nonatomic, strong) IBOutlet UIButton *followingButton;
@property (nonatomic, strong) IBOutlet UIButton *followersButton;
//@property (nonatomic, strong) IBOutlet UILabel *friendsCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *reviewsCountLabel;

-(IBAction)segmentSelected:(id)sender;
-(IBAction)logoutButtonAction:(id)sender;
-(IBAction)uploadPhoto:(id)sender;

@end
