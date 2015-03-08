//
//  WhereFriendsViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/4/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "WhereFriendsViewController.h"
#import "AddFriendsFromSettingsViewController.h"

@interface WhereFriendsViewController ()

@end

@implementation WhereFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier]isEqualToString:@"addFriends"]) {
        AddFriendsFromSettingsViewController *affsvc = [segue destinationViewController];
        
        if ([sender tag] ==1) {
            affsvc.searchType = @"contacts";
        } else {
            affsvc.searchType = @"facebook";
        }
    } else {
        
    }
    
}
-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {

}

@end
