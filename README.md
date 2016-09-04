# XGFDownloadManager<br>
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/SnapKit.svg)](https://img.shields.io/cocoapods/v/SnapKit.svg)
[![Pod Version](http://img.shields.io/cocoapods/v/SDWebImage.svg?style=flat)](http://cocoadocs.org/docsets/XGFDownloader/)
[![Pod Platform](http://img.shields.io/cocoapods/p/SDWebImage.svg?style=flat)](http://cocoadocs.org/docsets/XGFDownloader/)
######Swift Edition for FGGDownloader, A framework used for resume from breaking point downloading based on NSURLConnection with background downloading supported.
######FGGDownloader的swift版本一个基于NSURLConnection，用于断点下载及支持后台下载的框架

![演示](https://github.com/Insfgg99x/XGFDownloader/blob/master/demo.gif)<br>
<br>
#Install 安装:
Cocopods:
`use_frameworks!`<br>
`pod 'XGFDownloader', '~> 1.1'`<br>
<br>
Manual:
download [FGGDownloader](https://github.com/Insfgg99x/FGGDownloader.git) and drag it into your project。
#Useage 使用:
1.Import XGFDownloadManager header file.在项目中导入import XGFDownloadManager 头文件。<br>

2.SET progress in the function create UI with: `XGFDownloadManager.sharedManager.lastProgressWithUrl(url)`搭建UI时，设置显示进度的UIProgressView的进值:`XGFDownloadManager.sharedManager.lastProgressWithUrl(url)`<br>
<br>
`lastProgressWithUrl(url)`returns a float value between 0.0 an 1.00.`lastProgressWithUrl(url)`方法的返回一个在0.0到1.0之间的Float类型的值；<br>
<br>
3.Set file size/expect file total size label with text from: `XGFDownloadManager.sharedManager.fileSize(url)`设置显示文件大小/文件总大小的Label的文字：`XGFDownloadManager.sharedManager.fileSize(url)`<br>

4.Resume or start downloading with. 开始或恢复下载任务的方法:
`download(urlString:String,  toPath: String, process:ProcessHandle, completion:CompletionHandle, failure:FailureHandle)`
<br>
<pre>This function includes 3 call back blocks as follow:这个方法包含三个回调代码块，分别是：
<br>
1)during downloading call back block with 3 params: download progress->progress, downloaded part size->sizeString and downloading speed->speedString.
下载过程中的回调代码块，带3个参数：下载进度参数progress，已下载文件大小sizeString，文件下载速度speedString；
<br>
2)download finished call back block with no params.下载成功回调的代码块，没有参数；
<br>
3)downloading failed with error call back block with a param: error->error.下载失败的回调代码块，带一个下载错误参数error。
</pre>
#5.Explain 说明:
`XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString(url:String)` in the pause downloading function or in downloading failed call back block to cancel download task.
在下载出错的回调代码块中处理出错信息。在出错的回调代码块中或者暂停下载任务时，调用`XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString(url:String)`方法取消/暂停下载任务；