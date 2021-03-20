//
//  PDFCreator .swift
//  CreatePDFWithSwiftUI
//
//  Created by Selim Arda Eroğlu on 14.03.2021.
//

import PDFKit
import SwiftUI


class PDFCreator: NSObject {
    let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func createFlyer() -> Data {
        // 1
        let pdfMetaData = [
            kCGPDFContextCreator: "Flyer Builder",
            kCGPDFContextAuthor: "raywenderlich.com",
            kCGPDFContextTitle: "Title"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 2
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // 4
        let data = renderer.pdfData { (context) in
            // 5
            context.beginPage()
            // 6
            let imageBottom = addImage(pageRect: pageRect, imageTop: pageRect.midY)
            
        }
        
        
        return data
    }
    
    
    func addImage(pageRect: CGRect, imageTop: CGFloat) -> CGFloat {
        // 1
        let maxHeight = pageRect.height * 0.4
        let maxWidth = pageRect.width * 0.8
        // 2
        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        // 3
        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        // 4
        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageRect = CGRect(x: imageX, y: imageTop,
                               width: scaledWidth, height: scaledHeight)
        // 5
        image.draw(in: imageRect)
        
        
        return imageRect.origin.y + imageRect.size.height
    }
}
