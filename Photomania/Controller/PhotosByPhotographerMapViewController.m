//
//  PhotosByPhotographerMapViewController.m
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "PhotosByPhotographerMapViewController.h"
#import <MapKit/MapKit.h>
#import "Photo+Flickr.h"

@interface PhotosByPhotographerMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *photosByPhotographer; // of Photo
@end

@implementation PhotosByPhotographerMapViewController

- (void)updateMapViewAnnotations {

}

- (void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;

    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
}

- (void)setPhotographer:(Photographer *)photographer {
    _photographer = photographer;

    self.title = photographer.name;
    self.photosByPhotographer = nil;
    [self updateMapViewAnnotations];
}

- (NSArray *)photosByPhotographer {
    if (!_photosByPhotographer) {
        NSFetchRequest *requst = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTO];
        requst.predicate = [NSPredicate predicateWithFormat:@"photographer = %@", self.photographer];
        _photosByPhotographer = [self.photographer.managedObjectContext executeFetchRequest:requst error:NULL];
    }

    return _photosByPhotographer;
}

@end
