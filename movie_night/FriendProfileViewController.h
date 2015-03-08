//
//  FriendProfileViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 3/6/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *movieArray;
    NSMutableArray *wantToSeeArray;
    NSMutableArray *favoritesArray;
    NSString *userId;
    NSArray *friendsArray;
    NSMutableArray *currentFriendsArray;
   // NSString *userId;
}

@property (nonatomic, strong) IBOutlet UITableView *listTableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *listSegment;
@property (nonatomic, strong) IBOutlet UINavigationItem *navBar;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profilePicView;
@property (nonatomic, strong) IBOutlet UIButton *followUserButton;
@property (nonatomic, strong) IBOutlet UIButton *followingButton;
@property (nonatomic, strong) IBOutlet UIButton *followersButton;
@property (nonatomic, strong) IBOutlet UILabel *reviewsCountLabel;
@property (nonatomic, strong) NSString *userIdPassed;

-(IBAction)segmentSelected:(id)sender;
-(IBAction)followUserClicked:(id)sender;


@end
