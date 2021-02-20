//
//  OpenCVBridge-Swift.h
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/7.
//

//#include <stdint.h>
//#include <stdbool.h>
//#import "opencv2/Mat.h"
//#import <opencv2/WeChatQRCode.h>
#import <opencv2/opencv2.h>
//#ifdef __cplusplus
//typedef cv::Mat* Mat;
//#else
//typedef void* Mat;
//#endif


void Mat_Transform(Mat * src, Mat * dst, Mat * tm);
void Mat_Transpose(Mat * src, Mat * dst);

Mat * Mat_New();
void Mat_Close(Mat * m);

Mat * Mat_NewWithSize(int rows, int cols, int type);
Mat * Mat_NewFromBytes(int rows, int cols, int type, void *data);
Mat * Mat_FromPtr(Mat * m, int rows, int cols, int type, int prow, int pcol);

