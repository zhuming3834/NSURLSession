//
//  ViewController.m
//  NSURLSession
//
//  Created by HGDQ on 15/10/28.
//  Copyright (c) 2015年 HGDQ. All rights reserved.
//

#import "ViewController.h"
#define URLPATH  @"http://img6.faloo.com/Picture/0x0/0/747/747488.jpg"

//#define URLPATH  @"http://ftp-idc.pconline.com.cn/ceb7f6f871c6ec356127881b13eb8e3e/pub/download/201010/WPS2015.exe"

//http://ftp-idc.pconline.com.cn/ceb7f6f871c6ec356127881b13eb8e3e/pub/download/201010/WPS2015.exe
@interface ViewController ()<NSURLSessionDownloadDelegate>
{
	NSURLSessionDownloadTask *_task; //下载任务
	NSData *_resumeData;             //下载的数据
	NSURLSession *_session;          //session
	NSURL *_url;                     //下载链接
	NSData *_downloadData;           //暂存下载的数据
	CGFloat _totalBytes;             //数据的总得byte
	CGFloat _currentBytes;           //当前下载了的byte
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self systemInit];
	// Do any additional setup after loading the view, typically from a nib.
}
/**
 *  初始化相关对象
 */
- (void)systemInit{
	//设置进度条初始值
	self.progressView.progress = 0;
	_url = [NSURL URLWithString:URLPATH];
	NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
	_session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}
/**
 *  开始下载按钮
 *
 *  @param sender sender description
 */
- (IBAction)startButton:(id)sender {
	NSLog(@"开始下载");
	_task = [_session downloadTaskWithURL:_url];
	[_task resume];
}
/**
 *  暂停下载按钮
 *
 *  @param sender sender description
 */
- (IBAction)pauseButton:(id)sender {
	NSLog(@"暂停下载");
	[_task cancelByProducingResumeData:^(NSData *resumeData) {
		_downloadData = resumeData;
		_task = nil;
	}];
}
/**
 *  继续下载
 *
 *  @param sender sender description
 */
- (IBAction)resumeButton:(id)sender {
	NSLog(@"继续下载");
	if (!_task) {
		if (_downloadData) {
			_task = [_session downloadTaskWithResumeData:_downloadData];
		}
		else{
			_task = [_session downloadTaskWithURL:_url];
		}
	}
	[_task resume];
}
#pragma mark - 实现NSURLSessionDownloadDelegate协议方法
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
	NSLog(@"下载完成");
	NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
	NSString *filePath = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
	NSFileManager *fileManage = [NSFileManager defaultManager];
	BOOL success = [fileManage moveItemAtPath:location.path toPath:filePath error:nil];
	self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
	if (success) {
		dispatch_async(dispatch_get_main_queue(), ^{
			self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
		});
	}
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
	  didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
	NSLog(@"下载中。。。");
	_currentBytes = totalBytesWritten;
	_totalBytes = totalBytesExpectedToWrite;
	CGFloat progress = totalBytesWritten/totalBytesExpectedToWrite;
	NSString *currentText = [NSString stringWithFormat:@"%.2fMB/%.2fMB",_currentBytes/1024/1024,_totalBytes/1024/1024];
	NSString *proText = [NSString stringWithFormat:@"%.2f%%",((float)totalBytesWritten/totalBytesExpectedToWrite)*100];
	dispatch_async(dispatch_get_main_queue(), ^{
		self.progressView.progress = progress;
		self.progressLabel.text = proText;
		self.currentLabel.text = currentText;
	});
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end

















