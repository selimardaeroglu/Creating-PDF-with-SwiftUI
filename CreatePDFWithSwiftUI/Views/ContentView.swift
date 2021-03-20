
import SwiftUI
import PhotosUI

struct PDFSwiftUI: View {
    @State private var img: [UIImage] = []
    @State private var picker = false
    @State private var showPDF = false
    @State private var data: [Data] = []
    @State private var sharePDF = false
    
    var body: some View {
        Form{
            
            Section{
                VStack{
                    Button(action: {self.picker.toggle()}, label: {
                        Text("Select Image")
                    })
                }
            }
            
            if img.first != nil {
                Section{
                    Image(uiImage: img.first!)
                        .resizable()
                        .frame(height: UIScreen.main.bounds.height/3)
                        .padding(.horizontal)
                }
            }
            
            Section{
                Button(action: {
                    
                    for image in img {
                    self.showPDF.toggle()
                        data.append(PDFCreator(image: image).createFlyer())
                    }
                    
                }, label: {
                    Text("Create PDF")
                }).fullScreenCover(isPresented: $showPDF, content: {
                    CreatedPDFView(data: $data)
                })
            }
            
            Section{
                Button(action: {
                    
                    for image in img {
                    self.sharePDF.toggle()
                        data.append(PDFCreator(image: image).createFlyer())
                    }
                    
                }, label: {
                    Text("Share PDF")
                }).fullScreenCover(isPresented: $sharePDF, content: {
                    sharePDFView(data: $data)
                })
            }
            
        }.sheet(isPresented: $picker, content: {
            PhotoPickerForPDF(image: $img, picker: $picker)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PDFSwiftUI()
    }
}

struct PhotoPickerForPDF: UIViewControllerRepresentable {
    @Binding var image: [UIImage]
    @Binding var picker: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        //
    }
    
    class Coordinator: NSObject,PHPickerViewControllerDelegate {
        
        var parent: PhotoPickerForPDF
        
        init(_ parent: PhotoPickerForPDF) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.parent.picker.toggle()
            
            for res in results {
                 let itemProvider = res.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self){
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] item, err in
                        if let err = err {
                            print(err)
                        } else{
                            if let self = self, let image = item as? UIImage {
                                self.parent.image.append(image)
                            }
                        }
                    }
                }
            
        }
        }
        
    }
}

import UIKit
import PDFKit

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






struct CreatedPDFView: UIViewRepresentable {
    @Binding var data: [Data]
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        for pdf in data {
            pdfView.document = PDFDocument(data: pdf)
            pdfView.autoScales = true
        }
        
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        //
    }
    
}


struct sharePDFView: UIViewControllerRepresentable {
    @Binding var data: [Data]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: data, applicationActivities: nil)
    }
 
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        //
    }
    
}
