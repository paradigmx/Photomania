//
//  PhotosTableViewController.h
//  Photomania
//
//  Created by Neo on 8/29/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Photographer.h"

@interface PhotosTableViewController : CoreDataTableViewController
@property (strong, nonatomic) Photographer *photographer;
@end
