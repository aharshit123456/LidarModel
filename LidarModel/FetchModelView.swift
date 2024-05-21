//
//  FetchModelView.swift
//  LidarModel
//
//  Created by smlab_drone on 10/05/24.
//

import SwiftUI
import SceneKit

class CurrentlyDisplaying: ObservableObject{
    @Published var fileName = ""
}

struct FetchModelView: View {
    @StateObject private var currentlyDisplaying = CurrentlyDisplaying()
    @State private var fileNames : [String] = []
//    @State private var fileName = ""
    @State private var fullScreen = false
    var body: some View {
        VStack{
            List(fileNames, id: \.self){fileName in
                Button(action: {
                    self.currentlyDisplaying.fileName = fileName
//                    self.fileName = fileName
                    self.fullScreen.toggle()
                }){
                    HStack{
                        Text(fileName)
                        Spacer()
                        Image(systemName: "eye.fill")
                    }
                }
                .swipeActions(edge: .trailing){
                    Button(role: .destructive, action:{
                        removeFile(fileName: fileName)
                        withAnimation{
                            fetchFiles()
                        }
                    }){
                        Label("Delete", systemImage: "trash")
                    }
                }.refreshable {
                    fetchFiles()
                }
                .fullScreenCover(isPresented: $fullScreen){
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)){
                        if !self.currentlyDisplaying.fileName.isEmpty{
                            SceneViewWrapped(scene: displayFile(fileName: self.currentlyDisplaying.fileName))
                        }
                        Button(action: {
                            fullScreen = false
                        }){
                            Text("Back").padding()
                        }
                    }
                }
            }
            }.onAppear(){
                fetchFiles()
        }

    }
                           
                           
    func fetchFiles(){
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
    
//        guard let directory = self.getTmpDirectory() else{
//                        fatalError("Failed to access documents directory")
//        }
        
        let folderName = "OBJ_FILES"
        let folderURL = directory.appendingPathComponent(folderName)
        do{
            let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            let filteredURLs = fileURLs.filter{(url)->Bool in
                return url.pathExtension == "obj"
            }
            self.fileNames = filteredURLs.map {$0.lastPathComponent}
            print(fileNames)
            
        }catch{
            print("Error fetching files: \(error)")
        }
    }
    func displayFile(fileName: String) -> SCNScene{
//        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//                                    fatalError("Failed to access documents directory")
//
//        }
//        
////        guard let directory = self.getTmpDirectory() else{
////                        fatalError("Failed to access documents directory")
////        }
//        
//        let folderName = "OBJ_FILES"
//        let folderURL = directory.appendingPathComponent(folderName)
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Failed to access documents directory")
        }
    
//        guard let directory = self.getTmpDirectory() else{
//                        fatalError("Failed to access documents directory")
//        }
        
        let folderName = "OBJ_FILES"
        let folderURL = directory.appendingPathComponent(folderName)
        let fileURL = folderURL.appendingPathComponent(fileName)
        print("\(fileURL)")
        if FileManager.default.fileExists(atPath: "\(fileURL)"){print("WORKING")} else {print("ERROR RETRIEVING FILE")}
        
        let sceneView = try? SCNScene(url: fileURL)
        do{
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.absoluteString)
            if let fileSize = attributes[.size] as? Int64{
                let fileSizeKB = Double(fileSize) / 1024.0
                print("\(fileURL) is working and is of \(fileSizeKB)")
            }
            
        }catch{
            print("Errrrr \(error)")
        }
        
        print(sceneView?.rootNode.childNodes.count)
        
        return sceneView ?? SCNScene()
    }
    
    
    func getTmpDirectory() -> Optional<URL>{
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    
    func removeFile(fileName: String){
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Failed to access documents directory")
        }
//        
//        guard let directory = self.getTmpDirectory() else{
//                        fatalError("Failed to access documents directory")
//        }
        
        let folderName = "OBJ_FILES"
        let folderURL = directory.appendingPathComponent(folderName)
        let fileURL = folderURL.appendingPathComponent(fileName)
        do{
            try FileManager.default.removeItem(at: fileURL)
            print("File removed succesfully : \(fileURL)")
        }catch{
            print("Error removing file: \(error)")
        }
    }
}


struct SceneViewWrapped: UIViewRepresentable {
    let scene: SCNScene?
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        
        if let scene = scene {
            let camera = SCNCamera()
            let cameraNode = SCNNode()
            cameraNode.camera = camera
            scnView.pointOfView = cameraNode
            
            let light = SCNLight()
            light.type = .omni
            let lightNode = SCNNode()
            lightNode.light = light
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            scene.rootNode.addChildNode(lightNode)
            
            scnView.scene = scene
        }
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }
}

#Preview {
    FetchModelView()
}

