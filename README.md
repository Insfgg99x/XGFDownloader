# XGFDownloadManager<br>
SwiftEdition for FGGDownloader ,used for breaking point downloading,background downloading supported.
FGGDownloader的Swift版本，用于断点下载，支持后台下载<br>
<br>
![演示](https://github.com/Insfgg99x/XGFDownloader/blob/master/demo.gif)<br>
##Introduction
A framework used for resume from breaking point downloading based on NSURLConnection with background downloading supported<br>
一个基于NSURLConnection，用于断点下载及支持后台下载的框架

#Install:
Cocopods:
`pod 'FGGDownloader', '~> 1.0'`
Manual:
download [FGGDownloader](https://github.com/Insfgg99x/FGGDownloader.git) and drag it into your project。
#Useage:
1.Import XGFDownloadManager header file<br>
  在项目中导入import XGFDownloadManager 头文件；<br>
<br>
2.SET progress in the function create UI with: `XGFDownloadManager.sharedManager.lastProgressWithUrl(url)`<br>
 搭建UI时，设置显示进度的UIProgressView的进度值:`XGFDownloadManager.sharedManager.lastProgressWithUrl(url)`<br>
<br>
`lastProgressWithUrl(url)`returns a float value between 0.0 an 1.00.<br>
`lastProgressWithUrl(url)`方法的返回一个在0.0到1.0之间的Float类型的值；<br>
<br>
3.Set file size/expect file total size label with text from: `XGFDownloadManager.sharedManager.fileSize(url)`<br>
  设置显示文件大小/文件总大小的Label的文字：`XGFDownloadManager.sharedManager.fileSize(url)`<br>
<br>
4.Resume or start downloading with: <br>
`
download(urlString:String, 
            toPath: String, 
           process:ProcessHandle,
        completion:CompletionHandle,
           failure:FailureHandle
`
  开始或恢复下载任务的方法：<br>
`
download(urlString:String,
            toPath: String, 
           process:ProcessHandle,
        completion:CompletionHandle,
           failure:FailureHandle
`
<br>
This function includes 3 call back blocks as follow:<br>
这个方法包含三个回调代码块，分别是：<br>
<br>
1)during downloading call back block with 3 params: download progress->progress, downloaded part size->sizeString and downloading speed->speedString<br>
  下载过程中的回调代码块，带3个参数：下载进度参数progress，已下载文件大小sizeString，文件下载速度speedString；<br>
2)download finished call back block with no params<br>
  下载成功回调的代码块，没有参数；<br>
3)downloading failed with error call back block with a param: error->error<br>
  下载失败的回调代码块，带一个下载错误参数error。<br>
<br>
4.Use `XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString(url:String)` in the pause downloading function or in downloading failed call back block to cancel download task.<br>
  在下载出错的回调代码块中处理出错信息。在出错的回调代码块中或者暂停下载任务时，调用`XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString(url:String)`方法取消/暂停下载任务；<br>
<br>