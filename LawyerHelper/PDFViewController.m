//
//  PDFViewController.m
//  LawyerHelper
//
//  Created by mac on 2025/11/12.
//

#import "PDFViewController.h"

@interface PDFViewController ()

@property (nonatomic, strong) PDFView *pdfView;
@property (nonatomic, strong) NSURL *pdfFileURL;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray<PDFSelection *> *searchResults;
@property (nonatomic, assign) NSInteger currentSearchResultIndex;

@end

@implementation PDFViewController

// 通过文件路径初始化
- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        _pdfFileURL = [NSURL fileURLWithPath:filePath];
        _searchResults = [NSMutableArray array];
        _currentSearchResultIndex = -1;
    }
    return self;
}

// 通过URL初始化
- (instancetype)initWithFileURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        _pdfFileURL = fileURL;
        _searchResults = [NSMutableArray array];
        _currentSearchResultIndex = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置视图背景色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置导航栏标题
    self.title = @"法律法规文档";
    
    // 添加返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" 
                                                                  style:UIBarButtonItemStylePlain 
                                                                 target:self 
                                                                 action:@selector(backButtonTapped)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    // 添加搜索按钮
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch 
                                                                                 target:self 
                                                                                 action:@selector(searchButtonTapped)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    // 创建PDF视图
    self.pdfView = [[PDFView alloc] initWithFrame:self.view.bounds];
    self.pdfView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.pdfView.autoScales = YES;
    [self.view addSubview:self.pdfView];
    
    // 加载PDF文件
    [self loadPDFDocument];
}

- (void)loadPDFDocument {
    if (self.pdfFileURL) {
        PDFDocument *pdfDocument = [[PDFDocument alloc] initWithURL:self.pdfFileURL];
        if (pdfDocument) {
            self.pdfView.document = pdfDocument;
        } else {
            NSLog(@"无法加载PDF文件: %@", self.pdfFileURL);
            // 显示错误提示
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" 
                                                                           message:@"无法加载PDF文件" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" 
                                                     style:UIAlertActionStyleDefault 
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self backButtonTapped];
                                                   }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)searchButtonTapped {
    // 创建搜索控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"搜索文档内容...";
    
    // 配置搜索栏
    self.searchController.searchBar.showsCancelButton = YES;
    [self.searchController.searchBar sizeToFit];
    
    // 设置搜索控制器
    self.navigationItem.searchController = self.searchController;
    self.definesPresentationContext = YES;
    
    // 自动激活搜索框
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    
    if (searchText.length > 0 && self.pdfView.document) {
        // 清除之前的搜索结果
        [self.searchResults removeAllObjects];
        self.currentSearchResultIndex = -1;
        
        // 修复：使用正确的方式查找文档中的所有匹配项
        // 先获取第一个匹配项
        PDFSelection *selection = [self.pdfView.document findString:searchText withOptions:NSCaseInsensitiveSearch];
        
        // 收集所有搜索结果
        while (selection) {
            [self.searchResults addObject:selection];
            
            // 移动到下一个匹配项
            // 这里不能使用findNextMatch，而是需要自己实现
            // 一种简单的方式是从当前选择的下一个字符开始搜索
            CGRect selectionBounds = [selection boundsForPage:selection.pages.firstObject];
            
            // 简单实现：从下一页开始搜索（避免死循环）
            NSUInteger currentPageIndex = [self.pdfView.document indexForPage:selection.pages.lastObject];
            if (currentPageIndex < self.pdfView.document.pageCount - 1) {
                PDFPage *nextPage = [self.pdfView.document pageAtIndex:currentPageIndex + 1];
                selection = [self.pdfView.document findString:searchText 
                                                  withOptions:NSCaseInsensitiveSearch];
            } else {
                selection = nil;
            }
        }
        
        // 如果有搜索结果，显示第一个
        if (self.searchResults.count > 0) {
            [self showSearchResultAtIndex:0];
            
            // 显示搜索结果数量
            NSString *message = [NSString stringWithFormat:@"找到 %ld 个匹配项", (long)self.searchResults.count];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"搜索结果" 
                                                                           message:message 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            // 添加下一个按钮
            [alert addAction:[UIAlertAction actionWithTitle:@"下一个" 
                                                     style:UIAlertActionStyleDefault 
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       [self showNextSearchResult];
                                                   }]];
            
            // 添加取消按钮
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" 
                                                     style:UIAlertActionStyleCancel 
                                                   handler:nil]];
            
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // 没有找到匹配项
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"搜索结果" 
                                                                           message:@"未找到匹配项" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" 
                                                     style:UIAlertActionStyleDefault 
                                                   handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)showSearchResultAtIndex:(NSInteger)index {
    if (index >= 0 && index < self.searchResults.count) {
        PDFSelection *selection = self.searchResults[index];
        self.currentSearchResultIndex = index;
        
        // 清除之前的高亮
        [self clearSearchHighlights];
        
        // 高亮当前搜索结果
        [selection highlightForPage:self.pdfView.currentPage withColor:[UIColor yellowColor] inBox:nil];
        
        // 滚动到搜索结果
        [self.pdfView goToPage:selection.pages.firstObject];
        [selection centerInRect:self.pdfView.bounds forView:self.pdfView animate:YES];
    }
}

- (void)showNextSearchResult {
    if (self.searchResults.count > 0) {
        NSInteger nextIndex = (self.currentSearchResultIndex + 1) % self.searchResults.count;
        [self showSearchResultAtIndex:nextIndex];
        
        // 显示当前搜索结果位置
        NSString *message = [NSString stringWithFormat:@"结果 %ld / %ld", 
                            (long)(self.currentSearchResultIndex + 1), 
                            (long)self.searchResults.count];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"搜索结果" 
                                                                       message:message 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        // 添加下一个按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"下一个" 
                                                 style:UIAlertActionStyleDefault 
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [self showNextSearchResult];
                                               }]];
        
        // 添加取消按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" 
                                                 style:UIAlertActionStyleCancel 
                                               handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)clearSearchHighlights {
    for (PDFSelection *selection in self.searchResults) {
        [selection unhighlight];
    }
}

- (void)backButtonTapped {
    // 清除搜索高亮
    [self clearSearchHighlights];
    
    // 返回上一页
    [self.navigationController popViewControllerAnimated:YES];
}

@end