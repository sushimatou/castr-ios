//
//  ChangePicturePresenter.swift
//  CastrApp
//
//  Created by Antoine on 25/10/2017.
//  Copyright © 2017 Castr. All rights reserved.
//

import Foundation
import RxSwift

class ChangePicturePresenter {
    
    static let instance = ChangePicturePresenter()
    private let initState = ChangePictureViewState.empty(media: nil)
    private let interactor = PictureInteractor()
    private var disposable: Disposable?
    private var view = ChangePictureViewController()
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK: - Bind / Unbind View
    
    public func bind(view: ChangePictureViewController){
        self.view = view
        self.disposable = Observable.merge([obsAddImageIntent(),
                                            obsValidChangeIntent()])
                                    .scan(initState, accumulator: reduceViewState)
                                    .subscribe(onNext: { newState in
                                        view.render(state: newState)
                                    })
    }
    
    public func unbind() {
        self.disposable?.dispose()
    }
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK: - Observables
    
    func obsAddImageIntent() -> Observable<ChangePictureAction> {
        return view
            .addImageSubject
            .map{ image in
                return ChangePictureAction.setPicture(image)
            }
    }
    
    func obsValidChangeIntent() -> Observable<ChangePictureAction> {
        return view
            .validChangeIntent()
            .flatMap({ (image) -> Observable<Result<(progress: Progress?, isSent: Bool)>> in
                let imageData = UIImageJPEGRepresentation(image, 0.8)
                return self
                    .interactor
                    .changePicture(context: self.view.context,
                                   imageData: imageData!)
            })
            .map{ result  in
                switch result {
                case .success(let progress, let isSent):
                    if isSent {
                        return .setDone
                    }
                    else {
                        return .setUploading(progress!)
                    }
                case .failed(let error):
                    return .setError(error)
            }
        }
    }
    
//    func obsDeleteImageIntent() -> Observable<ChangePictureAction> {
//        return view
//            .deleteImageIntent()
//            .flatMap{ _ in
//                return self
//                    .interactor
//                    .deletePicture(context: self.view.context)
//            }
//            .map{ result in
//                switch result {
//                case .success:
//                    return .setDone
//                case .failed(let error):
//                    return .setError(error)
//                }
//            }
//    }
    
    // ---------------------------------------------------------------------------------------------
    
    // MARK: - Reduce View State
    
    private func reduceViewState(previousState: ChangePictureViewState, actions: ChangePictureAction) -> ChangePictureViewState {
        
        var newState = previousState
        
        switch actions {
            
        case .setPicture(let image):
            newState = .empty(media: image)
            
        case .setDone:
            newState = .uploaded
        
        case .setUploading(let progress):
            newState = .uploading(progress: progress)
            
        case .setError(let error):
            newState = .error(error)
            
        }
        return newState
    }
}
