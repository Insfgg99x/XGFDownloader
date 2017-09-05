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
    
    var downloadBlock:((_ sender:UIButton?)->Void)?
    
    func cellWithModel(model:TaskModel) {
        
        self.nameLabel?.text=model.name;
        let exist=FileManager.default.fileExists(atPath: model.destinationPath!)
        if exist {
            
            let progress=XGFDownloaderManager.shared.lastProgress(urlString: model.urlString!)
            progressView?.progress=progress
            sizeLabel?.text=XGFDownloaderManager.shared.filesSize(urlString: model.urlString!)
            progressLabel?.text=String(format: "%.1f%%",progress*100)
        }
        if progressView?.progress==1.0 {
            downloadBtn?.setTitle("完成", for: UIControlState.normal)
            downloadBtn?.isEnabled=false
        }
        else if (progressView?.progress)!>Float(0) {
            
            downloadBtn?.setTitle("恢复", for: UIControlState.normal)
        }
        else{
            downloadBtn?.setTitle("开始", for: UIControlState.normal)
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameLabel=UILabel()
        nameLabel?.font=UIFont.systemFont(ofSize: 15)
        nameLabel?.adjustsFontSizeToFitWidth=true
        nameLabel?.frame=CGRect(x: 10, y: 0, width: kWidth-120, height: 20)
        
        sizeLabel=UILabel()
        sizeLabel?.font=UIFont.systemFont(ofSize: 12)
        sizeLabel?.textAlignment=NSTextAlignment.right
        sizeLabel?.adjustsFontSizeToFitWidth=true
        sizeLabel?.frame=CGRect(x: kWidth-110, y: 0, width: 100, height: 20)
        self.contentView.addSubview(nameLabel!)
        self.contentView.addSubview(sizeLabel!)
        
        downloadBtn=UIButton()
        downloadBtn?.frame=CGRect(x: 10, y: 20, width: 40, height: 20)
        downloadBtn?.setTitle("开始", for: UIControlState.normal)
        downloadBtn?.titleLabel?.font=UIFont.systemFont(ofSize: 14)
        downloadBtn?.setTitleColor(UIColor.blue, for: UIControlState.normal)
        downloadBtn?.addTarget(self, action: #selector(downloadAction(sender:)), for: .touchUpInside)
        self.contentView.addSubview(downloadBtn!)
        
        progressView=UIProgressView()
        progressView?.frame=CGRect(x: 60, y: 30, width: kWidth-120, height: 10)
        progressView?.progress=0.0
        self.contentView.addSubview(self.progressView!)
        
        progressLabel=UILabel()
        progressLabel?.font=UIFont.systemFont(ofSize: 12)
        progressLabel?.textAlignment=NSTextAlignment.right
        progressLabel?.adjustsFontSizeToFitWidth=true
        progressLabel?.frame=CGRect(x: kWidth-60, y: 20, width: 50, height: 20)
        self.contentView.addSubview(progressLabel!)
        
        speedLabel=UILabel()
        speedLabel?.font=UIFont.systemFont(ofSize: 12)
        speedLabel?.textAlignment=NSTextAlignment.left
        speedLabel?.frame=CGRect(x: 10, y: 40, width: 50, height: 20)
        self.contentView.addSubview(speedLabel!)
        speedLabel?.isHidden=true
    }
    
    func downloadAction(sender:UIButton?)  {
        
        if (self.downloadBlock != nil){
            
            self.downloadBlock!(sender)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
