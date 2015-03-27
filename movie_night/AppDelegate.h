//
//  AppDelegate.h
//  movie_night
//
//  Created by Ariana Antonio on 2/14/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h> 
#import "FriendFeedViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSDictionary *newLaunchingOptions;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) FriendFeedViewController *friendFeedVC;


+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void(^)(NSData *data))completionHandler;

@end

