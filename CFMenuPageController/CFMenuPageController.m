//
//  CFMenuPageController.m
//  CFMenuPageController
//
//  Created by coful on 17/1/11.
//  Copyright © 2017年 coful. All rights reserved.
//

#import "CFMenuPageController.h"
#import "ViewController.h"

#define kScreenSize [UIScreen mainScreen].bounds
#define kScreenWidth kScreenSize.size.width
#define kScreenHeight kScreenSize.size.height
#define NavigationBarHeight  64
#define MenuBarViewHeight 40

@interface CFMenuPageController ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIView *menuBarView;
@property (nonatomic,strong) UIView *menuSlider;
@property (nonatomic,strong) UIView *controllerView;
@property (nonatomic,strong) UIScrollView *menuView;

@property NSInteger fromPage;
@property NSInteger currentPage;
@property NSInteger toPage;

@property UIGestureRecognizer *PagePanGestureRecognizer;

@property CGPoint menuSliderCenter;

@end

@implementation CFMenuPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"标题";
    
    if(!_menuArray){
        _menuArray =@[
                      @[@"标题1",[ViewController class]],
                      @[@"标题2",[ViewController class]],
                      @[@"标题3",[ViewController class]],
                      @[@"标题4",[ViewController class]]
                      ];
    }
    
    _fromPage = 0;
    _currentPage = 0;
    _toPage = 0;
    
    [self initMenu];
    
    [self initController];
    
    // 设置UIPageViewController的配置项
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                       forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    
    self.pageController.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-MenuBarViewHeight);
    
    self.pageController.delegate = self;
    
    self.pageController.dataSource = self;
    
    [self pageControllerSetView:_fromPage forward:YES];
    
    [self addChildViewController:self.pageController];
    
    _controllerView = [[UIView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight+MenuBarViewHeight, kScreenWidth, kScreenHeight-MenuBarViewHeight)];
    [_controllerView addSubview:self.pageController.view];
    [self.view addSubview:_controllerView];
    
    for (UIView *v in self.pageController.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)v).delegate = self;
        }
    }
    
}

-(void)initController{
    _viewControllers = [NSMutableArray array];
    for (int i=0; i<_menuArray.count; i++) {
        Class className = _menuArray[i][1];
        
        UIViewController *vc =[[className alloc] init];
        vc.title = _menuArray[i][0];
        [_viewControllers addObject:vc];
    }
}

-(void)initMenu{
    _menuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, MenuBarViewHeight)];
    
    _menuView.backgroundColor = [UIColor clearColor];
    
    _menuView.showsHorizontalScrollIndicator = NO;
    
    NSInteger total = _menuArray.count;
    CGFloat maginX = 0;
    CGFloat mbWidth = (kScreenWidth-total+1)/total;
    
    for(int i=0; i < total;i++){
        
        UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(maginX, 0, mbWidth, MenuBarViewHeight)];
        menuBtn.backgroundColor = [UIColor darkGrayColor];
        [menuBtn setTitle:_menuArray[i][0] forState:UIControlStateNormal];
        
        if (i == 0) {
            [self menuBtnSelect:menuBtn isSelect:YES];
            
        }else{
            [self menuBtnSelect:menuBtn isSelect:NO];
        }
        
        menuBtn.tag = i+1000;
        
        [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_menuView addSubview:menuBtn];
        
        maginX += mbWidth+1;
    }
    
    _menuSlider = [[UIView alloc] initWithFrame:CGRectMake(0, MenuBarViewHeight-3, mbWidth, 3)];
    _menuSlider.backgroundColor = [UIColor lightGrayColor];
    
    
    _menuView.contentSize = CGSizeMake(maginX, MenuBarViewHeight);
    
    _menuBarView = [[UIView alloc] initWithFrame:CGRectMake(0, NavigationBarHeight, kScreenWidth, MenuBarViewHeight)];
    _menuBarView.backgroundColor = [UIColor lightGrayColor];
    
    [_menuBarView addSubview:_menuView];
    [_menuBarView addSubview:_menuSlider];
    
    [self.view addSubview:_menuBarView];
    
}

#pragma mark 直接点击
-(void)menuBtnClick:(UIButton *)sender{
    
    _fromPage = _currentPage;
    
    _toPage = sender.tag-1000;
    
    if(_toPage-_fromPage>0){
        //                NSLog(@"前进");
        [self pageControllerSetView:_toPage forward:YES];
    }else{
        //                NSLog(@"后退");
        [self pageControllerSetView:_toPage forward:NO];
    }
    
    [self menuSelect:_toPage];
    
}

#pragma mark 选中样式
-(void)menuBtnSelect:(UIButton *)sender isSelect:(BOOL)temp{
    _menuSliderCenter = CGPointZero;
    if (temp) {
        
        [UIView animateWithDuration:0.5f animations:^{
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            sender.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:19.0];//[UIFont systemFontOfSize:19];
            sender.backgroundColor = [UIColor blackColor];
            _menuSlider.center = CGPointMake(sender.center.x, _menuSlider.center.y);
        }completion:nil];
    }else{
        [UIView animateWithDuration:0.5f animations:^{
            [sender setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.9] forState:UIControlStateNormal];
            sender.titleLabel.font = [UIFont systemFontOfSize:18];
            sender.backgroundColor = [UIColor darkGrayColor];
        }completion:nil];
    }
}

-(void)scrollToBtn:(UIButton *)sender{
    
    CGFloat pointX=sender.center.x-_menuView.center.x;
    
    CGPoint point = CGPointZero;
    
    if(pointX>0){
        point = CGPointMake(pointX, 0);
    }
    
    //    NSLog(@"point x:%f,y:%f",point.x,point.y);
    
    [_menuView setContentOffset:point animated:YES];
}

-(void)menuSelect:(NSInteger)toPage{
    _currentPage = toPage;
    if (toPage != _fromPage) {
        
        //      NSLog(@"%ld -> %ld",(long)_fromPage,(long)toPage);
        
        UIButton *oButton = (UIButton *)[_menuView viewWithTag:(_fromPage+1000)];
        
        [self menuBtnSelect:oButton isSelect:NO];
        
        
        UIButton *nButton = (UIButton *)[_menuView viewWithTag:(toPage+1000)];
        
        [self menuBtnSelect:nButton isSelect:YES];
        
    }
}


-(void)pageControllerSetView:(NSUInteger)index forward:(BOOL)forward{
    UIViewController *vc = [self viewControllerAtIndex:index];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(forward){
            [self.pageController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }else{
            [self.pageController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        }
    });
}

#pragma mark 得到相应的VC对象
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    UIViewController *vc = _viewControllers[index];
    
    return vc;
}

#pragma mark 根据数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(UIViewController *)viewController {
    
    NSUInteger index = [_viewControllers indexOfObject:viewController];
    
    return index;
}

#pragma mark - UIPageViewControllerDataSource

#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    
    NSUInteger index = [self indexOfViewController:(UIViewController *)viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == 0)  {
        //        NSLog(@"左边已经没有了！");
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    
    NSUInteger index = [self indexOfViewController:(UIViewController *)viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == [_menuArray count]) {
        //         NSLog(@"右边已经没有了！");
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

#pragma mark 开始滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    NSUInteger index =  [self indexOfViewController:pendingViewControllers[0]];
    _toPage = index;
}

#pragma mark 结束滚动或翻页的时候触发
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    if (completed)  {
        NSUInteger index =  [self indexOfViewController:previousViewControllers[0]];
        _fromPage = index;
        [self menuSelect:_toPage];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _menuSliderCenter = _menuSlider.center;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offSetX = (scrollView.contentOffset.x-kScreenWidth)/kScreenWidth;
    
    if(offSetX != 0 && _menuSliderCenter.x != 0 && _menuSliderCenter.y != 0){
        _menuSlider.center = CGPointMake(_menuSliderCenter.x + offSetX *  _menuSlider.frame.size.width,_menuSlider.center.y);
        //        NSLog(@"offSetX:%f",offSetX);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
