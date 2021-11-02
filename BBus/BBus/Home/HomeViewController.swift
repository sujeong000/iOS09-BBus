//
//  ViewController.swift
//  BBus
//
//  Created by Kang Minsang on 2021/10/26.
//

import UIKit

class HomeViewController: UIViewController {

    weak var coordinator: HomeCoordinator?
    private let viewModel: HomeViewModel?
    private lazy var searchButton: UIButton = {
        let button = UIButton(frame: CGRect(origin: CGPoint(), size: CGSize(width: self.view.frame.width, height: 30)))
        button.backgroundColor = UIColor(named: "bbusLightGray")
        button.layer.borderColor = UIColor(named: "bbusGray")?.cgColor
        button.layer.borderWidth = 0.3
        button.layer.cornerRadius = 3
        button.setTitle("버스 또는 정류장 검색", for: .normal)
        button.setTitleColor(UIColor(named: "bbusGray"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    private lazy var homeView = HomeView()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"

        self.configureLayout()
        self.homeView.configureLayout()
        self.addButtonAction()
    }

    private func configureLayout() {
        self.view.backgroundColor = UIColor.systemBackground

        self.navigationItem.titleView = self.searchButton
        self.searchButton.titleLabel?.leftAnchor.constraint(equalTo: self.searchButton.leftAnchor, constant: 10).isActive = true


        self.homeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.homeView)
        NSLayoutConstraint.activate([
            self.homeView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.homeView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.homeView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.homeView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func addButtonAction() {
        self.homeView.refreshButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }

    @objc func buttonAction(_ sender: UIButton) {
        coordinator?.pushToSearchBus()
    }
}

