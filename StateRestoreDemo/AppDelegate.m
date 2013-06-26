//
//  AppDelegate.m
//  StateRestoreDemo
//
//  Created by zhang kun on 6/26/13.
//  Copyright (c) 2013 zhang kun. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)commonInitialization:(NSDictionary *)launchOptions
{
    // GCD will ensure it gets called once no mater what version of iOS we are running,
    // so in iOS 6.0 or later this will not get called twice from both delegate methods
    //
    static dispatch_once_t pred;
    dispatch_once(&pred, ^ {
        
        // perform common initialization code here
        //..
        
        // require the window being visible before state restoration
        [self.window makeKeyAndVisible];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self commonInitialization:launchOptions];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// store data not necessarily related to the user interface,
// this is called when the app is suspended to the background
//
- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    // encode any state at the app delegate level
}

// reload data not necessarily related to the user interface,
// this is called when the app is re-launched
//
- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    // decode any state at the app delegate level
    //
    // if you plan to do any asynchronous initialization for restoration -
    // Use these methods to inform the system that state restoration is occuring
    // asynchronously after the application has processed its restoration archive on launch.
    // In the even of a crash, the system will be able to detect that it may have been
    // caused by a bad restoration archive and arrange to ignore it on a subsequent application launch.
    //
    [[UIApplication sharedApplication] extendStateRestoration];
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        
        // do any additional asynchronous initialization work here...
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // done asynchronously initializing, complete our state restoration
            //
            [[UIApplication sharedApplication] completeStateRestoration];
        });
    });
    
    // if you ever want to check for restore bundle version of user interface idiom, use this code:
    //
    //ask for the restoration version (used in case we have multiple versions of the app with varying UIs)
    // String with value of info.plist's Bundle Version (app version) when state was last saved for the app
    //
    NSString *restoreBundleVersion = [coder decodeObjectForKey:UIApplicationStateRestorationBundleVersionKey];
    NSLog(@"Restore bundle version = %@", restoreBundleVersion);
    
    // ask for the restoration idiom (used in case user ran used to run an iPhone version but now running on an iPad)
    // NSNumber containing the UIUSerInterfaceIdiom enum value of the app that saved state
    //
    NSNumber *restoreUserInterfaceIdiom = [coder decodeObjectForKey:UIApplicationStateRestorationUserInterfaceIdiomKey];
    NSLog(@"Restore User Interface Idiom = %d", restoreUserInterfaceIdiom.integerValue);
}


@end
