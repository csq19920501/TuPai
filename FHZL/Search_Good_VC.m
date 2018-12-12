//
//  Search_Good_VC.m
//  FHZL
//
//  Created by hk on 2018/11/26.
//  Copyright © 2018年 hk. All rights reserved.
//

#import "Search_Good_VC.h"

@interface Search_Good_VC ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@end

@implementation Search_Good_VC
- (IBAction)cancelClick:(id)sender {
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)searchButClick:(id)sender {
    UIButton *but = (UIButton *)sender;
    if (self.serchBlock) {
        self.serchBlock(but.titleLabel.text);
    }
    [self cancelClick:nil];
}
- (IBAction)deleClick:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.topConstraint.constant = kTopHeight;
    self.navigationController.navigationBar.hidden = YES;
    self.editing = YES;
}
#pragma mark -- serachDele
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    if (self.serchBlock) {
        self.serchBlock(searchBar.text);
    }
    [self cancelClick:nil];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!kStringIsEmpty(searchBar.text)) {
        if (self.serchBlock) {
            self.serchBlock(searchBar.text);
        }
        [self cancelClick:nil];
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
