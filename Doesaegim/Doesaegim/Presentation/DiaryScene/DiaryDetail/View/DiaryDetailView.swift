//
//  DiaryDetailView.swift
//  Doesaegim
//
//  Created by 서보경 on 2022/11/23.
//

import UIKit

import SnapKit

final class DiaryDetailView: UIView {
    // MARK: - UI Properties
    
    /// 이미지 슬라이더 뷰. 추후 컬렉션뷰로 변경 예정
    private let imageSlider: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill")
        
        return imageView
    }()
    
    /// 페이지 컨트롤
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .grey2
        pageControl.currentPageIndicatorTintColor = .grey4
        pageControl.numberOfPages = 5
        
        return pageControl
    }()
    
    /// 이미지 슬라이더, 페이지 컨트롤을 포함하는 스택 뷰
    private let imageStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        return stackView
    }()
    
    /// 내용 레이블
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Metric.contentNumberOfLines
        
        return label
    }()
    
    /// 장소 레이블
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.changeFontSize(to: FontSize.body)
        label.text = "asdffdsaf"
        
        return label
    }()
    
    /// 날짜 레이블
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.changeFontSize(to: FontSize.caption)
        label.textColor = .grey3
        label.text = "asdffdsafadsfasdf"
        
        return label
    }()
    
    /// 장소, 날짜 레이블을 포함한 스택 뷰
    private let infoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metric.infoStackSpacing
        
        return stackView
    }()
    
    /// 전체 컨텐츠를 포함한 스택 뷰
    private let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metric.contentStackSpacing
        stackView.alignment = .center
        
        return stackView
    }()
    
    /// 전체 컨텐츠 스크롤 뷰
    private let scrollView = UIScrollView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Configure Functions
    
    private func configureViews() {
        configureSubviews()
        configureConstraint()
    }
    
    private func configureSubviews() {
        imageStack.addArrangedSubviews(imageSlider, pageControl)
        infoStack.addArrangedSubviews(locationLabel, dateLabel)
        
        contentStack.addArrangedSubviews(imageStack, contentLabel, infoStack)
        
        scrollView.addSubview(contentStack)
        addSubview(scrollView)
    }
    
    private func configureConstraint() {
        imageSlider.snp.makeConstraints {
            $0.height.equalTo(imageSlider.snp.width)
        }
        
        [contentLabel, infoStack].forEach {
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(Metric.contentInsets)
            }
        }
        
        imageStack.snp.makeConstraints { $0.horizontalEdges.equalToSuperview() }
        contentStack.snp.makeConstraints { $0.edges.width.equalToSuperview() }
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
    }
    
    // MARK: - Setup Functions
    
    func setupData() {
        
    }
    
}

// MARK: - Namespaces

extension DiaryDetailView {
    enum Metric {
        static let contentNumberOfLines = 0
        
        static let infoStackSpacing: CGFloat = 8
        static let contentStackSpacing: CGFloat = 16
        
        static let contentInsets: CGFloat = 16
    }
}
