//
//  LTZMoreInputViewItem.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/6.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "LTZMoreInputItem.h"

@interface LTZMoreInputItem ()<NSCopying, NSCoding>
{
    UIImage *_image;
    NSString *_title;
}

@end

@implementation LTZMoreInputItem
@synthesize image = _image;
@synthesize title = _title;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title
{
    if (self = [super init]) {
        [self updateWithImage:image title:title];
    }
    
    return self;
}
- (void)updateWithImage:(UIImage *)image title:(NSString *)title
{
    _image = image;
    _title = title;
}

- (void)dealloc
{
    _image = nil;
    _title = nil;
}

#pragma mark NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    LTZMoreInputItem *newObject = [[[self class] allocWithZone:zone] init];
    //Here is a sample for using the NScoding method
    //Add your code here
    [newObject updateWithImage:self.image title:self.title];

    return newObject;
}

#pragma mark -
#pragma mark NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //Here is a sample for using the NScoding method
    //Add your code here
    [aCoder encodeObject:self.image forKey:@"image"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //Here is a sample for using the NScoding method
        //Add your code here
        [self updateWithImage:[aDecoder decodeObjectForKey:@"image"] title:[aDecoder decodeObjectForKey:@"title"]];
    }
    return  self;
}

@end
