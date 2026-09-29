//
//  FPLSquadViewController.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    static let estimatedItemHeight: CGFloat = 64
}

// MARK: - FPLSquadViewController

final class FPLSquadViewController: UIViewController {
    let viewModel: FPLSquadViewModel

    private lazy var collectionView = FPLGridCollectionView(
        frame: .zero,
        collectionViewLayout: FPLGridLayout.make(estimatedItemHeight: Constants.estimatedItemHeight, showsHeaders: true)
    )
    private var dataSource: UICollectionViewDiffableDataSource<FPLPosition, FPLPlayer>?
    private let bannerView = FPLBannerView()

    init(viewModel: FPLSquadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemGroupedBackground

        setupCollectionView()
        setupSearch()
        bindViewModel()
    }

    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        let reload: @MainActor () -> Void = { [weak self] in self?.reload() }
        // No reload button for "no search results", the user just changes the text.
        let isSearching = !viewModel.searchText.isEmpty
        contentUnavailableConfiguration = UIContentUnavailableConfiguration.fpl(
            state: viewModel.state,
            emptyImageName: isSearching ? FPLImageName.searchEmpty : FPLImageName.playersEmpty,
            emptyAction: isSearching ? nil : reload,
            retry: reload
        )
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.allowsSelection = false
        collectionView.register(FPLPlayerCell.self, forCellWithReuseIdentifier: FPLPlayerCell.reuseIdentifier)
        collectionView.register(
            FPLSectionHeaderView.self,
            forSupplementaryViewOfKind: FPLGridLayout.sectionHeaderKind,
            withReuseIdentifier: FPLSectionHeaderView.reuseIdentifier
        )
        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction { [weak self] _ in
            self?.reload()
        })
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let dataSource = UICollectionViewDiffableDataSource<FPLPosition, FPLPlayer>(collectionView: collectionView) { collectionView, indexPath, player in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FPLPlayerCell.reuseIdentifier, for: indexPath)
            (cell as? FPLPlayerCell)?.configure(with: player)
            return cell
        }
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: FPLSectionHeaderView.reuseIdentifier,
                for: indexPath
            )
            if let section = self?.viewModel.state.content?[safe: indexPath.section] {
                (header as? FPLSectionHeaderView)?.configure(with: section)
            }
            return header
        }
        self.dataSource = dataSource
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        viewModel.onRefreshError = { [weak self] message in
            guard let self else { return }
            bannerView.show(message, in: view)
        }
        render(viewModel.state)
    }

    // MARK: - Actions

    private func reload() {
        Task {
            await viewModel.refresh()
            collectionView.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Render

    private func render(_ state: FPLViewState<[FPLSquadSection]>) {
        var snapshot = NSDiffableDataSourceSnapshot<FPLPosition, FPLPlayer>()
        for section in state.content ?? [] {
            snapshot.appendSections([section.position])
            snapshot.appendItems(section.players, toSection: section.position)
        }
        // Header counts change with search, so reload them too.
        snapshot.reloadSections(snapshot.sectionIdentifiers)

        let hadItems = (dataSource?.snapshot().numberOfItems ?? 0) > 0
        dataSource?.apply(snapshot, animatingDifferences: hadItems)
        setNeedsUpdateContentUnavailableConfiguration()
    }
}
