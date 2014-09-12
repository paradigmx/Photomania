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
#import "Photo+Annotation.h"
#import "ImageViewController.h"
#import "Photographer+Create.h"
#import "AddPhotoViewController.h"

@interface PhotosByPhotographerMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPhotoBarButtonItem;
@property (strong, nonatomic) NSArray *photosByPhotographer; // of Photo
@property (strong, nonatomic) ImageViewController *imageViewController;
@property (strong, nonatomic) Photo *selectedPhoto;
@end

@implementation PhotosByPhotographerMapViewController

- (ImageViewController *)imageViewController {
    id detail = self.splitViewController.viewControllers.lastObject;
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = ((UINavigationController *)detail).viewControllers.firstObject;
    }
    return [detail isKindOfClass:[ImageViewController class]] ? detail : nil;
}

- (void)updateMapViewAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByPhotographer];
    [self.mapView showAnnotations:self.photosByPhotographer animated:YES];

    if (self.imageViewController) {
        Photo *photo = self.photosByPhotographer.firstObject;

        if (photo) {
            [self.mapView selectAnnotation:photo animated:YES];
            [self prepareViewController:self.imageViewController forSegueWithIdentifier:nil withAnnotation:photo];
        }
    }
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
    [self updateAddPhotoBarButtonItem];
}

- (void)updateAddPhotoBarButtonItem {
    if (self.addPhotoBarButtonItem) {
        BOOL canAddPhoto = self.photographer.isUser;
        NSMutableArray *rightBarButtonItems = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (!rightBarButtonItems) rightBarButtonItems = [[NSMutableArray alloc] init];
        NSUInteger addPhotoBarButtonItemIndex = [rightBarButtonItems indexOfObject:self.addPhotoBarButtonItem];
        if (addPhotoBarButtonItemIndex == NSNotFound) {
            if (canAddPhoto) [rightBarButtonItems addObject:self.addPhotoBarButtonItem];
        }
        else {
            if (!canAddPhoto) [rightBarButtonItems removeObjectAtIndex:addPhotoBarButtonItemIndex];
        }
        self.navigationItem.rightBarButtonItems = rightBarButtonItems;
    }
}

- (NSArray *)photosByPhotographer {
    if (!_photosByPhotographer) {
        NSFetchRequest *requst = [NSFetchRequest fetchRequestWithEntityName:ENTITY_NAME_PHOTO];
        requst.predicate = [NSPredicate predicateWithFormat:@"photographer = %@", self.photographer];
        _photosByPhotographer = [self.photographer.managedObjectContext executeFetchRequest:requst error:NULL];
    }

    return _photosByPhotographer;
}

#pragma mark - Map view delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *reuseIdentifier = @"Photo by Photographer";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        view.canShowCallout = YES;

        if (!self.imageViewController) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
            view.leftCalloutAccessoryView = imageView;

            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    }

    view.annotation = annotation;

    return view;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if (self.imageViewController) {
        [self prepareViewController:self.imageViewController forSegueWithIdentifier:nil withAnnotation:view.annotation];
    }
    else {
        [self updateLeftCalloutAccessoryViewInAnnotationView:view];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self performSegueWithIdentifier:@"Show Photo" sender:view];
}

- (void)updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView *)annotationView {
    UIImageView *imageView = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if (imageView) {
        Photo *photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *)annotationView.annotation;
        }
        if (photo) {
            self.selectedPhoto = photo;
            dispatch_queue_t fetchQ = dispatch_queue_create("FlickrFetcher", NULL);
            dispatch_async(fetchQ, ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];
                if (photo == self.selectedPhoto) {
                    dispatch_async(dispatch_get_main_queue(), ^{ imageView.image = image; });
                }
            });
        }
    }
}

#pragma mark - Navigation

- (void)prepareViewController:(id)vc forSegueWithIdentifier:(NSString *)identifier withAnnotation:(id <MKAnnotation>)annotation {
    Photo *photo = nil;
    if ([annotation isKindOfClass:[Photo class]]) {
        photo = (Photo *)annotation;
    }
    if (photo) {
        if (![identifier length] || [identifier isEqualToString:@"Show Photo"]) {
            if ([vc isKindOfClass:[ImageViewController class]]) {
                ImageViewController *imageViewControll = (ImageViewController *)vc;
                imageViewControll.title = photo.title;
                imageViewControll.imageURL = [NSURL URLWithString:photo.imageURL];
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController
             forSegueWithIdentifier:segue.identifier
                     withAnnotation:((MKAnnotationView *)sender).annotation];
    }
    else {
        if ([segue.destinationViewController isKindOfClass:[AddPhotoViewController class]]) {
            AddPhotoViewController *addPhotoViewController = (AddPhotoViewController *)segue.destinationViewController;
            addPhotoViewController.photographer = self.photographer;
        }
    }
}

- (IBAction)addPhoto:(UIStoryboardSegue *)segue {
    if ([segue.sourceViewController isKindOfClass:[AddPhotoViewController class]]) {
        AddPhotoViewController *addPhotoViewController = (AddPhotoViewController *)segue.sourceViewController;
        Photo *photo = addPhotoViewController.photo;
        if (photo) {
            [self.mapView addAnnotation:photo];
            [self.mapView showAnnotations:@[photo] animated:YES];
            self.photosByPhotographer = nil;
        }
        else {
            NSLog(@"WARNING: AddPhotoViewController did not return a photo.");
        }
    }
}

@end
