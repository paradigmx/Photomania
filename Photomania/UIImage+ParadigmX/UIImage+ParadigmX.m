//
//  UIImage+ParadigmX.m
//  Photomania
//
//  Created by Neo on 9/11/14.
//  Copyright (c) 2014 Paradigm X. All rights reserved.
//

#import "UIImage+ParadigmX.h"

@implementation UIImage (ParadigmX)

- (UIImage *)imageByScalingToSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resizedImage;
}

- (UIImage *)imageByApplyingFilterNamed:(NSString *)filterName {
    UIImage *filteredImage = self;
    CIImage *inputImage = [CIImage imageWithCGImage:[self CGImage]];
    if (inputImage) {
        CIFilter *filter = [CIFilter filterWithName:filterName];
        [filter setValue:inputImage forKey:kCIInputImageKey];

        CIImage *outputImage = [filter outputImage];

        if (outputImage) {
            filteredImage = [UIImage imageWithCIImage:outputImage];
            if (filteredImage) {
                UIGraphicsBeginImageContextWithOptions(self.size, YES, 0.0);
                [filteredImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
                filteredImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
        }
    }

    return filteredImage;
}

@end
