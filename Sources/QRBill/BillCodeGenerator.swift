import Foundation
import CoreImage
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import QRCodeGenerator

public struct BillCodeGenerator
{
    #if canImport(AppKit)
    public typealias CrossplatformImage = NSImage
    #elseif canImport(UIKit)
    public typealias CrossplatformImage = UIImage
    #endif
    
    public enum Error : Swift.Error {
        case failedToGenerateQrCode
    }
    
    public static func createSVGString(from data:Data, border:Int = 1) throws -> String
    {
        try data.validate()
        let inputMessage = data.qrData.joined(separator: "\r\n")

        let qr = try QRCode.encode(text: inputMessage, ecl: .medium)
        return qr.toSVGString(border: border)
    }
    
    public static func createCiImage(from data:Data, scaling:Double = 20) throws -> CIImage
    {
        try data.validate()
        let inputMessage = data.qrData.joined(separator: "\r\n")

        let filter = CIFilter(name: "CIQRCodeGenerator")!
        filter.setValue(inputMessage.data(using: .isoLatin1), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        let transform = CGAffineTransform(scaleX: scaling, y: scaling)
        
        guard let ciImage = filter.outputImage else {
            throw Error.failedToGenerateQrCode
        }

        return ciImage.transformed(by: transform)
    }

    public static func createImage(from data:Data) throws -> CrossplatformImage
    {
        let ciImage = try createCiImage(from: data)

#if canImport(AppKit)
        let representation = NSCIImageRep(ciImage: ciImage)
        let image = NSImage(size: ciImage.extent.size)
        image.addRepresentation(representation)
#elseif canImport(UIKit)
        let image = UIImage(ciImage:ciImage)
#endif

        return image
    }

}
