//
//  PhotosByPhotographerImageViewController.m
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotosByPhotographerImageViewController.h"
#import "PhotosByPhotographerMapViewController.h"

@interface PhotosByPhotographerImageViewController ()
@property (strong, nonatomic) PhotosByPhotographerMapViewController *mapViewController;
@end

@implementation PhotosByPhotographerImageViewController


#pragma mark - Navigation

- (void)setPhotographer:(Photographer *)photographer {
    _photographer = photographer;

    self.title = photographer.name;
    self.mapViewController.photographer = self.photographer;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[PhotosByPhotographerMapViewController class]]) {
        PhotosByPhotographerMapViewController *mapViewController = (PhotosByPhotographerMapViewController *)segue.destinationViewController;
        mapViewController.photographer = self.photographer;
        self.mapViewController = mapViewController;
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

@end
