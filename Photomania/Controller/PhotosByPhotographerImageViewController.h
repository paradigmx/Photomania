//
//  PhotosByPhotographerImageViewController.h
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "ImageViewController.h"
#import "Photographer.h"

@interface PhotosByPhotographerImageViewController : ImageViewController
@property (strong, nonatomic) Photographer *photographer;
@end
