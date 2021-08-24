//
//  FirebaseDatabase.swift
//  CastrApp
//
//  Created by Antoine on 25/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

class FirebaseDatabase {
    
    //MARK: - Properties
    
    static let storageRef = Storage.storage().reference()
    static let dbRef = Database.database().reference()

    static func uploadImageToDatabase(context: UploadType, imageData: Data ) -> Observable<FirebaseUploadStatus> {
        
        let metadata = StorageMetadata()
        var createdMessageId = ""
        var imageRef = storageRef
        
        switch context {
        case .uploadUserPic(let user):
            imageRef = storageRef.child("/users/profiles/\(user.id)/profile.jpeg")
        case .uploadChatroomPic(let chatroom):
            imageRef = storageRef.child("/channels/profiles/\(chatroom.id)/profile.jpeg")
        case .uploadMessageRoom(let chatroomId):
            let targetRef = dbRef.child("/channels/messages/\(chatroomId)").childByAutoId()
            createdMessageId = targetRef.key
            imageRef = storageRef.child("/channels/messages/\(chatroomId)/\(createdMessageId))/image.jpeg")
        case .uploadMessageChat(let chatId):
            imageRef = storageRef.child("/chats/messages/\(chatId)/\(createdMessageId))/image.jpeg")
        }
        
        return Observable.create{emitter in
            
            metadata.contentType = "image/jpeg"
            let uploadTask = imageRef.putData(imageData, metadata: metadata)
            
            // Uploading
            uploadTask.observe(.progress, handler: { (progression) in
                print(progression)
                if let progression = progression.progress {
                    emitter.onNext(.uploading(progress: progression))
                }
            })
            
            // Successfully uploaded
            uploadTask.observe(.success, handler: { (snapshot) in
                if let downloadUrl = snapshot.metadata!.downloadURL() {
                    emitter.onNext(.uploaded(url: downloadUrl))
                }
            })
            
            // Failure
            uploadTask.observe(.failure, handler: { (error) in
                if let error = error.error {
                    emitter.onError(error)
                }
            })
            
            return Disposables.create()
        }
    }
}
public enum UploadType {
    case uploadUserPic(user: UserDTO)
    case uploadChatroomPic(chatroom: ChatroomDTO)
    case uploadMessageRoom(chatroomId: String)
    case uploadMessageChat(chatId: String)
}
