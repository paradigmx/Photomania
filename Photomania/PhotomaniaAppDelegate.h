//
//  PhotomaniaAppDelegate.h
//  Photomania
//
//  Created by Neo Lee on 8/31/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotomaniaAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIManagedDocument *database; // our photo database
@end
