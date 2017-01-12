//
//  CFMenuPageController.h
//  CFMenuPageController
//
//  Created by coful on 17/1/11.
//  Copyright © 2017年 coful. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CFMenuPageController : UIViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (nonatomic,strong) UIPageViewController *pageController;

@property (nonatomic,strong) NSMutableArray *viewControllers;

@property (nonatomic,strong) NSArray *menuArray;

@end
