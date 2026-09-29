//
//  FPLTeamsViewController.swift
//  FPLTeamViewer
//
//  Created by AG on 29/09/26.
//

import UIKit

private enum Constants {
    /// Teams screen has a single section.
    static let teamsSection = 0
    static let estimatedItemHeight: CGFloat = 72
}

// MARK: - FPLTeamsViewController

final class FPLTeamsViewController: UIViewController {
    private let viewModel: FPLTeamsViewModel
    private weak var navigator: IFPLNavigator?

    private lazy var collectionView = FPLGridCollectionView(
        frame: .zero,
        collectionViewLayout: FPLGridLayout.make(estimatedItemHeight: Constants.estimatedItemHeight, showsHeaders: false)
    )
    private var dataSource: UICollectionViewDiffableDataSource<Int, FPLTeam>?
    private let bannerView = FPLBannerView()
    private let fetchIndicator = UIActivityIndicatorView(style: .medium)

    init(viewModel: FPLTeamsViewModel, navigator: IFPLNavigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = FPLStringKey.teamsTitle
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemGroupedBackground

        setupCollectionView()
        bindViewModel()

        Task { await viewModel.load() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // On a single column the selection should clear after coming back.
        // On two columns it stays, so the user sees which squad is open.
        if splitViewController?.isCollapsed ?? true {
            collectionView.indexPathsForSelectedItems?.forEach { collectionView.deselectItem(at: $0, animated: animated) }
        }
    }

    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        contentUnavailableConfiguration = UIContentUnavailableConfiguration.fpl(
            state: viewModel.state,
            emptyImageName: FPLImageName.teamsEmpty,
            emptyAction: { [weak self] in self?.reload() },
            retry: { [weak self] in self?.reload() }
        )
    }

    // MARK: - Setup

    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(FPLTeamCell.self, forCellWithReuseIdentifier: FPLTeamCell.reuseIdentifier)
        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction { [weak self] _ in
            self?.pullToRefresh()
        })
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, team in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FPLTeamCell.reuseIdentifier, for: indexPath)
            (cell as? FPLTeamCell)?.configure(with: team)
            return cell
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        viewModel.onRefreshError = { [weak self] message in
            guard let self else { return }
            bannerView.show(message, in: view)
        }
        viewModel.onFetchingChange = { [weak self] isFetching in
            self?.updateFetchIndicator(isFetching: isFetching)
        }
        render(viewModel.state)
    }

    // MARK: - Actions

    private func reload() {
        Task { await viewModel.load() }
    }

    private func pullToRefresh() {
        Task {
            await viewModel.refresh()
            collectionView.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Render

    private func render(_ state: FPLViewState<[FPLTeam]>) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, FPLTeam>()
        snapshot.appendSections([Constants.teamsSection])
        snapshot.appendItems(state.content ?? [])
        let hadItems = (dataSource?.snapshot().numberOfItems ?? 0) > 0
        dataSource?.apply(snapshot, animatingDifferences: hadItems)

        if let lastUpdated = viewModel.lastUpdated {
            collectionView.refreshControl?.attributedTitle = NSAttributedString(string: FPLStringKey.lastUpdated(lastUpdated))
        }
        setNeedsUpdateContentUnavailableConfiguration()
    }

    /// Small spinner in the nav bar while cached data is shown and fresh data is loading.
    /// Not needed for the first load (full screen loader) or pull to refresh (own spinner).
    private func updateFetchIndicator(isFetching: Bool) {
        let isPullToRefresh = collectionView.refreshControl?.isRefreshing ?? false
        let showsIndicator = isFetching && viewModel.state.content != nil && !isPullToRefresh

        if showsIndicator {
            fetchIndicator.startAnimating()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: fetchIndicator)
        } else {
            fetchIndicator.stopAnimating()
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FPLTeamsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let team = dataSource?.itemIdentifier(for: indexPath) else { return }
        navigator?.showSquad(for: team)
    }
}
