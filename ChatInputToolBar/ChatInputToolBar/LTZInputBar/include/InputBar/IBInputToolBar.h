//
//  LTZInputToolBar.h
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBInputTool;

@protocol IBInputToolBarDelegate;
@protocol IBInputToolBarDataSource;

@interface IBInputToolBar : UIImageView
/**
 *  The object that acts as the delegate of the LTZInputToolBar.
 */
@property (weak, nonatomic) id<IBInputToolBarDelegate> delegate;

@property (weak, nonatomic) id<IBInputToolBarDataSource> dataSource;
/**
 *  The pan gesture recognizer responsible for handling user interaction with the system keyboard.
 */
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
/**
 *  The text view in which the user is editing with the system keyboard.
 */
@property (strong, nonatomic, readonly) IBInputTool *inputTool;

/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (strong, nonatomic, readonly) UIView *contextView;
/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (strong, nonatomic, readonly) UIScrollView *scrollView;

+ (CGFloat)IBInputToolDefaultHeight;

+ (CGFloat)IBInputToolBarDefaultHeight;

/**
 *  init a object with a view which this inputToolBar view will display on
 *
 *
 *  @param frame                frame
 *  @param scrollView           scrollView
 *  @param contextView          contextView
 *  @param panGestureRecognizer panGestureRecognizer
 *  @param delegate             delegate
 *
 *  @return this object
 */
- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView *)scrollView
             inView:(UIView *)contextView
  gestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
           delegate:(id<IBInputToolBarDelegate>)delegate
         dataSource:(id<IBInputToolBarDataSource>)dataSource;

/**
 *  close the keyboard
 */
- (void)resignFirstResponder;
/**
 *  Scroll the UIScrollView to its bottom
 */
- (void)scrollToBottom;

@end

