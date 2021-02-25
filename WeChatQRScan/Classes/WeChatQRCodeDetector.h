//
//  WeChatQRCodeDetector.h
//  Pods-Example
//
//  Created by 乐 y on 2021/2/23.
//

#import <Foundation/Foundation.h>
#import <opencv2/WeChatQRCode.h>
#import <AVFoundation/AVFoundation.h>

@interface WeChatQRCodeDetector : WeChatQRCode
- (nullable NSArray<NSString*> *)detectAndDecode:(CMSampleBufferRef)sampleBuffer NS_SWIFT_NAME(detectAndDecode(sampleBuffer:));
@end
