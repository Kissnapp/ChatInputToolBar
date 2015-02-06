//
//  LTZKeyboardController.h
//  LTZInputToolBar
//
//  Created by Peter Lee on 15/1/16.
//  Copyright (c) 2015年 Peter Lee. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class LTZKeyboardController;

/**
 *  Posted when the system keyboard frame changes.
 *  The object of the notification is the `LTZKeyboardController` object. 
 *  The `userInfo` dictionary contains the new keyboard frame for key
 *  `LTZKeyboardControllerUserInfoKeyKeyboardDidChangeFrame`.
 */
FOUNDATION_EXPORT NSString * const LTZKeyboardControllerNotificationKeyboardDidChangeFrame;

/**
 *  Contains the new keyboard frame wrapped in an `NSValue` object.
 */
FOUNDATION_EXPORT NSString * const LTZKeyboardControllerUserInfoKeyKeyboardDidChangeFrame;


/**
 *  The `LTZKeyboardControllerDelegate` protocol defines methods that 
 *  allow you to respond to the frame change events of the system keyboard.
 *
 *  A `LTZKeyboardController` object also posts the `LTZKeyboardControllerNotificationKeyboardDidChangeFrame`
 *  in response to frame change events of the system keyboard.
 */
@protocol LTZKeyboardControllerDelegate <NSObject>

@required

/**
 *  Tells the delegate that the keyboard frame has changed.
 *
 *  @param keyboardController The keyboard controller that is notifying the delegate.
 *  @param keyboardFrame      The new frame of the keyboard in the coordinate system of the `contextView`.
 */
- (void)keyboardController:(LTZKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame;

/**
 *  Tells the delegate that the keyboard has been hidden.
 *
 *  @param keyboardController The keyboard controller that is notifying the delegate.
 */
- (void)keyboardControllerKeyboardDidHide:(LTZKeyboardController *)keyboardController;

@end


/**
 *  An instance of `LTZKeyboardController` manages responding to the hiding and showing 
 *  of the system keyboard for editing its `textView` within its specified `contextView`. 
 *  It also controls user interaction with the system keyboard via its `panGestureRecognizer`, 
 *  allow the user to interactively pan the keyboard up and down in the `contextView`.
 *  
 *  When the system keyboard frame changes, it posts the `LTZKeyboardControllerNotificationKeyboardDidChangeFrame`.
 */
@interface LTZKeyboardController : NSObject

/**
 *  The object that acts as the delegate of the keyboard controller.
 */
@property (weak, nonatomic) id<LTZKeyboardControllerDelegate> delegate;

/**
 *  The text view in which the user is editing with the system keyboard.
 */
@property (weak, nonatomic, readonly) UITextView *textView;

/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (weak, nonatomic, readonly) UIView *contextView;

/**
 *  The pan gesture recognizer responsible for handling user interaction with the system keyboard.
 */
@property (weak, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  Specifies the distance from the keyboard at which the `panGestureRecognizer`
 *  should trigger user interaction with the keyboard by panning.
 *
 *  @discussion The x value of the point is not used.
 */
@property (assign, nonatomic) CGPoint keyboardTriggerPoint;

/**
 *  Returns `YES` if the keyboard is currently visible, `NO` otherwise.
 */
@property (assign, nonatomic, readonly) BOOL keyboardIsVisible;

/**
 *  Returns the current frame of the keyboard if it is visible, otherwise `CGRectNull`.
 */
@property (assign, nonatomic, readonly) CGRect currentKeyboardFrame;

/**
 *  Creates a new keyboard controller object with the specified textView, contextView, panGestureRecognizer, and delegate.
 *
 *  @param textView             The text view in which the user is editing with the system keyboard. This value must not be `nil`.
 *  @param contextView          The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`. This value must not be `nil`.
 *  @param panGestureRecognizer The pan gesture recognizer responsible for handling user interaction with the system keyboard. This value must not be `nil`.
 *  @param delegate             The object that acts as the delegate of the keyboard controller.
 *
 *  @return An initialized `LTZKeyboardController` if created successfully, `nil` otherwise.
 */
- (instancetype)initWithTextView:(UITextView *)textView
                     contextView:(UIView *)contextView
            panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                        delegate:(id<LTZKeyboardControllerDelegate>)delegate;

/**
 *  Tells the keyboard controller that it should begin listening for system keyboard notifications.
 */
- (void)beginListeningForKeyboard;

/**
 *  Tells the keyboard controller that it should end listening for system keyboard notifications.
 */
- (void)endListeningForKeyboard;

@end
