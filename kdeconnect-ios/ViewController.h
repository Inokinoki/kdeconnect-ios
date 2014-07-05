//
//  ViewController.h
//  kdeconnect-ios
//
//  Created by yangqiao on 5/2/14.
//  Copyright (c) 2014 yangqiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkPackage.h"
#import "BackgroundService.h"
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]

@interface ViewController : UIViewController<backgroundServiceDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *_tableView;

@end