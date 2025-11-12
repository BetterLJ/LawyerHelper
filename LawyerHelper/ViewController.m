//
//  ViewController.m
//  LawyerHelper
//
//  Created by mac on 2025/11/12.
//

#import "ViewController.h"
#import "PDFViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *openFileButton;
@property (nonatomic, strong) UIButton *openLocalFileButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置视图背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建打开文件按钮
    self.openFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.openFileButton setTitle:@"打开设备PDF文件" forState:UIControlStateNormal];
    self.openFileButton.frame = CGRectMake(50, 100, self.view.frame.size.width - 100, 44);
    [self.openFileButton addTarget:self action:@selector(openFileButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openFileButton];
    
    // 创建打开本地文件按钮
    self.openLocalFileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.openLocalFileButton setTitle:@"打开项目中的民法典" forState:UIControlStateNormal];
    self.openLocalFileButton.frame = CGRectMake(50, 160, self.view.frame.size.width - 100, 44);
    [self.openLocalFileButton addTarget:self action:@selector(openLocalFileButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openLocalFileButton];
}

- (void)openFileButtonTapped {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"com.adobe.pdf"] inMode:UIDocumentPickerModeOpen];
    documentPicker.delegate = self;
    documentPicker.allowsMultipleSelection = NO;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)openLocalFileButtonTapped {
    // 直接打开项目中的PDF文件
    NSString *fileName = @"中华人民共和国民法典_20200528_20251112111009.pdf";
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    
    if (filePath) {
        // 创建PDFViewController并跳转到新页面
        PDFViewController *pdfViewController = [[PDFViewController alloc] initWithFilePath:filePath];
        [self.navigationController pushViewController:pdfViewController animated:YES];
    } else {
        NSLog(@"找不到PDF文件: %@", fileName);
        // 显示错误提示
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" 
                                                                       message:[NSString stringWithFormat:@"找不到PDF文件: %@", fileName] 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *fileURL = urls[0];
        
        // 创建PDFViewController并跳转到新页面
        PDFViewController *pdfViewController = [[PDFViewController alloc] initWithFileURL:fileURL];
        [self.navigationController pushViewController:pdfViewController animated:YES];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // 用户取消了选择
    NSLog(@"User cancelled file selection");
}

@end