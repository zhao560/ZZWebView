//
//  ZZWebViewController.m
//  WKWebView 与 JS
//
//  Created by 凉凉 on 2017/5/31.
//  Copyright © 2017年 凉凉. All rights reserved.
//

#import "ZZWebViewController.h"
#import <WebKit/WebKit.h>

@interface ZZWebViewController () <WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic,strong) UIProgressView *progressView;
//返回按钮
@property (nonatomic)UIBarButtonItem *backBtnItem;
//关闭按钮
@property (nonatomic)UIBarButtonItem *closeButtonItem;
@end

@implementation ZZWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                                                                      NSForegroundColorAttributeName: [UIColor blackColor],
                                                                      NSFontAttributeName: [UIFont systemFontOfSize:16]
                                                                      }];
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    [self updateNavigationItems];
    // 请求网页数据
    [self loadData];
    // 点击调用js方法
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"test" style:UIBarButtonItemStylePlain target:self action:@selector(clickNavRightBtn)];
}
// 本地文件返回有时不会出现关闭 用网络连接是没问题的
-(void)loadData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
}

//-(void)loadData {
//    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://baidu.com"]];
//    [self.webView loadRequest:req];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        self.progressView.hidden = NO;
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        if(self.webView.estimatedProgress >=1.0f) {
            [self.progressView setProgress:1.0f animated:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.progressView setProgress:0.0f animated:NO];
                self.progressView.hidden = YES;
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - WKNavigationDelegate
// 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
}
// 加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"当内容开始返回时调用");
}
// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"页面加载超时");
}
//跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"跳转失败");
}
//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"在发送请求之前，决定是否跳转");
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKScriptMessageHandler
// 从web界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"AppModel"]) {
        NSLog(@"%@",message.body);
        [self showMsg:[message.body objectForKey:@"key"]];
    }
}
- (void)showMsg:(NSString *)msg {
    if ([msg isEqual:[NSNull null]]) {
        msg = @"test";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"j调用oc" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:NULL];
}
#pragma mark ================ 自定义返回/关闭按钮 ================

-(void)updateNavigationItems {
    if (self.webView.canGoBack) {
        [self.navigationItem setLeftBarButtonItems:@[self.backBtnItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:@[self.backBtnItem]];
    }
}
// 返回
-(void)clickBackBtn {
    [self updateNavigationItems];
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
// 关闭
-(void)clickCloseBtn {
    [self.navigationController popViewControllerAnimated:YES];
}

// oc 调用js
-(void)clickNavRightBtn {
    [self.webView evaluateJavaScript:@"alertName('这是WKWebView')" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
    }];
}

#pragma mark - lazy
-(WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        config.preferences.minimumFontSize = 10;
        // 默认认为YES
        config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        
        // web内容处理池
        config.processPool = [[WKProcessPool alloc] init];
        
        // 通过JS与webview内容交互
        config.userContentController = [[WKUserContentController alloc] init];
        // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
        // 我们可以在WKScriptMessageHandler代理中接收到
        [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
        
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        //kvo 添加进度监控
        [_webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:NULL];
        // 设置代理
        _webView.navigationDelegate = self;
    }
    return _webView;
}


-(UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [_progressView setFrame:CGRectMake(0, 64, self.view.frame.size.width, 1)];
        
        //设置进度条颜色
        [_progressView setTintColor:[UIColor colorWithRed:0.400 green:0.863 blue:0.133 alpha:1.000]];
    }
    return _progressView;
}


-(UIBarButtonItem *)backBtnItem {
    if (!_backBtnItem) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btn setTitle:@"返回" forState:UIControlStateNormal];
        [btn setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"backItemImage"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        _backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    return _backBtnItem;
}

-(UIBarButtonItem *)closeButtonItem {
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickCloseBtn)];
    }
    return _closeButtonItem;
}

-(void)dealloc {
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"AppModel"];
    [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
