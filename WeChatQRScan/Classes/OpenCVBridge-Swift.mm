//
//  OpenCVBridge-Swift.m
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/7.
//

#import "OpenCVBridge-Swift.h"

//    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(sampleBuffer);
//
//    CVPixelBufferLockBaseAddress(imgBuf, 0);
//
//    void *imgBufAddr = CVPixelBufferGetBaseAddressOfPlane(imgBuf, 0);
//
//    int w = (int)CVPixelBufferGetWidth(imgBuf);
//    int h = (int)CVPixelBufferGetHeight(imgBuf);
////    [[Mat alloc] initWithRows:h cols:w type:CV_8UC4 data:imgBufAddr step:0];
//    cv::Mat mat(h, w, CV_8UC4, imgBufAddr, 0);
//    cv::Mat transMat;
//    cv::transpose(mat, transMat);
//    cv::Mat flipMat;
//    cv::flip(transMat, flipMat, 1);
//    CVPixelBufferUnlockBaseAddress(imgBuf, 0);
//    Mat *flipMatOne;
//    std::vector<cv::Mat> points;
//
//    return flipMatOne;

void Mat_Transform(cv::Mat * src, cv::Mat * dst, cv::Mat * tm) {
    cv::transform(* src, * dst, * tm);
}

void Mat_Transpose(cv::Mat * src, cv::Mat * dst) {
    cv::transpose(* src,* dst);
}

Mat* Mat_New() { return [Mat new]; }

//Mat* Mat_NewWithSize(int rows, int cols, int type) { return new cv::Mat(rows, cols, type, 0.0); }
//Mat* Mat_NewFromBytes(int rows, int cols, int type, void *data) {
////    return new cv::Mat(rows, cols, type, buf.data);
//    return [Mat alloc] initWithRows:<#(int)#> cols:<#(int)#> type:<#(int)#> data:<#(nonnull NSData *)#>;
//}
