//
//  UIImage+ParadigmX.h
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ParadigmX)
// Makes a resized copy of image
- (UIImage *)imageByScalingToSize:(CGSize)size;

// Applies a filter on image
- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName;
@end
