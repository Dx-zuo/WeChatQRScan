//
//  WeChatQRCodeDetector.m
//  Pods-Example
//
//  Created by 乐 y on 2021/2/23.
//

#import "WeChatQRCodeDetector.h"
#import <opencv2/opencv2.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@implementation WeChatQRCodeDetector
- (NSArray<NSString *> *)detectAndDecode:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imgBuf, 0);

    void *imgBufAddr = CVPixelBufferGetBaseAddressOfPlane(imgBuf, 0);

    int w = (int)CVPixelBufferGetWidth(imgBuf);
    int h = (int)CVPixelBufferGetHeight(imgBuf);

    cv::Mat mat(h, w, CV_8UC4, imgBufAddr, 0);

    cv::Mat transMat;
    cv::transpose(mat, transMat);

    cv::Mat flipMat;
    cv::flip(transMat, flipMat, 1);

    CVPixelBufferUnlockBaseAddress(imgBuf, 0);

    NSTimeInterval start = CACurrentMediaTime();

    std::vector<cv::Mat> points;
    std::vector<std::string> res = self.nativePtr->detectAndDecode(flipMat, points);
    if (!res.size()) {
        return nil;
    }
    NSMutableArray<NSString*> *resStrings = [NSMutableArray new];
    for (int i = 0; i < res.size(); ++i) {
        [resStrings addObject:[NSString stringWithCString:res[i].c_str() encoding:[NSString defaultCStringEncoding]]];
    }
    return [resStrings copy];
}
@end
