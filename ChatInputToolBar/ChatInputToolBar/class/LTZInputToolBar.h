//
//  LTZInputToolBar.h
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Posted when the system keyboard frame changes.
 *  The object of the notification is the LTZInputToolBar object.
 *  The `userInfo` dictionary contains the new keyboard frame for key
 *  `LTZInputToolBarUserInfoKeyKeyboardDidChangeFrame`.
 */
FOUNDATION_EXPORT NSString * const LTZInputToolBarNotificationKeyboardDidChangeFrame;

/**
 *  Contains the new keyboard frame wrapped in an `NSValue` object.
 */
FOUNDATION_EXPORT NSString * const LTZInputToolBarUserInfoKeyKeyboardDidChangeFrame;

@class HPGrowingTextView;
@protocol LTZInputToolBarDelegate;
@interface LTZInputToolBar : UIImageView
/**
 *  The object that acts as the delegate of the LTZInputToolBar.
 */
@property (weak, nonatomic) id<LTZInputToolBarDelegate> delegate;

/**
 *  The text view in which the user is editing with the system keyboard.
 */
@property (strong, nonatomic, readonly) HPGrowingTextView *inputTextView;

/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (strong, nonatomic, readonly) UIView *contextView;
/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (strong, nonatomic, readonly) UIScrollView *scrollView;

/**
 *  The pan gesture recognizer responsible for handling user interaction with the system keyboard.
 */
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  <#Description#>
 *
 *  @param frame                <#frame description#>
 *  @param scrollView           <#scrollView description#>
 *  @param contextView          <#contextView description#>
 *  @param panGestureRecognizer <#panGestureRecognizer description#>
 *  @param delegate             <#delegate description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithFrame:(CGRect)frame
         scrollView:(UIScrollView *)scrollView
             inView:(UIView *)contextView
  gestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
           delegate:(id<LTZInputToolBarDelegate>)delegate;

/**
 *  Tells the keyboard controller that it should begin listening for system keyboard notifications.
 */
- (void)beginListeningForKeyboard;

/**
 *  Tells the keyboard controller that it should end listening for system keyboard notifications.
 */
- (void)endListeningForKeyboard;

- (void)resignFirstResponder;


@end



@protocol LTZInputToolBarDelegate <NSObject>

@required
@optional

/**
 *  Tells the delegate that the keyboard frame has changed.
 *
 *  @param keyboardController The keyboard controller that is notifying the delegate.
 *  @param keyboardFrame      The new frame of the keyboard in the coordinate system of the `contextView`.
 */
- (void)keyboardController:(LTZInputToolBar *)inputToolBar keyboardDidChangeFrame:(CGRect)keyboardFrame;

/**
 *  Tells the delegate that the keyboard has been hidden.
 *
 *  @param keyboardController The keyboard controller that is notifying the delegate.
 */
- (void)keyboardControllerKeyboardDidHide:(LTZInputToolBar *)inputToolBar;

@end
