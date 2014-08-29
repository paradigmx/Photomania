//
//  PhotosByPhotographerTableViewController.h
//  Photomania
//
//  Created by Neo on 8/29/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerTableViewController : PhotosTableViewController
@property (strong, nonatomic) Photographer *photographer;
@end
