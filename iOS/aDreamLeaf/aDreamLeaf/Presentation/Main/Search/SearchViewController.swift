//
//  SearchViewController.swift
//  aDreamLeaf
//
//  Created by 엄태양 on 2023/03/30.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: SearchViewModel
    
    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    private let underLine = UIView()
    private let checkBoxView = UIView()
    private let buttonStackView = UIStackView()
    private let allButton = UIButton()
    private let cardButton = UIButton()
    private let goodButton = UIButton()
    private let tableView = UITableView()
    private let searchListEmptyWarnLabel = UILabel()
    
    init() {
        viewModel = SearchViewModel()
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 2)
        tabBarItem.imageInsets = .init(top: 6, left: 0, bottom: -6, right: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SearchCell.self, forCellReuseIdentifier: K.TableViewCellID.SearchCell)
        
        bind()
        attribute()
        layout()
    }
    
    private func bind() {
        viewModel.tableItem
            .bind(to: tableView.rx.items) { tv, row, element in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = self.tableView.dequeueReusableCell(withIdentifier: K.TableViewCellID.SearchCell, for: indexPath) as! SearchCell
                
                cell.setUp(with: element)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .withLatestFrom(viewModel.tableItem) { return ($0, $1)}
            .subscribe(onNext: { indexPath, list in
                self.tableView.cellForRow(at: indexPath)?.isSelected = false
                self.navigationController?.pushViewController(StoreDetailViewController(storeId: (list[indexPath.row]).storeId), animated: true)
            })
            .disposed(by: disposeBag)
        
        allButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.allButton.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
                self.cardButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
                self.goodButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
                self.viewModel.allButtonTap.accept(Void())
            })
            .disposed(by: disposeBag)
        
        cardButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.cardButton.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
                self.allButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
                self.goodButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
                self.viewModel.cardButtonTap.accept(Void())
            })
            .disposed(by: disposeBag)
        
        goodButton.rx.tap
            .asDriver()
            .drive(onNext: {
                self.goodButton.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
                self.cardButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
                self.allButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
                self.viewModel.goodButtonTap.accept(Void())
            })
            .disposed(by: disposeBag)
        
        searchTextField.rx.text
            .orEmpty
            .bind(to: viewModel.keyword)
            .disposed(by: disposeBag)
        
        searchButton.rx.tap
            .bind(to: viewModel.searchButtonTap)
            .disposed(by: disposeBag)
        
        viewModel.allList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.allButton.sendActions(for: .touchUpInside)
            })
            .disposed(by: disposeBag)
        
        viewModel.tableItem
            .map { $0.count != 0 }
            .observe(on: MainScheduler.instance)
            .bind(to: searchListEmptyWarnLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
    }    
    
    private func attribute() {
    
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        searchTextField.textColor = .black
        searchTextField.font = .systemFont(ofSize: 16, weight: .regular)
        searchTextField.attributedPlaceholder =
        NSAttributedString(string: "가게명, 행정구역, 주소 등을 입력하세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        let searchButtonConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular, scale: .default)
        let searchButtonImg = UIImage(systemName: "magnifyingglass", withConfiguration: searchButtonConfig)?.withRenderingMode(.alwaysTemplate)
        searchButton.setImage(searchButtonImg, for: .normal)
        searchButton.tintColor = .black
        
        underLine.backgroundColor = .lightGray
        
        checkBoxView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        checkBoxView.layer.cornerRadius = 5
        
        buttonStackView.spacing = 15
        
        allButton.setTitle("전체", for: .normal)
        allButton.setImage(UIImage(systemName: "checkmark.rectangle"), for: .normal)
        allButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        allButton.setTitleColor(.black, for: .normal)
        allButton.tintColor = .black
        allButton.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 0)
        
        cardButton.setTitle("아동급식카드 가맹점", for: .normal)
        cardButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
        cardButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        cardButton.setTitleColor(.black, for: .normal)
        cardButton.tintColor = .black
        cardButton.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 0)
        
        goodButton.setTitle("선한영향력 가게", for: .normal)
        goodButton.setImage(UIImage(systemName: "rectangle"), for: .normal)
        goodButton.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        goodButton.setTitleColor(.black, for: .normal)
        goodButton.tintColor = .black
        goodButton.imageEdgeInsets = .init(top: 0, left: -5, bottom: 0, right: 0)
        
        searchListEmptyWarnLabel.text = "검색된 음식점이 없습니다 🥲"
        searchListEmptyWarnLabel.textColor = .black
        searchListEmptyWarnLabel.font = .systemFont(ofSize: 15, weight: .bold)
        searchListEmptyWarnLabel.textAlignment = .center
    }
    
    private func layout() {
        [searchTextField, searchButton, underLine, tableView, checkBoxView, searchListEmptyWarnLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        checkBoxView.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [ allButton, goodButton, cardButton].forEach {
            buttonStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor),
            
            searchButton.topAnchor.constraint(equalTo: searchTextField.topAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            searchButton.heightAnchor.constraint(equalToConstant: 25),
            
            underLine.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 15),
            underLine.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            underLine.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            underLine.heightAnchor.constraint(equalToConstant: 0.2),
            
            checkBoxView.heightAnchor.constraint(equalToConstant: 30),
            checkBoxView.topAnchor.constraint(equalTo: underLine.bottomAnchor, constant: 20),
            checkBoxView.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
            checkBoxView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor),
            
            buttonStackView.centerXAnchor.constraint(equalTo: checkBoxView.centerXAnchor),
            buttonStackView.centerYAnchor.constraint(equalTo: checkBoxView.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: checkBoxView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            searchListEmptyWarnLabel.topAnchor.constraint(equalTo: tableView.topAnchor),
            searchListEmptyWarnLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            searchListEmptyWarnLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            searchListEmptyWarnLabel.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
            
        ].forEach { $0.isActive = true }
    }
}
