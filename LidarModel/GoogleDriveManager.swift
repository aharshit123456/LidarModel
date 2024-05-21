//
//  GoogleDriveManager.swift
//  LidarModel
//
//  Created by smlab_drone on 13/05/24.
//

//import GoogleAPIClientForREST
//import GTMSessionFetcher
//import GoogleSignIn
//
//class GoogleDriveManager{
//    private let service = GTLRDriveService()
//    
//
//    
//    private func authenticate(completion: @escaping (Error?)->Void){
//        GIDSignIn.sharedInstance.clientID = ""
//        
//        
//        guard let currentUser = GIDSignIn.sharedInstance.currentUser, currentUser.authentication != nil else{
//            let error = NSError(domain: "GoogleDriveManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User is not signed in to Google"])
//            completion(error)
//            return
//        }
//        
//        
//        
//        
//    }
//    
//}
