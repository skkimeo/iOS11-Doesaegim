//
//  DiaryAddViewModel.swift
//  Doesaegim
//
//  Created by sun on 2022/11/21.
//

import UIKit

final class DiaryAddViewModel {
    typealias ImageID = String

    // MARK: - Properties

    weak var delegate: DiaryAddViewModelDelegate?

    lazy var travelPickerDataSource: PickerDataSource<Travel> = {
        let result = repository.fetchAllTravels()

        switch result {
        case .success(let travels):
            return PickerDataSource(items: travels)
        case .failure(let error):
            return PickerDataSource(items: [])
        }
    }()

    private let repository: DiaryAddRepository

    private let imageManager: ImageManager

    /// 유저의 입력값을 관리하기 위한 객체
    private var temporaryDiary = TemporaryDiary()


    // MARK: - Init(s)

    init(repository: DiaryAddRepository, imageManager: ImageManager) {
        self.repository = repository
        self.imageManager = imageManager
    }


    // MARK: - User Interaction Handling Functions

    func travelDidSelect(_ travel: Travel) {
        temporaryDiary.travel = travel
        delegate?.diaryAddViewModlelValuesDidChange(temporaryDiary)
    }

    func locationDidSelect(_ location: LocationDTO) {
        temporaryDiary.location = location
        delegate?.diaryAddViewModlelValuesDidChange(temporaryDiary)
    }

    func titleDidChange(to title: String?) {
        temporaryDiary.title = title
        delegate?.diaryAddViewModlelValuesDidChange(temporaryDiary)
    }

    func contentDidChange(to content: String?) {
        temporaryDiary.content = content
        delegate?.diaryAddViewModlelValuesDidChange(temporaryDiary)
    }

    func image(withID id: ImageID) -> ImageStatus {
        let status = imageManager.image(withID: id) { [weak self] id in
            DispatchQueue.main.async {
                self?.delegate?.diaryAddViewModelDidLoadImage(withId: id)
            }
        }

        switch status {
        case .error(let image):
            return .error(image ?? UIImage(systemName: StringLiteral.errorImageName))
        default:
            return status
        }
    }

    func imageDidSelect(_ results: [(id: ImageID, itemProvider: NSItemProvider)]) {
        imageManager.selectedIDs.removeAll()
        imageManager.itemProviders.removeAll()

        results.forEach {
            imageManager.selectedIDs.append($0.id)
            imageManager.itemProviders[$0.id] = $0.itemProvider
        }

        delegate?.diaryAddViewModelDidUpdateSelectedImageIDs(imageManager.selectedIDs)
    }

    func saveButtonDidTap() {
        temporaryDiary.imagePaths = Array(repeating: .empty, count: imageManager.selectedIDs.count)
        let imageSavingGroup = DispatchGroup()
        saveImagesToFileSystem(groupedBy: imageSavingGroup)

        imageSavingGroup.notify(queue: .global()) { [weak self] in
            guard let imagePaths = self?.temporaryDiary.imagePaths,
                  !imagePaths.contains(.empty)
            else {
                self?.deleteImagesInFileSystem()
                DispatchQueue.main.async {
                    self?.delegate?.diaryAddViewModelDidAddDiary(.failure(CoreDataError.saveFailure(.diary)))
                }
                return
            }

            guard let result = self?.addDiary()
            else {
                return
            }

            switch result {
            case .success:
                break
            case .failure:
                self?.deleteImagesInFileSystem()
            }

            DispatchQueue.main.async {
                self?.delegate?.diaryAddViewModelDidAddDiary(result)
            }
        }
    }

    private func saveImagesToFileSystem(groupedBy imageSavingGroup: DispatchGroup) {
        imageManager.selectedIDs.enumerated().forEach { index, id in
            let imageConvertingGroup = DispatchGroup()
            imageConvertingGroup.enter()
            imageSavingGroup.enter()

            let convertingWorkitem = DispatchWorkItem { [weak self] in
                let result = self?.imageManager.image(withID: id) { _ in
                    imageConvertingGroup.leave()
                }

                switch result {
                case .complete, .error:
                    imageConvertingGroup.leave()
                default:
                    break
                }
            }

            let savingWorkItem = DispatchWorkItem { [weak self] in
                guard let image = self?.imageManager.images[id],
                      let path = FileProcessManager.shared.saveImage(image, path: id)
                else {
                    self?.temporaryDiary.imagePaths[index] = .empty
                    imageSavingGroup.leave()
                    return
                }

                self?.temporaryDiary.imagePaths[index] = path
                imageSavingGroup.leave()
            }

            imageConvertingGroup.notify(queue: .global(), work: savingWorkItem)
            DispatchQueue.global().async(execute: convertingWorkitem)
        }
    }

    private func addDiary() -> Result<Diary, Error> {
        guard let title = temporaryDiary.title,
              let content = temporaryDiary.content,
              let location = temporaryDiary.location,
              let travel = temporaryDiary.travel
        else {
            return .failure(CoreDataError.saveFailure(.diary))
        }

        let diaryDTO = DiaryDTO(
            content: content,
            date: temporaryDiary.date,
            images: temporaryDiary.imagePaths,
            title: title,
            location: location,
            travel: travel
        )

        return repository.addDiary(diaryDTO)
    }

    // TODO: Check Concurrency
    private func deleteImagesInFileSystem() {
        temporaryDiary.imagePaths.filter { !$0.isEmpty }.forEach {
            FileProcessManager.shared.deleteImage(at: $0)
        }
    }
}


// MARK: - Constants

fileprivate extension DiaryAddViewModel {

    enum StringLiteral {
        static let errorImageName = "exclamationmark.circle"
    }
}
