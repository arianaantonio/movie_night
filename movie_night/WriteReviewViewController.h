//
//  WriteReviewViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"

@interface WriteReviewViewController : UIViewController
{
    NSString *numStars;
    NSString *toggle;
    BOOL isFave;
}

@property (nonatomic, strong) IBOutlet UIButton *star1Button;
@property (nonatomic, strong) IBOutlet UIButton *star2Button;
@property (nonatomic, strong) IBOutlet UIButton *star3Button;
@property (nonatomic, strong) IBOutlet UIButton *star4Button;
@property (nonatomic, strong) IBOutlet UIButton *star5Button;
@property (nonatomic, strong) IBOutlet UITextView *reviewView;
@property (nonatomic, strong) IBOutlet UIImageView *heartImageView;

@property (nonatomic, strong) NSString *movieID;
@property (nonatomic, strong) MovieClass *moviePassed;

-(IBAction)clickStar:(id)sender;
-(IBAction)clickedSave:(id)sender;
-(IBAction)clickedFavorite:(id)sender;

@end
