//
//  DPAllJoynLightingResponseCode.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

typedef NS_ENUM(NSUInteger, DPAllJoynLightResponseCode) {
    DPAllJoynLightResponseCodeOK = 0,                          /* Success status */
    DPAllJoynLightResponseCodeERR_NULL = 1,                    /* Unexpected NULL pointer */
    DPAllJoynLightResponseCodeERR_UNEXPECTED = 2,              /* An operation was unexpected at this time */
    DPAllJoynLightResponseCodeERR_INVALID = 3,                 /* A value was invalid */
    DPAllJoynLightResponseCodeERR_UNKNOWN = 4,                 /* A unknown value */
    DPAllJoynLightResponseCodeERR_FAILURE = 5,                 /* A failure has occurred */
    DPAllJoynLightResponseCodeERR_BUSY = 6,                    /* An operation failed and should be retried later */
    DPAllJoynLightResponseCodeERR_REJECTED = 7,                /* The request was rejected */
    DPAllJoynLightResponseCodeERR_RANGE = 8,                   /* Value provided was out of range */
    DPAllJoynLightResponseCodeERR_UNDEFINED1 = 9,              /* [This response code is not defined] */
    DPAllJoynLightResponseCodeERR_INVALID_FIELD = 10,          /* Invalid param/state field */
    DPAllJoynLightResponseCodeERR_MESSAGE = 11,                /* Invalid message */
    DPAllJoynLightResponseCodeERR_INVALID_ARGS = 12,           /* The arguments were invalid */
    DPAllJoynLightResponseCodeERR_EMPTY_NAME = 13,             /* The name is empty */
    DPAllJoynLightResponseCodeERR_RESOURCES = 14,              /* not enough resources */
    DPAllJoynLightResponseCodeERR_REPLY_WITH_INVALID_ARGS = 15,/* The reply received for a message had invalid arguments */
    DPAllJoynLightResponseCodeERR_PARTIAL = 16,                /* The requested operation was only partially successful */
    DPAllJoynLightResponseCodeERR_NOT_FOUND = 17,              /* The entity of interest was not found */
    DPAllJoynLightResponseCodeERR_NO_SLOT = 18,                /* There is no slot for new entry */
    DPAllJoynLightResponseCodeERR_DEPENDENCY = 19,             /* There is a dependency of the entity for which a delete request was received */
    DPAllJoynLightResponseCodeRESPONSE_CODE_LAST = 20
};
