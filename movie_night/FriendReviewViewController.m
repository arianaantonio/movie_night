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
@synthesize scrollView, commentField;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    commentArray = [[NSMutableArray alloc]init];
    [commentField setDelegate:self];
    [self registerForKeyboardNotifications];
    
    
    UIImage *profilePicImage = self.selectedReview.user_photo_file;
    _profilePic.image = profilePicImage;
    
    UIImage *posterImage = self.selectedReview.movie_poster_file;
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
//set up textfield so return button closes keyboard
-(BOOL)textFieldShouldReturn:(UITextField*)textField {

    [textField resignFirstResponder];
    return NO;
}
//register keyboard to receive notifications
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}
//call when keyboard is shown
- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    //scroll view to bottem field so keyboard doesn't hide it
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if (!CGRectContainsPoint(aRect, commentField.frame.origin) ) {
        
        [self.scrollView scrollRectToVisible:commentField.frame animated:YES];
    }
}
//when keyboard is hidden
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    //sroll view down when keyboard is hidden to regular dimensions
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}
-(void)onPostComment:(id)sender {
    NSString *comment = [commentField text];
    NSDictionary *commentDict = [NSDictionary dictionaryWithObjectsAndKeys:comment, @"comment", nil];
    [commentArray addObject:commentDict];
    [_commentTable reloadData];
    [commentField setText:@""];
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
