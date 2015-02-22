//
//  BLTIntroViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 2/21/15.
//  Copyright (c) 2015 Shikhar Mohan. All rights reserved.
//

#import "BLTIntroViewController.h"

@interface BLTIntroViewController ()
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation BLTIntroViewController{

    CGSize iOSScreenSize;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    iOSScreenSize = [[UIScreen mainScreen] bounds].size;
    
    
    
    // Do any additional setup after loading the view.
    _pageTitles = @[@"", @"Drink spontaneously", @"Never drink alone", @"Nudge your friends"];
    _pageSubtitles=@[@"", @"Stay in the know with daily local drink deals.", @"See friends that are interested in going with less hassle.", @"Invite your friends out with a simple gesture."];
    _pageImages = @[@"", @"appdesign-Slide2@3x.jpg", @"appdesign-Slide3@3x.jpg", @"appdesign-Slide4@3x.jpg"];
    
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    self.pageViewController.dataSource = self;
    BLTLoginViewController *loginViewController = (BLTLoginViewController *)[self viewControllerAtIndex:0];
    NSArray *viewControllers = @[loginViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+ 37);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:self.pageControl];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    if(index == 0){
        BLTLoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginController"];
        loginController.pageIndex = 0;
        return loginController;
    }

    BLTIntroPagesViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.subtitleText = self.pageSubtitles[index];
    pageContentViewController.pageIndex = index;
    // Create a new view controller and pass suitable data.
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BLTIntroPagesViewController*) viewController).pageIndex;
     [self.pageControl setCurrentPage:index];
    [self.pageControl updateCurrentPageDisplay];

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BLTIntroPagesViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
      [self.pageControl setCurrentPage:index];
    [self.pageControl updateCurrentPageDisplay];
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    [self.pageControl setNumberOfPages:4];
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
