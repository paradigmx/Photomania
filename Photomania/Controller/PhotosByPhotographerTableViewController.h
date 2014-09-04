//
//  PhotosByPhotographerTableViewController.h
//  Photomania
//
//  Created by Neo Lee on 9/3/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotosTableViewController.h"
#import "Photographer+Create.h"

@interface PhotosByPhotographerTableViewController : PhotosTableViewController
@property (strong, nonatomic) Photographer *photographer;
@end
