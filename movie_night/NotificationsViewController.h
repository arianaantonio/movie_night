//
//  NotificationsViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 3/10/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieClass.h"

@interface NotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *notifArray;
    NSString *userId;
    MovieClass *activityUser;
}

@property (nonatomic, strong) IBOutlet UITableView *notifTable;

@end
