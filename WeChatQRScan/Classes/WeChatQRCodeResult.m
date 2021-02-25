//
//  WeChatQRCodeResult.m
//  WeChatQRScan
//
//  Created by rickzuo on 2021/2/25.
//

#import "WeChatQRCodeResult.h"

@implementation WeChatQRCodeResult

- (instancetype)initWithContent:(NSString *)content rect:(CGRect)rect {
    self = [super init];
    if (self) {
        _content = content;
        _rect = rect;
    }
    return self;
}

- (instancetype)initWithContent:(NSString *)content {
    self = [super init];
    if (self) {
        _content = content;
    }
    return self;
}

@end
