//
//  LTZMoreInputViewItem.m
//  ChatInputToolBar
//
//  Created by Peter Lee on 15/2/6.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import "IBMoreInputItem.h"

@interface IBMoreInputItem ()<NSCopying, NSCoding>
{
    NSString *_imageName;
    NSString *_highlightName;
    NSString *_title;
}

@end

@implementation IBMoreInputItem
@synthesize imageName = _imageName;
@synthesize highlightName = _highlightName;
@synthesize title = _title;

- (instancetype)initWithImageName:(NSString *)imageName
                    highlightName:(NSString *)highlightName
                            title:(NSString *)title
{
    if (self = [super init]) {
        [self updateWithImageName:imageName highlightName:highlightName title:title];
    }
    
    return self;
}
- (void)updateWithImageName:(NSString *)imageName
              highlightName:(NSString *)highlightName
                      title:(NSString *)title
{
    _imageName = imageName;
    _highlightName = highlightName;
    _title = title;
}

- (void)dealloc
{
    _imageName = nil;
    _highlightName = nil;
    _title = nil;
}

#pragma mark NSCopying Methods
- (id)copyWithZone:(NSZone *)zone
{
    IBMoreInputItem *newObject = [[[self class] allocWithZone:zone] init];
    //Here is a sample for using the NScoding method
    //Add your code here
    [newObject updateWithImageName:self.imageName highlightName:self.highlightName title:self.title];

    return newObject;
}

#pragma mark -
#pragma mark NSCoding Methods
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    //Here is a sample for using the NScoding method
    //Add your code here
    [aCoder encodeObject:self.imageName forKey:@"imageName"];
    [aCoder encodeObject:self.highlightName forKey:@"highlightName"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //Here is a sample for using the NScoding method
        //Add your code here
        [self updateWithImageName:[aDecoder decodeObjectForKey:@"imageName"] highlightName:[aDecoder decodeObjectForKey:@"highlightName"] title:[aDecoder decodeObjectForKey:@"title"]];
    }
    return  self;
}

@end
