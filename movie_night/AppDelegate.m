//
//  AppDelegate.m
//  movie_night
//
//  Created by Ariana Antonio on 2/14/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "FriendFeedViewController.h"
#import "FriendReviewViewController.h"
//#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //set up parse for application
    [Parse setApplicationId:@"IASTyOSCs3IoFTnmNU7JcBQ4ZoDzTVb1ESK8jwSW"
                  clientKey:@"FvfYcrED2qanfxBb7XE87BXGiWquIW2iJvZKORFj"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //check if logged in an navigate accordingly
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
    } else {
        // show the signup or login screen
        self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    }
    
    newLaunchingOptions = launchOptions;
    
    //set up notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if ([currentInstallation objectForKey:@"user"] == nil && currentUser) {
        [currentInstallation setObject:currentUser forKey:@"user"];
        currentInstallation.channels = @[currentUser.objectId];
    }
    
    //handle app opening from push notification
    [self handlePush:launchOptions];
    
    return YES;
}
//setup current device in parse
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFUser *currentUser = [PFUser currentUser];
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    if (currentUser == nil) {
        currentInstallation.channels = @[@"global"];
    } else {
        currentInstallation.channels = @[@"global", currentUser.objectId];
    }
    [currentInstallation saveInBackground];
}
//handle notification while app is in use
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [[PFFacebookUtils session] close];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //reset any badge notifications
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

+(void)downloadDataFromURL:(NSURL *)url withCompletionHandler:(void (^)(NSData *))completionHandler{
    // Instantiate a session configuration object.
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Instantiate a session object.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    // Create a data task object to perform the data downloading.
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error != nil) {
            // If any error occurs then just display its description on the console.
            NSLog(@"%@", [error localizedDescription]);
        }
        else{
            // If no error occurs, check the HTTP status code.
            NSInteger HTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
            
            // If it's other than 200, then show it on the console.
            if (HTTPStatusCode != 200) {
                NSLog(@"HTTP status code = %ld", (long)HTTPStatusCode);
            }
            
            // Call the completion handler with the returned data on the main thread.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionHandler(data);
            }];
        }
    }];
    
    // Resume the task.
    [task resume];
}
//handle app being opened from a push notification
- (void)handlePush:(NSDictionary *)launchOptions {
    
    //get notification info
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Make sure our user and data are good
    if (remoteNotificationPayload && [PFUser currentUser]) {
        NSString *string = [NSString stringWithFormat:@"Disct: %@", remoteNotificationPayload];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Qlert" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        //transition to review view
        NSString *activityObjectId = [remoteNotificationPayload objectForKey:@"rid"];
        
        UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"Qlert" message:activityObjectId delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert2 show];
        if (activityObjectId && activityObjectId.length != 0) {
            PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
            [query getObjectInBackgroundWithId:activityObjectId block:^(PFObject *review, NSError *error) {
                if (!error) {
                    NSString *reviewId = [review objectForKey:@"reviewId"];
                    FriendReviewViewController *detailViewController = [FriendReviewViewController alloc];
                    detailViewController.selectedReview.user_review_objectId = reviewId;
                    
                    UINavigationController *homeNavigationController = [[self.tabBarController viewControllers] objectAtIndex:0];
                    [self.tabBarController setSelectedViewController:homeNavigationController];
                    [homeNavigationController pushViewController:detailViewController animated:YES];
                }
            }];
        }
    }
}
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils session];
}
@end
