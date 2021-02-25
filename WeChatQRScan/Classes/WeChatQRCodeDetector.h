//
//  WeChatQRCodeDetector.h
//  Pods-Example
//
//  Created by 乐 y on 2021/2/23.
//

#import <Foundation/Foundation.h>
#import <opencv2/WeChatQRCode.h>
#import <AVFoundation/AVFoundation.h>
#import "WeChatQRCodeResult.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WeChatQRCodeDetectorDelegate

- (void)WeChatQRCodeDetector:(NSArray <WeChatQRCodeResult *> *)results sampleBuffer:(CMSampleBufferRef _Nullable )sampleBuffer;

@end

@interface WeChatQRCodeDetector : WeChatQRCode

@property (nonatomic, weak, nullable) id <WeChatQRCodeDetectorDelegate> delegate;

- (void)sendSampleBuffer:(CMSampleBufferRef _Nullable )sampleBuffer;

@end
NS_ASSUME_NONNULL_END
