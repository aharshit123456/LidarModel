//
//  ContentView.swift
//  LidarModel
//
//  Created by smlab_drone on 05/05/24.
//

import SwiftUI

struct ContentView: View {
    @State private var submittedExportRequest = false
    @State private var exportedUrl :URL?
    @State private var submittedName = ""
    @State private var isShowingActivityView = false
    @State var fileUrl :URL?
    
    var body: some View {
        HStack{
            FetchModelView()
            VStack {
                ARWrapper(submittedExportRequest: $submittedExportRequest, submittedName: $submittedName)
                Button("Export"){
                    alertTF(title: "Save File", message: "Enter your file name", hintText: "my_filename", primaryTitle: "Save", secondaryTitle: "Cancel"){text in
                        submittedName = text
                        submittedExportRequest.toggle()
                        isShowingActivityView = true
                        fileUrl = exportedUrl

                    } secondaryAction: {
                        print("Cancelled")
                    }
                }.padding()
                Button("Test Storage") {
                    guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        fatalError("Could not access the Documents directory")
                    }
                    let fileURL = documentsURL.appendingPathComponent("example.txt")
                    do {
                        let data = "Hello, World! I AM BORED.".data(using: .utf8)
                        try data?.write(to: fileURL)
                        print("File saved successfully at: \(fileURL)")
                    } catch {
                        print("Error saving file: \(error)")
                    }
                    
//                    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//                    
//                    // Set the source view for popover presentation controller
//                    activityViewController.popoverPresentationController?.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
//                    
//                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                }

//                Button("Test Storage"){
//                    guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//                        fatalError("Could not access the Documents directory")
//                    }
//                    let fileURL = documentsURL.appendingPathComponent("example.txt")
//                    do {
//                        let data = "Hello, World!".data(using: .utf8)
//                        try data?.write(to: fileURL)
//                        print("File saved successfully at: \(fileURL)")
//                    } catch {
//                        print("Error saving file: \(error)")
//                    }
//                    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//                    
//                    activityViewController.popoverPresentationController?.sourceView = view // Replace 'view' with the appropriate source view
//
//                    rootController().present(activityViewController, animated: true, completion: nil)
//
//                    
//                }
//                    guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//                        fatalError("Could not access the Documents directory")
//                    }
//                    
//                    do{
//                        try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)}catch{print("Errr : \(error)")}
//
//                    let fileURL = documentsURL.appendingPathComponent("example.txt")
//
//                    do {
//                        let data = "Hello, World!".data(using: .utf8)
//                        try data?.write(to: fileURL)
//                        print("File saved successfully at: \(fileURL)")
//                    } catch {
//                        print("Error saving file: \(error)")
//                    }
//                    
//                    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//                    rootController().present(activityViewController, animated: true, completion: nil)
//
//                }
            }
        }
        .padding()
        .sheet(isPresented: $isShowingActivityView) {
            //            ActivityViewController(fileURL: fileURL ?? URL(fileURLWithPath: "doyouhateme/file.txt"))
            
                        let defaultUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("OBJ_FILES").appendingPathComponent("file1234.obj")
            
                        ActivityViewController(fileURL: fileUrl ?? defaultUrl)
                        //        }
                    }
    }
}

#Preview {
    ContentView()
}

struct ActivityViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = context.coordinator.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update the view controller if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var parent: ActivityViewController

        init(_ parent: ActivityViewController) {
            self.parent = parent
        }

        var view: UIView!

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            // Handle the sheet dismissal if needed
        }
    }
}
extension View{
    func alertTF(title: String, message: String, hintText:String, primaryTitle: String, secondaryTitle:String, primaryAction: @escaping(String)->(), secondaryAction: @escaping()->()){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addTextField{field in
            field.placeholder = hintText
        }
        
        alert.addAction(.init(title: secondaryTitle, style:  .cancel, handler: {_ in
            secondaryAction()
        })
        )
        
        alert.addAction(.init(title: primaryTitle, style: .default, handler: {_ in
            if let text = alert.textFields?[0].text{
                primaryAction(text)
            }else{
                primaryAction("")
            }
            
        }))
        
        rootController().present(alert, animated:true, completion: nil)
    }
    
    func rootController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else{
            return.init()
        }
        
        return root
    }
}
