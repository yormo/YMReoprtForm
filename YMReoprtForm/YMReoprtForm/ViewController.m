//
//  ViewController.m
//  YMReoprtForm
//
//  Created by 含包阁 on 2019/11/11.
//  Copyright © 2019 含包阁. All rights reserved.
//

#import "ViewController.h"
#import "YMReportViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)report:(id)sender {
    YMReportViewController *vc = [[YMReportViewController alloc] initWithNibName:@"YMReportViewController" bundle:[NSBundle mainBundle]];
     [self.navigationController pushViewController:vc animated:YES];
}

@end
