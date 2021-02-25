//
//  WeChatQRCodeResult.h
//  WeChatQRScan
//
//  Created by rickzuo on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeChatQRCodeResult : NSObject

@property (nonatomic, copy, readonly) NSString * content;

@property (nonatomic, assign, readonly) CGRect rect;

- (instancetype)initWithContent:(NSString *)content rect:(CGRect)rect;

- (instancetype)initWithContent:(NSString *)content;

@end
NS_ASSUME_NONNULL_END
