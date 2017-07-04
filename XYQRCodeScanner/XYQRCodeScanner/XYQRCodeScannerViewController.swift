//
//  XYQRCodeScannerViewController.swift
//  XYQRCodeScanner
//
//  Created by xiaoyi on 2017/7/3.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit
import AVFoundation

let SCREENWIDTH = UIScreen.main.bounds.size.width
let SCREENHEIGHT = UIScreen.main.bounds.size.height



class XYQRCodeScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    private let toTop = (SCREENHEIGHT - 220)/2
    private let toLeft = (SCREENWIDTH - 220)/2
    
    //扫描动画定时器
    private var scannerTimer:Timer?
    //用以判断上下扫描使用
    private var isNeedUpScanner:Bool = false
    //动画ImageView
    private var animationImage:UIImageView!
    
    private var device:AVCaptureDevice!
    private var input:AVCaptureDeviceInput!
    private var output:AVCaptureMetadataOutput!
    private var session:AVCaptureSession!
    private var preview:AVCaptureVideoPreviewLayer!
    
    //遮罩层
    var maskLayer:CAShapeLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        addMaskLayer()
        creatScannerAnimation()
        creatScanner()
        
        // Do any additional setup after loading the view.
    }
    
    
    //叠加区域图片及上下扫描动画
    private func creatScannerAnimation(){
        //叠加区域图片
        let ScannerImageView = UIImageView(frame: CGRect(x:toLeft, y: toTop, width: 220, height: 220))
        ScannerImageView.image = #imageLiteral(resourceName: "scannerRect")
        self.view.addSubview(ScannerImageView)
        //增加扫描动画
        animationImage = UIImageView(frame: CGRect(x:toLeft, y: toTop+10, width: 220, height: 2))
        animationImage.image = #imageLiteral(resourceName: "scannerLine")
        self.view.addSubview(animationImage)
        //scannerTimer = Timer(timeInterval: 0.3, target: self, selector: #selector(scannerTimerAct), userInfo: nil, repeats: true)
        
        scannerTimer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(scannerTimerAct), userInfo: nil, repeats: true)
    }
    
    
    //MARK: - 动画扫描
    func scannerTimerAct(){
        if !isNeedUpScanner {
            animationImage.frame.origin.y += CGFloat(2)
            if animationImage.frame.origin.y >= toTop + 210{
                isNeedUpScanner = true
            }
        }else{
            animationImage.frame.origin.y -= CGFloat(2)
            if animationImage.frame.origin.y <= toTop + 10{
                isNeedUpScanner = false
            }
        }
        
        
    }
    
    
    //MARK: - 创建扫描器
    private func creatScanner(){
        //创建
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        input = try! AVCaptureDeviceInput(device: self.device)
        output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session = AVCaptureSession()
        //高质量采集率
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        //连接输入与输出
        if session.canAddInput(input){
            session.addInput(input)
        }
        if session.canAddOutput(output){
            session.addOutput(output)
        }
        //设置条码类型
        //仅二维码
        //output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        //条形码加上二维码
        output.metadataObjectTypes =  [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code]
        
        //设置扫描区域，这里设置的是比例
        let toTopPercent = toTop/SCREENHEIGHT
        let toLeftPercent = toLeft/SCREENWIDTH
        let widthPercent = 220/SCREENWIDTH
        let heightPercent = 220/SCREENHEIGHT
        //注意，这里需要将x,y坐标互换，width和height互换
        output.rectOfInterest = CGRect(x: toTopPercent, y: toLeftPercent, width: heightPercent, height: widthPercent)
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(preview, at: 0)
        
        
        //开始扫描
        session.startRunning()
        
    }
    
    
    //MARK: - 增加遮罩层
    private func  addMaskLayer(){
        //遮罩矩形
        let showRect:CGRect = CGRect(x:toLeft, y: toTop, width: 220, height: 220)
        
        maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(showRect)
        path.addRect(CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT))
        //kCAFillRuleEvenOdd：奇偶规则，当这个点作任意方法的射线，射线和路径的交点数量是奇数则认为点在内部.内部镂空
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.path = path
        maskLayer.fillColor = UIColor.black.cgColor
        //不透明度
        maskLayer.opacity = 0.6
        maskLayer.setNeedsDisplay()
        self.view.layer.addSublayer(maskLayer)
        
        
        
    }
    
    //MARK: - 实现AVCaptureMetadataOutputObjectsDelegate协议
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var codeStr:String!
        if metadataObjects.count > 0{
            session.stopRunning()
            scannerTimer?.invalidate()
            scannerTimer = nil
            if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject{
                codeStr = metadataObject.stringValue
                scannerSuccessAct(str: codeStr)
            }
            
        }
    }
    
    
    //MARK: - 扫码成功后操作
    public func scannerSuccessAct(str:String){
        
        let alertVC = UIAlertController(title: "扫描结果", message: str, preferredStyle: .alert)
        let alertAct = UIAlertAction(title: "好的", style: .default) { (act) in
            
            if let scannerUrl = URL(string:str) {
                UIApplication.shared.open(scannerUrl, options: [ : ], completionHandler: nil)
            }
            
            
        }
        alertVC.addAction(alertAct)
        self.present(alertVC, animated: true, completion: nil)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
