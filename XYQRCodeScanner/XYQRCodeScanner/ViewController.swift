//
//  ViewController.swift
//  XYQRCodeScanner
//
//  Created by xiaoyi on 2017/6/28.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var QRCodeImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        //生成二维码并显示
        let QRCodePriduce = XYQRCodeGeneration()
       QRCodeImage =   QRCodePriduce.generateQRCode(codeStr:  "http://www.baidu.com")
       //设置二维码颜色
       QRCodeImage = QRCodeImage.setImagePixelColor(colorStr: "068b22", alpha: 1.0)
       //为二维码添加logo
       QRCodeImage = QRCodeImage.addQRCodeImageLogo(logoPicture: #imageLiteral(resourceName: "logo"))!
        
        let QRCodeImageView = UIImageView(frame: CGRect(x: SCREENWIDTH/2 - 200/2, y: SCREENHEIGHT/2 - 200/2, width: 200, height: 200))
        QRCodeImageView.image = QRCodeImage
        
        //长按识别图片当中二维码
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(readImageQRInfoAct(sender:)))
          QRCodeImageView.isUserInteractionEnabled = true
          QRCodeImageView.addGestureRecognizer(longPressGesture)
        self.view.addSubview(QRCodeImageView)

        //点击可跳转到扫码界面
        let btn = UIButton(frame: CGRect(x:SCREENWIDTH/2 - 200/2 , y: QRCodeImageView.frame.maxY + 40, width: 200, height: 40))
        btn.addTarget(self, action: #selector(btnAct), for: .touchUpInside)
        btn.setTitle("扫码(长按图片自动识别图片二维码)", for: .normal)
        btn.setTitleColor(UIColor.yellow, for: .normal)
        btn.backgroundColor = UIColor.green
        self.view.addSubview(btn)

        // Do any additional setup after loading the view, typically from a nib.
    }

    
    func readImageQRInfoAct(sender:UILongPressGestureRecognizer){
        if sender.state == .began{
        if let QRCodeImageInfo = QRCodeImage.readImageQRCodeInfo(){
            print(QRCodeImageInfo)
        }
        }
    }
    
    func btnAct(){
        self.present(XYQRCodeScannerViewController(), animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

