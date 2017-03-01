//
//  DConnectTouchProfile.h
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*!
 @file
 @brief Provides functionality to implement the Touch profile.
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief Profile name
 */
extern NSString *const DConnectTouchProfileName;

/*!
 @brief Attribute: ontouch.
 */
extern NSString *const DConnectTouchProfileAttrOnTouch;

/*!
 @brief Attribute: ontouchstart.
 */
extern NSString *const DConnectTouchProfileAttrOnTouchStart;

/*!
 @brief Attribute: ontouchend.
 */
extern NSString *const DConnectTouchProfileAttrOnTouchEnd;

/*!
 @brief Attribute: ondoubletap.
 */
extern NSString *const DConnectTouchProfileAttrOnDoubleTap;

/*!
 @brief Attribute: ontouchmove.
 */
extern NSString *const DConnectTouchProfileAttrOnTouchMove;

/*!
 @brief Attribute: ontouchcancel.
 */
extern NSString *const DConnectTouchProfileAttrOnTouchCancel;
/*!
 @brief Attribute: ontouchchange.
 */
extern NSString *const DConnectTouchProfileAttrOnTouchChange;
/*!
 @brief Parameter: state.
 */
extern NSString *const DConnectTouchProfileParamState;

/*!
 @brief Parameter: touch.
 */
extern NSString *const DConnectTouchProfileParamTouch;

/*!
 @brief Parameter: touches.
 */
extern NSString *const DConnectTouchProfileParamTouches;

/*!
 @brief Parameter: id.
 */
extern NSString *const DConnectTouchProfileParamId;

/*!
 @brief Parameter: x.
 */
extern NSString *const DConnectTouchProfileParamX;

/*!
 @brief Parameter: y.
 */
extern NSString *const DConnectTouchProfileParamY;

/*!
 @brief Enumeration: start.
 */
extern NSString *const DConnectTouchProfileEnumStart;
/*!
 @brief Enumaration: end.
 */
extern NSString *const DConnectTouchProfileEnumEnd;
/*!
 @brief Enumaration: doubletap.
 */
extern NSString *const DConnectTouchProfileEnumDoubleTap;
/*!
 @brief Enumaration: move.
 */
extern NSString *const DConnectTouchProfileEnumMove;
/*!
 @brief Enumaration: cancel.
 */
extern NSString *const DConnectTouchProfileEnumCancel;


/*!
 @class DConnectTouchProfile
 @brief Touch Profile.
 
 Receive request to the Touch Profile API.
 The received request is reported to the delegate for each API.
 */
@interface DConnectTouchProfile : DConnectProfile

#pragma mark - Setters

/*!
 @brief Set touch information to message.
 @param[in] touch touch information.
 @param[in,out] message message for storing touch information.
 */
+ (void) setTouch:(DConnectMessage *)touch target:(DConnectMessage *)message;

/*!
 @brief Set touch coordinate information to message.
 @param[in] touches touch coordinate information.
 @param[in,out] message message for storing touch coordinate information.
 */
+ (void) setTouches:(DConnectArray *)touches target:(DConnectMessage *)message;

/*!
 @brief Set the identification number to message.
 @param[in] id identification number.
 @param[in,out] message message for storing identification number.
 */
+ (void) setId:(int)id target:(DConnectMessage *)message;

/*!
 @brief Set the X coordinates to message.
 @param[in] x X coordinate.
 @param[in,out] message message for storing X coordinate.
 */
+ (void) setX:(int)x target:(DConnectMessage *)message;

/*!
 @brief Set the Y coordinates to message.
 @param[in] y Y coordinate.
 @param[in,out] message message for storing Y coordinate.
 */
+ (void) setY:(int)y target:(DConnectMessage *)message;

/*!
 @brief Set the Touch State to message.
 @param[in] state Touch State.
 @param[in,out] message message for storing touch state.
 */
+ (void) setState:(NSString*)state target:(DConnectMessage *)message;

@end
