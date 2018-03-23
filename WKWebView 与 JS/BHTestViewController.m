
//
//  BHTestViewController.m
//  BHJinFu
//
//  Created by 凉凉 on 2018/3/23.
//  Copyright © 2018年 z. All rights reserved.
//

#import "BHTestViewController.h"

@interface BHTestViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>
@property (nonatomic , strong)UITableView *tableView;

@property (nonatomic , strong)UIWebView *webView;

@property (nonnull , strong)UILabel *headLab;

@end

@implementation BHTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
}

- (void)createView{
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60.f;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UILabel *footLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    footLabel.text = @"继续拖动，查看图文详情";
    footLabel.font = [UIFont systemFontOfSize:13];
    footLabel.textAlignment = NSTextAlignmentCenter;
    _tableView.tableFooterView = footLabel;
    //注意:懒加载时,只有用 self 才能调其 getter 方法
    [self.view addSubview:self.webView];
    _headLab = [[UILabel alloc] init];
    _headLab.text = @"上拉，返回详情";
    _headLab.textAlignment = NSTextAlignmentCenter;
    _headLab.font = [UIFont systemFontOfSize:13];
    _headLab.frame = CGRectMake(0, 0, self.view.frame.size.width, 40.f);
    _headLab.alpha = 0.f;
    _headLab.textColor = [UIColor blackColor];
    [_webView addSubview:_headLab];
    
    [ _webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    
}
//懒加载 webView 增加流畅度
- (UIWebView *)webView{
    
    //注意,这里不用 self 防止循环引用
    if (!_webView) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, _tableView.contentSize.height, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.delegate = self;
        _webView.delegate = self;
        _webView.scrollView.delegate = self;
        
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    }
    
    return _webView;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 15;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *indetifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indetifier];
    cell.textLabel.text = @"Amydom";
    
    return cell;
    
    
}

//监测 scroll 的偏移量
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if([scrollView isKindOfClass:[UITableView class]]) // tableView界面上的滚动
    {
        // 能触发翻页的理想值:tableView整体的高度减去屏幕本省的高度
        CGFloat valueNum = _tableView.contentSize.height - self.view.frame.size.height;
        if ((offsetY - valueNum) > 40)
        {
            
            [self goToDetailAnimation]; // 进入图文详情的动画
        }
    }
    
    else // webView页面上的滚动
    {
        if(offsetY < 0 && -offsetY > 40)
        {
            [self backToFirstPageAnimation]; // 返回基本详情界面的动画
        }
    }
}

// 进入详情的动画
- (void)goToDetailAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _webView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        _tableView.frame = CGRectMake(0, -self.view.frame.size.height , self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}


// 返回第一个界面的动画
- (void)backToFirstPageAnimation
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        _tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height);
        _webView.frame = CGRectMake(0, _tableView.contentSize.height, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

// KVO观察
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if(object == _webView.scrollView && [keyPath isEqualToString:@"contentOffset"])
    {
        [self headLabAnimation:[change[@"new"] CGPointValue].y];
    }else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



// 头部提示文本动画
- (void)headLabAnimation:(CGFloat)offsetY
{
    _headLab.alpha = -offsetY/60;
    _headLab.center = CGPointMake(self.view.frame.size.width/2, -offsetY/2.f);
    // 图标翻转，表示已超过临界值，松手就会返回上页
    if(-offsetY > 40){
        _headLab.textColor = [UIColor redColor];
        _headLab.text = @"释放，返回详情";
    }else{
        _headLab.textColor = [UIColor blackColor];
        _headLab.text = @"上拉，返回详情";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
