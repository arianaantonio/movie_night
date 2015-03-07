//
//  AddContactsViewController.h
//  movie_night
//
//  Created by Ariana Antonio on 3/3/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary *personObject;
    NSMutableArray *contactArray;
    NSString *currentUserId;
    NSMutableArray *toAddArray;
}

@property (nonatomic, strong) IBOutlet UITableView *contactsTable;
@property (nonatomic, strong) IBOutlet UIButton *addButton;


-(IBAction)addContacts:(id)sender;
-(IBAction)clickedDone:(id)sender;

@end

