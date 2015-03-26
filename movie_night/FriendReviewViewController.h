//
//  FriendReviewViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/23/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"

@interface FriendReviewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *commentArray;
    NSMutableArray *likesArray;
    NSString *reviewId;
    NSString *userId;
    NSString *commenterId;
    NSString *username;
    UIImage *userImage;
    NSString *reviewerUsername;
    NSString *reviewerUserId;
}

@property (nonatomic, strong) MovieClass *selectedReview;
@property (nonatomic, strong) IBOutlet UIImageView *profilePic;
@property (nonatomic, strong) IBOutlet UIImageView *posterView;
@property (nonatomic, strong) IBOutlet UIImageView *star1;
@property (nonatomic, strong) IBOutlet UIImageView *star2;
@property (nonatomic, strong) IBOutlet UIImageView *star3;
@property (nonatomic, strong) IBOutlet UIImageView *star4;
@property (nonatomic, strong) IBOutlet UIImageView *star5;
@property (nonatomic, strong) IBOutlet UIButton *usernameButton;
@property (nonatomic, strong) IBOutlet UIButton *movieTitleButton;
@property (nonatomic, strong) IBOutlet UITextView *reviewField;
@property (nonatomic, strong) IBOutlet UITextField *commentField;
@property (nonatomic, strong) IBOutlet UITableView *commentTable;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSString *movieTitlePassed;
@property (nonatomic, strong) UIImage *moviePosterPassed;
@property (nonatomic, strong) IBOutlet UILabel *likesLabel;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;

@property (nonatomic, strong) NSString *browse;

-(IBAction)onPostComment:(id)sender;

@end
