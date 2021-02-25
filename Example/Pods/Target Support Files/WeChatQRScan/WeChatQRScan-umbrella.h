#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "OpenCVBridge.h"
#import "WeChatQRCodeDetector.h"
#import "WeChatQRScan.h"

FOUNDATION_EXPORT double WeChatQRScanVersionNumber;
FOUNDATION_EXPORT const unsigned char WeChatQRScanVersionString[];

