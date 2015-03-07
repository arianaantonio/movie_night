//
//  AddFriendsFromSettingsViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 3/4/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendsFromSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *friendsArray;
    NSMutableArray *toAddArray;
    NSDictionary *personObject;
    NSString *currentUserId;
}


@property (nonatomic, strong) IBOutlet UITableView *friendsTable;
@property (nonatomic, strong) IBOutlet NSString *searchType;

-(IBAction)addContacts:(id)sender;

@end
