//
//  OpenCVBridge.h
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/7.
//

#include <stdbool.h>

typedef struct ByteArray {
    char* data;
    int length;
} ByteArray;

typedef struct Scalar {
    double val1;
    double val2;
    double val3;
    double val4;
} Scalar;
#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#include <opencv2/wechat_qrcode.hpp>

extern "C"{
#endif
    #ifdef __cplusplus
    typedef cv::Mat* Mat;
    typedef cv::OutputArrayOfArrays Arrays;
    #else
    typedef void* Mat;
    typedef void* Arrays;
    #endif
    void Mat_Transform(Mat src, Mat dst, Mat tm);
    void Mat_Transpose(Mat src, Mat dst);

    void Mat_Flip(Mat src, Mat dst, int flipCode);

    Mat Mat_New();
    void Mat_Close(Mat m);
    Mat Mat_NewWithSize(int rows, int cols, int type);
    Mat Mat_NewFromScalar(const Scalar ar, int type);
    Mat Mat_NewWithSizeFromScalar(const Scalar ar, int rows, int cols, int type);
    Mat Mat_NewFromBytes(int rows, int cols, int type, struct ByteArray buf);
    Mat Mat_NewFromBufAddr(int rows, int cols, int type, void * imgBufAddr);
    Mat Mat_FromPtr(Mat m, int rows, int cols, int type, int prows, int pcols);
#ifdef __cplusplus
}
#endif
