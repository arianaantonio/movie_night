//
//  WriteReviewViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "WriteReviewViewController.h"

@interface WriteReviewViewController ()

@end

@implementation WriteReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)clickStar:(id)sender {
    UIImage *filledStar = [UIImage imageNamed:@"star-48.png"];
    UIImage *emptyStar = [UIImage imageNamed:@"star-50.png"];
    
    switch ([sender tag]) {
        case 1:
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:emptyStar forState:UIControlStateNormal];
            [_star3Button setImage:emptyStar forState:UIControlStateNormal];
            [_star4Button setImage:emptyStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 2:
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:emptyStar forState:UIControlStateNormal];
            [_star4Button setImage:emptyStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 3:
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:filledStar forState:UIControlStateNormal];
            [_star4Button setImage:emptyStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 4:
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:filledStar forState:UIControlStateNormal];
            [_star4Button setImage:filledStar forState:UIControlStateNormal];
            [_star5Button setImage:emptyStar forState:UIControlStateNormal];
            break;
        case 5:
            [_star1Button setImage:filledStar forState:UIControlStateNormal];
            [_star2Button setImage:filledStar forState:UIControlStateNormal];
            [_star3Button setImage:filledStar forState:UIControlStateNormal];
            [_star4Button setImage:filledStar forState:UIControlStateNormal];
            [_star5Button setImage:filledStar forState:UIControlStateNormal];
            break;
        default:
            break;
    }
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
