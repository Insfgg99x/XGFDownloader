# XGFDownloadManager<br>
FGGDownloader的Swift版本，用于断点下载，大文件下载，支持后台下载<br>
<br>
![演示](https://github.com/Insfgg99x/FGGDownloader/blob/master/demo.gif)<br>
<br>
XGFDownloadManager用法简介<br>
---------------------------------------------------------------------------------------------<br>
基于UNSURLConnection封装的断点下载。<br>
<br>
-->1.在项目中导入import XGFDownloadManager 头文件；<br>
-->2.搭建UI时，设置显示进度的UIProgressView的进度值:XGFDownloadManager.sharedManager.lastProgressWithUrl(url)<br>
这个方法的返回值是Float类型的；<br>
设置显示文件大小/文件总大小的Label的文字：XGFDownloadManager.sharedManager.fileSize(url)<br>
<br>
-->3.开始或恢复下载任务的方法：<br>
download(urlString:String, <br>
            toPath: String, <br>
           process:ProcessHandle,<br>
        completion:CompletionHandle,<br>
           failure:FailureHandle<br>
<br>
这个方法包含三个回调代码块，分别是：<br>
<br>
1)下载过程中的回调代码块，带3个参数：下载进度参数progress，已下载文件大小sizeString，文件下载速度speedString；<br>
2)下载成功回调的代码块，没有参数；<br>
3)下载失败的回调代码块，带一个下载错误参数error。<br>

-->4.在下载出错的回调代码块中处理出错信息。在出错的回调代码块中或者暂停下载任务时，<br>
调用XGFDownloaderManager.sharedManager.cancelDownloadTaskWithUrlString(url:String)方法取消/暂停下载任务；<br>
<br>
==============================================================================================<br>
Copyright (c) 2016年 夏桂峰. All rights reserved.<br>


