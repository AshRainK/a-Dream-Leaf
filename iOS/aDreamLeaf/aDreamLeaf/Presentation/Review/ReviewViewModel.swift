//
//  ReviewViewModel.swift
//  aDreamLeaf
//
//  Created by 엄태양 on 2023/04/03.
//

import Foundation
import RxSwift
import RxRelay

struct ReviewViewModel: LoadingViewModel {
    var loading: PublishSubject<Bool>
    
    private let disposeBag = DisposeBag()
    private let storeId: Int

    let editData : Review? // 리뷰 수정 시 리뷰 데이터, 신규 작성시 nil
    let rating = BehaviorSubject<Int>(value: 5)
    let body = BehaviorSubject<String>(value: "")
    let image = BehaviorSubject<UIImage?>(value: nil)
    let saveBtnTap = PublishSubject<Void>()
    
    let reviewRequestResult = PublishSubject<RequestResult<Void>>()
    
    init(storeId: Int, editData: Review?, _ repo: ReviewRepository = ReviewRepository()) {
        self.storeId = storeId
        self.editData = editData
        self.loading = PublishSubject<Bool>()
        
        // 신규 리뷰 작성
        saveBtnTap
            .filter { editData == nil }
            .withLatestFrom(Observable.combineLatest(rating, body, image))
            .flatMap{rating, body, img in repo.create(storeId: storeId, body: body, rating: rating, image: img)}
            .bind(to: reviewRequestResult)
            .disposed(by: disposeBag)
        
        // 기존 리뷰 수정
        saveBtnTap
            .filter { editData != nil }
            .withLatestFrom(Observable.combineLatest(rating, body, image))
            .flatMap{rating, body, img in repo.update(reviewId: editData!.reviewId, body: body, rating: rating, image: img)}
            .bind(to: reviewRequestResult)
            .disposed(by: disposeBag)
        
        // 리뷰 수정모드 시 초기값 설정
        if let data = editData {
            rating.onNext(data.rating)
            body.onNext(data.body)
            if let reviewImage = data.reviewImage { // 리뷰에 이미지가 포함 된 경우
                image.onNext(Image.base64ToImg(with: reviewImage))
            }
        }
        
        //MARK: - Loading
        
        saveBtnTap
            .map { return true }
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        reviewRequestResult
            .map { _ in return false }
            .bind(to: loading)
            .disposed(by: disposeBag)
    }
}
