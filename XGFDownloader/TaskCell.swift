//
//  TaskCell.swift
//  XGFDownloader
//
//  Created by 夏桂峰 on 16/6/6.
//  Copyright © 2016年 夏桂峰. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    var downloadBtn:UIButton?
    var progressView:UIProgressView?
    var nameLabel:UILabel?
    var progressLabel:UILabel?
    var sizeLabel:UILabel?
    var speedLabel:UILabel?
    
    var downloadBlock:((sender:UIButton?)->Void)?
    
    func cellWithModel(model:TaskModel) {
        
        self.nameLabel?.text=model.name;
        let exist=NSFileManager.defaultManager().fileExistsAtPath(model.destinationPath!)
        if exist {
            
            let progress=XGFDownloaderManager.sharedManager.lastProgress(model.urlString!)
            progressView?.progress=progress
            sizeLabel?.text=XGFDownloaderManager.sharedManager.filesSize(model.urlString!)
            progressLabel?.text=String(format: "%.1f%%",progress*100)
        }
        if progressView?.progress==1.0 {
            downloadBtn?.setTitle("完成", forState: UIControlState.Normal)
            downloadBtn?.enabled=false
        }
        else if progressView?.progress>0.0 {
            
            downloadBtn?.setTitle("恢复", forState: UIControlState.Normal)
        }
        else{
            downloadBtn?.setTitle("开始", forState: UIControlState.Normal)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel=UILabel()
        nameLabel?.font=UIFont.systemFontOfSize(15)
        nameLabel?.adjustsFontSizeToFitWidth=true
        nameLabel?.frame=CGRectMake(10, 0, kWidth-120, 20)
        
        sizeLabel=UILabel()
        sizeLabel?.font=UIFont.systemFontOfSize(12)
        sizeLabel?.textAlignment=NSTextAlignment.Right
        sizeLabel?.adjustsFontSizeToFitWidth=true
        sizeLabel?.frame=CGRectMake(kWidth-110, 0, 100, 20)
        self.contentView.addSubview(nameLabel!)
        self.contentView.addSubview(sizeLabel!)
        
        downloadBtn=UIButton()
        downloadBtn?.frame=CGRectMake(10, 20, 40, 20)
        downloadBtn?.setTitle("开始", forState: UIControlState.Normal)
        downloadBtn?.titleLabel?.font=UIFont.systemFontOfSize(14)
        downloadBtn?.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        downloadBtn?.addTarget(self, action: #selector(TaskCell.downloadAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.contentView.addSubview(downloadBtn!)
        
        progressView=UIProgressView()
        progressView?.frame=CGRectMake(60, 30, kWidth-120, 10)
        progressView?.progress=0.0
        self.contentView.addSubview(self.progressView!)
        
        progressLabel=UILabel()
        progressLabel?.font=UIFont.systemFontOfSize(12)
        progressLabel?.textAlignment=NSTextAlignment.Right
        progressLabel?.adjustsFontSizeToFitWidth=true
        progressLabel?.frame=CGRectMake(kWidth-60, 20, 50, 20)
        self.contentView.addSubview(progressLabel!)
        
        speedLabel=UILabel()
        speedLabel?.font=UIFont.systemFontOfSize(12)
        speedLabel?.textAlignment=NSTextAlignment.Left
        speedLabel?.frame=CGRectMake(10, 40, 50, 20)
        self.contentView.addSubview(speedLabel!)
        speedLabel?.hidden=true
    }
    
    func downloadAction(sender:UIButton?)  {
        
        if (self.downloadBlock != nil){
            
            self.downloadBlock!(sender: sender)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
