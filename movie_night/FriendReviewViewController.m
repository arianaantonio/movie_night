//
//  FriendReviewViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/23/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "FriendReviewViewController.h"

@interface FriendReviewViewController ()

@end

@implementation FriendReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    commentArray = [[NSMutableArray alloc]init];
    
    UIImage *profilePicImage = [UIImage imageNamed:self.selectedReview.user_photo];
    _profilePic.image = profilePicImage;
    
    UIImage *posterImage = [UIImage imageNamed:self.selectedReview.movie_poster];
    _posterView.image = posterImage;
    
    _titleLabel.text = [NSString stringWithFormat:@"%@ has rated %@:", self.selectedReview.username, self.selectedReview.movie_title];
    
    _reviewField.text = self.selectedReview.user_review;
    
    NSString *rating = self.selectedReview.user_rating;
    
    NSString *filledStar = @"star-48.png";
    NSString *emptyStar = @"star-50.png";
    
    UIImage *star1Image;
    UIImage *star2Image;
    UIImage *star3Image;
    UIImage *star4Image;
    UIImage *star5Image;
    
    if ([rating isEqual:@"1"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:emptyStar];
        star3Image = [UIImage imageNamed:emptyStar];
        star4Image = [UIImage imageNamed:emptyStar];
        star5Image = [UIImage imageNamed:emptyStar];
    } else if ([rating isEqual:@"2"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:filledStar];
        star3Image = [UIImage imageNamed:emptyStar];
        star4Image = [UIImage imageNamed:emptyStar];
        star5Image = [UIImage imageNamed:emptyStar];
    } else if ([rating isEqual:@"3"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:filledStar];
        star3Image = [UIImage imageNamed:filledStar];
        star4Image = [UIImage imageNamed:emptyStar];
        star5Image = [UIImage imageNamed:emptyStar];
        
    } else if ([rating isEqual:@"4"]) {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:filledStar];
        star3Image = [UIImage imageNamed:filledStar];
        star4Image = [UIImage imageNamed:filledStar];
        star5Image = [UIImage imageNamed:emptyStar];
        
    } else {
        star1Image = [UIImage imageNamed:filledStar];
        star2Image = [UIImage imageNamed:filledStar];
        star3Image = [UIImage imageNamed:filledStar];
        star4Image = [UIImage imageNamed:filledStar];
        star5Image = [UIImage imageNamed:filledStar];
    }
    _star1.image = star1Image;
    _star2.image = star2Image;
    _star3.image = star3Image;
    _star4.image = star4Image;
    _star5.image = star5Image;
    
    
    
}
-(void)onPostComment:(id)sender {
    NSString *comment = [_commentField text];
    NSDictionary *commentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil];
    [commentArray addObject:commentDict];
    [_commentTable reloadData];
    [_commentField setText:@""];
}
#pragma mark TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [commentArray count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
    
    NSDictionary *commentDict = [commentArray objectAtIndex:indexPath.row];
    
    if (cell != nil) {
        
        UIImageView *profilePicView = (UIImageView *) [cell viewWithTag:1];
        UIImage *profileImage = [UIImage imageNamed:@"profilepic6.jpg"];
        profilePicView.image = profileImage;
        
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:2];
        nameLabel.text = @"templepilot17 said:";
        
        UILabel *commentLabel = (UILabel *) [cell viewWithTag:3];
        commentLabel.text = [commentDict objectForKey:@"comment"];

        return cell;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
