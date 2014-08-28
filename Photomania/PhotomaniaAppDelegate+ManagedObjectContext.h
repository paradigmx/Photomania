//
//  PhotomaniaAppDelegate+ManagedObjectContext.h
//  Photomania
//
//  Created by Neo on 8/28/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotomaniaAppDelegate.h"

@interface PhotomaniaAppDelegate (ManagedObjectContext)
- (void)saveContext:(NSManagedObjectContext *)managedObjectContext;
- (NSManagedObjectContext *)createMainQueueManagedObjectContext;
@end
