//
//  PDFViewController.h
//  LawyerHelper
//
//  Created by mac on 2025/11/12.
//

#import <UIKit/UIKit.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDFViewController : UIViewController <UISearchResultsUpdating>

// 通过文件路径初始化PDFViewController
- (instancetype)initWithFilePath:(NSString *)filePath;

// 通过URL初始化PDFViewController
- (instancetype)initWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END