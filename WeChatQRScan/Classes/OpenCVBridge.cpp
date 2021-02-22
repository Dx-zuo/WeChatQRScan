//
//  OpenCVBridge-Swift.m
//  WeChatQRScan
//
//  Created by 乐 y on 2021/2/7.
//

#import "OpenCVBridge.h"


void Mat_Transform(Mat src, Mat dst, Mat tm) {
    cv::transform(*src, *dst, *tm);
}

void Mat_Transpose(Mat src, Mat dst) {
    cv::transpose(*src, *dst);
}

void Mat_Flip(Mat src, Mat dst, int flipCode) {
    cv::flip(*src, *dst, flipCode);
}
// Mat_New creates a new empty Mat
Mat Mat_New() {
    return new cv::Mat();
}

// Mat_NewWithSize creates a new Mat with a specific size dimension and number of channels.
Mat Mat_NewWithSize(int rows, int cols, int type) {
    return new cv::Mat(rows, cols, type, 0.0);
}

// Mat_NewFromScalar creates a new Mat from a Scalar. Intended to be used
// for Mat comparison operation such as InRange.
Mat Mat_NewFromScalar(Scalar ar, int type) {
    cv::Scalar c = cv::Scalar(ar.val1, ar.val2, ar.val3, ar.val4);
    return new cv::Mat(1, 1, type, c);
}

// Mat_NewWithSizeFromScalar creates a new Mat from a Scalar with a specific size dimension and number of channels
Mat Mat_NewWithSizeFromScalar(Scalar ar, int rows, int cols, int type) {
    cv::Scalar c = cv::Scalar(ar.val1, ar.val2, ar.val3, ar.val4);
    return new cv::Mat(rows, cols, type, c);
}

Mat Mat_NewFromBytes(int rows, int cols, int type, struct ByteArray buf) {
    return new cv::Mat(rows, cols, type, buf.data);
}

Mat Mat_NewFromBufAddr(int rows, int cols, int type, void * imgBufAddr) {
    return new cv::Mat(rows, cols, type, imgBufAddr, 0);
}

Mat Mat_FromPtr(Mat m, int rows, int cols, int type, int prow, int pcol) {
    return new cv::Mat(rows, cols, type, m->ptr(prow, pcol));
}


// Mat_Close deletes an existing Mat
void Mat_Close(Mat m) {
    delete m;
}

// Mat_Empty tests if a Mat is empty
int Mat_Empty(Mat m) {
    return m->empty();
}

// Mat_Clone returns a clone of this Mat
Mat Mat_Clone(Mat m) {
    return new cv::Mat(m->clone());
}
