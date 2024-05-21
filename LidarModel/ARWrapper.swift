//
//  ARWrapper.swift
//  LidarModel
//
//  Created by smlab_drone on 05/05/24.
//

import SwiftUI
import RealityKit
import ARKit 

import GoogleSignIn
import GoogleAPIClientForREST


struct ARWrapper: UIViewRepresentable{
    @Binding var submittedExportRequest: Bool
//    @Binding var exportedURL: URL?
    @Binding var submittedName: String
    
    let arView = ARView(frame: .zero)
    func makeUIView(context: Context) -> ARView {
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let vm = ExportViewModel()
        setARViewOptions(arView)
        let configuration = buildConfigure()
        arView.session.run(configuration)
        
        if submittedExportRequest{
            guard let camera = arView.session.currentFrame?.camera else{return}
            if let meshAnchors = arView.session.currentFrame?.anchors.compactMap({$0 as? ARMeshAnchor}),
                let asset = vm.convertToAsset(meshAnchor: meshAnchors, camera: camera){
                do {
                    let url = try vm.export(asset: asset, fileName: submittedName)
//                    exportedURL = url
                    
                }catch{
                    print("Export failure")
                }
            }
            
                
        }
    }
    
    private func buildConfigure() -> ARWorldTrackingConfiguration{
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.environmentTexturing = .automatic
        configuration.sceneReconstruction = .meshWithClassification
        
        arView.automaticallyConfigureSession = false
        
        if type(of : configuration).supportsFrameSemantics(.sceneDepth){
            configuration.frameSemantics = .sceneDepth
        }
        
        return configuration
    }
    
    private func setARViewOptions(_ arView: ARView){
        arView.debugOptions.insert(.showFeaturePoints)
        arView.debugOptions.insert(.showSceneUnderstanding)
//        arView.debugOptions.insert(.showStatistics)

    }
}


class ExportViewModel: NSObject, ObservableObject, ARSessionDelegate{
    
    
    
    func convertToAsset(meshAnchor: [ARMeshAnchor], camera: ARCamera) -> MDLAsset?{
        guard let device = MTLCreateSystemDefaultDevice() else {return nil}
        
        let asset = MDLAsset()
        
        for anchor in meshAnchor {
            let mdlMesh = anchor.geometry.toMDLMesh(device: device, camera: camera, modelMatrix: anchor.transform)
            asset.add(mdlMesh)
            print("\(mdlMesh)")
        }
        
        return asset
    }
    
    func convertUSDZToData(url: URL) -> Data? {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("Error converting USDZ to Data: \(error)")
                return nil
            }
        }
    
    func export(asset: MDLAsset, fileName: String) throws -> URL{
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "com.Harshit.LidarModel", code: 153)
        }
        
        try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        print("Access granted")

        
//        guard let directory = self.getTmpDirectory() else{
//                throw NSError(domain: "com.Harshit.LidarModel", code: 153)
//        }
        
        let folderName = "OBJ_FILES"
        let folderURL = directory.appendingPathComponent(folderName)
        
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        
        let url = folderURL.appendingPathComponent("\(fileName.isEmpty ? UUID().uuidString: fileName).obj")
        
        do{
            try asset.export(to: url)
            print("Object saved succesfully at ", url)
            /*            let tcpClient = TCPClient()
             
             tcpClient.connect(to: "127.0.0.1", with: 54533){error in
             if(error != nil){
             print("There was an error sorry, \(error)")
             }else{
             print("Its connected, yayy")
             }
             }
             */
            guard let assetData = convertUSDZToData(url: url) else {
                print("Error: Failed to convert USDZ to Data")
                return URL(fileURLWithPath: "")
            }
            /*            tcpClient.send(data: assetData){error in
             if(error == nil){
             print("There was an error sorry")
             }else{
             print("Its connected, yayy")
             }
             */
            
            //            GIDSignIn.sharedInstance().clientID =
            //
            //            let file = GTLRDrive_File()
            //            file.name = "\(fileName).obj"
            //
            
            return url
        }catch{
            print(error)
        }
                


        
        return url
    }
    
    func getTmpDirectory() -> Optional<URL>{
        return URL(fileURLWithPath: NSTemporaryDirectory())
    }
    
    
}
