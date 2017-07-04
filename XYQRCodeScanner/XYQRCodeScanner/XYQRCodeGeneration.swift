//
//  XYQRCodeGeneration.swift
//  XYQRCodeScanner
//
//  Created by xiaoyi on 2017/7/3.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class XYQRCodeGeneration: NSObject {
    
    
    //MARK: - 生成二维码
   public func generateQRCode(codeStr:String) -> UIImage{
        let qrCodeImage = self.createNonInterpolatedUIImageFromCIImage(image: createQRForStr(str: codeStr)!, size: 400)
        return qrCodeImage!
    }
    
    
   //MARK: - 通过字符串创建QR
   private func createQRForStr(str:String) -> CIImage?{
        let stringData = str.data(using: .utf8)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("M", forKey: "inputCorrectionLevel")
        return qrFilter?.outputImage
    }
    
    
    
    
  //MARK: - 创建更清晰的二维码图片
  private  func createNonInterpolatedUIImageFromCIImage(image:CIImage,size:CGFloat) -> UIImage?{
        let extent:CGRect = image.extent.integral
        let scale:CGFloat =  (size/extent.width <= size/extent.height) ? size/extent.width:size/extent.height
        
        let width:size_t = size_t(extent.width * scale)
        let height:size_t = size_t(extent.height * scale)
        let cs = CGColorSpaceCreateDeviceGray()
        
        let bitmapRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs,bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        
        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(image, from: extent)
        
        bitmapRef?.interpolationQuality = CGInterpolationQuality(rawValue: CGInterpolationQuality.none.rawValue)!
        bitmapRef?.scaleBy(x: scale, y: scale)
        
        bitmapRef?.draw(bitmapImage!, in: extent)
        
        let scaledImage = bitmapRef!.makeImage()
        
        return UIImage(cgImage: scaledImage!)
    }
    


}


extension UIImage{
    
    /*
     //MARK: - 获取图片的某像素颜色
     func getPixelColor(pos:CGPoint)->(alpha: CGFloat, red: CGFloat, green: CGFloat,blue:CGFloat){
     //let pixelData=CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
     let pixelData=self.cgImage!.dataProvider!.data
     let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
     let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
     
     let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
     let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
     let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
     let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
     
     return (a,r,g,b)
     }
     */
    
    //MARK: - 设置二维码的颜色，此处将黑色二维码改成需要的颜色，背景为透明灰色
    func  setImagePixelColor(colorStr:String,alpha:CGFloat) -> UIImage{
        var imageRGBA = RGBAImage(image: self)!
        let rgbaPrameter = XYColorStringToRGB(colorName: colorStr, alpha: alpha)
        
        for y in 0..<imageRGBA.height{
            for x in 0..<imageRGBA.width{
                let index = y * imageRGBA.width + x
                var pixel = imageRGBA.pixels[index]
                if pixel.red == 0 && pixel.blue == 0 && pixel.green == 0{
                    
                    pixel.red = rgbaPrameter.r
                    pixel.blue = rgbaPrameter.g
                    pixel.green = rgbaPrameter.b
                    pixel.alpha = UInt8(alpha * 255)
                    
                    imageRGBA.pixels[index] = pixel
                }else if  pixel.red == 255 && pixel.blue == 255 && pixel.green == 255{
                    pixel.red = 170
                    pixel.blue = 170
                    pixel.green = 170
                    pixel.alpha = 200
                    imageRGBA.pixels[index] = pixel
                }
            }
        }
        return imageRGBA.toUIImage()!
    }
    
    
    //MARK: - 读取图片当中的二维码信息
    public func readImageQRCodeInfo() -> String?{
        let data = UIImagePNGRepresentation(self)
        let ciImage = CIImage(data: data!)
        
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        if let detector = qrDetector {
            //识别到的图片数据数组
            let features = detector.features(in: ciImage!)
            //识别二维码正常就一条数据,所以取一条
            print(features.count)
            if features.count > 0{
                if let decode = (features.first as? CIQRCodeFeature)?.messageString{
                    return decode
                }
            }
            
        }
        return nil
        
    }
    
    
    
    
}


//MARK: - 颜色字符串转RGBA值
func XYColorStringToRGB(colorName:String,alpha:CGFloat) -> (r:UInt8,g:UInt8,b:UInt8,alpha:CGFloat){
    var cString:String = colorName.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
    if (cString.hasPrefix("#")) {
        cString = (cString as NSString).substring(from: 1)
    }
    if (colorName.characters.count != 6) {
        return (170,170,170,1)
    }
    let rString = (cString as NSString).substring(to: 2)
    let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
    let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)
    return (UInt8(r),UInt8(g),UInt8(b),alpha)
}


