//
//  Photo+Annotation.m
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "Photo+Annotation.h"

@implementation Photo (Annotation)

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinate;

    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longitude doubleValue];

    return coordinate;
}

@end
