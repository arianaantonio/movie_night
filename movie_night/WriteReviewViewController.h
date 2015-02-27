//
//  WriteReviewViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriteReviewViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *star1Button;
@property (nonatomic, strong) IBOutlet UIButton *star2Button;
@property (nonatomic, strong) IBOutlet UIButton *star3Button;
@property (nonatomic, strong) IBOutlet UIButton *star4Button;
@property (nonatomic, strong) IBOutlet UIButton *star5Button;

-(IBAction)clickStar:(id)sender;
@end
