//
//  ViewController.m
//  Choose
//
//  Created by Jianzhimao on 2020/6/9.
//  Copyright © 2020 Jianzhimao. All rights reserved.
//

#import "ViewController.h"
#import "choose.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@" %@" , [choose choose:@"ViewController"]);
    NSLog(@" %@" , [choose choose:@"AppDelegate"]);
}

@end



