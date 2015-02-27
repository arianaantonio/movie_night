//
//  SettingsViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *settingsArray;
}

@property (nonatomic, strong) IBOutlet UITableView *settingsTable;

@end
