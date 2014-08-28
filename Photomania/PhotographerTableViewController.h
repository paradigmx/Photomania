//
//  PhotographerTableViewController.h
//  Photomania
//
//  Created by Neo on 8/28/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PhotographerTableViewController : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
