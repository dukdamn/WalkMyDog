//
//  StorageManager.swift
//  WalkMyDog
//
//  Created by κΉνν on 2021/03/01.
//

import Foundation
import FirebaseStorage
import Alamofire
import RxSwift

class StorageManager {
    // MARK: - Properties
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    // MARK: - Methods
    func saveImage(with ref: FIRStoreRef, id: String, image: UIImage, completion: @escaping (String) -> Void) {
        
        guard let imageData = image.pngData() else { return }
        let ref = storage.child("\(ref.uid)/\(id)")
        
        ref.putData(imageData, metadata: nil) { (_, error) in
            if error != nil {
                print("Failed to upload: \(error!.localizedDescription)")
                return
            }
            ref.downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                completion(urlString)
            }
        }
    }
    
    func loadImage(from url: String) -> Observable<UIImage> {
        return Observable.create() { emitter in
            self.requestImage(from: url) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(UIImage(data: data)!)
                case .failure(let err):
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
    
    func requestImage(from url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        AF.request(url).response { response in
            switch response.result {
            case .success(let data):
                completion(.success(data!))
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    func deleteImage(with ref: FIRStoreRef, id: String, completion: @escaping (Bool, Error?) -> Void) {
        let ref = storage.child("\(ref.uid)/\(id)")
        ref.delete { (err) in
            if err != nil {
                print("Error deleting image: \(err!.localizedDescription)")
                completion(false, err)
            } else {
                print("Deleting image Succeded")
                completion(true, nil)
            }
        }
    }
}
