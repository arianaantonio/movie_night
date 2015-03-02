//
//  SettingsViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 2/25/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    settingsArray = [[NSArray alloc]initWithObjects:@"Change Profile Picture", @"Change Username", @"Change Full Name", @"Add Friends From Facebook", @"Add Friends From Contacts", nil];
    [_settingsTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)logoutButtonAction:(id)sender  {
    

    NSIndexPath *selectedIndexPath = [_settingsTable indexPathForSelectedRow];
    NSLog(@"Row: %@", selectedIndexPath);
    

    [PFUser logOut]; 
    
    [self performSegueWithIdentifier:@"loginSegue" sender:self];
    // Return to Login view controller
    //LoginViewController *lvc = [[LoginViewController alloc]init];
    //[self presentViewController:lvc animated:YES completion:nil];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark  - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [settingsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell" forIndexPath:indexPath];
    
    if (cell != nil) {
        
        cell.textLabel.text = [settingsArray objectAtIndex:indexPath.row];
        
        return cell;
    }
    return nil;
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
