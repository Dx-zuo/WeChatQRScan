//
//  WeChatQRCodeDetector.m
//  Pods-Example
//
//  Created by 乐 y on 2021/2/23.
//

#import "WeChatQRCodeDetector.h"
#import <opencv2/opencv2.h>




@implementation WeChatQRCodeDetector

- (void)sendSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    std::vector<cv::Mat> points;
    cv::Mat mat = [self cvBufferToMat:sampleBuffer];
    std::vector<std::string> res = self.nativePtr->detectAndDecode(mat, points);
    if (!res.size()) {
        return;
    }
    NSMutableArray<WeChatQRCodeResult*> *results = [NSMutableArray new];
    for (int i = 0; i < res.size(); ++i) {
        WeChatQRCodeResult *result;
        NSString *content = [NSString stringWithCString:res[i].c_str() encoding:[NSString defaultCStringEncoding]];
        if (points.size() < i) {
            cv::Mat m        = points[i];
            CGRect rect = [self cvMatsToRects:m];
            result = [[WeChatQRCodeResult alloc] initWithContent:content rect:rect];
        } else {
            result = [[WeChatQRCodeResult alloc] initWithContent:content];
        }
        [results addObject:result];
    }
    [self.delegate WeChatQRCodeDetector:results sampleBuffer:sampleBuffer];
}

- (CGRect)cvMatsToRects:(cv::Mat)mat {
    cv::Mat &m = mat;
    CGPoint topLeft    = CGPointMake(m.at<float>(0, 0), m.at<float>(0, 1));
    CGPoint topRight   = CGPointMake(m.at<float>(1, 0), m.at<float>(1, 1));
    CGPoint bottomLeft = CGPointMake(m.at<float>(2, 0), m.at<float>(2, 1));
    
    CGRect rectOfImage = (CGRect){topLeft, CGSizeMake(topRight.x - topLeft.x, bottomLeft.y - topLeft.y)};
    return rectOfImage;
}

- (cv::Mat)cvBufferToMat:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress( pixelBuffer, 0);

    CGFloat bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat bufferHeight = CVPixelBufferGetHeight(pixelBuffer);

    unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);

    cv::Mat mat(bufferHeight, bufferWidth, CV_8UC4, pixel, 0);

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    return mat;
}
@end
