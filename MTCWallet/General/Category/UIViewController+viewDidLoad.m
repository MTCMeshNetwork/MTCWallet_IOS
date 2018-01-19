//
//  UIViewController+viewDidLoad.m
//  Demo_RuntimeExchangeMethod
//
//  Created by ihefe_Hanrovey on 16/7/18.
//  Copyright © 2016年 Hanrovey. All rights reserved.
//

#import "UIViewController+viewDidLoad.h"
#import <objc/runtime.h>

// pointer of _VIMP by custom
typedef void (* _VIMP)(id, SEL, ...);

@implementation UIViewController (viewDidLoad)

// override viewController load() method
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
        // get system viewDidLoad method
        Method viewDidLoad = class_getInstanceMethod(self, @selector(viewDidLoad));
        
        // get the system implementation of viewDidLoad
        _VIMP viewDidLoad_VIMP = (_VIMP)method_getImplementation(viewDidLoad);
        
        // resetter the  system implementation of viewDidLoad
        method_setImplementation(viewDidLoad, imp_implementationWithBlock(^ (UIViewController *target , SEL action){
        
            // the system viewDidLoad method
            viewDidLoad_VIMP(target , @selector(viewDidLoad));
            if (target.navigationController) {
                UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
                target.navigationItem.backBarButtonItem = item;
            }
            // the new add NSLog method
            //NSLog(@"自定义log :%@ did load",target);
        }));
        
        
    });
    
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method method2 = class_getInstanceMethod([self class], @selector(deallocSwizzle));
    method_exchangeImplementations(method1, method2);
}


- (void)deallocSwizzle
{
    NSLog(@"调试释放内存log，调用相册会闪退，正式需删除 :%@ dealloc",self);
    //调用原生dealloc
    [self deallocSwizzle];
}

@end
