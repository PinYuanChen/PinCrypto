//
// Created on 2022/12/22.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var statistics = [StatisticModel]()
    @Published var allCoins = [CoinModel]()
    @Published var portfolioCoins = [CoinModel]()
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var sortOption: SortOption = .holdings
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption {
        case rank
        case rankReversed
        case holdings
        case holdingsReversed
        case price
        case priceReversed
    }
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        
        // update all coins
        $searchText
            .combineLatest(coinDataService.$allCoins, $sortOption)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterAndSortCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        // update portfolio with filtered coins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnedCoins in
                guard let self = self else { return }
                self.portfolioCoins = self.sortPortfolioCoinsIfNeeded(coins: returnedCoins)
            }
            .store(in: &cancellables)
        
        // update market data
        marketDataService
            .$marketData
            .combineLatest($portfolioCoins)
            .map(mapGlobalMarketData)
            .sink { [weak self] stats in
                self?.statistics = stats
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        portfolioDataService.updatePortfolio(coin: coin, amount: amount)
    }
    
    func reloadData() {
        isLoading = true
        coinDataService.getCoins()
        marketDataService.getData()
        HapticManager.notification(type: .success)
    }
}

private extension HomeViewModel {
    
    func filterAndSortCoins(text: String,
                            coins: [CoinModel],
                            sort: SortOption) -> [CoinModel] {
        var updatedCoins = filterCoins(text: text, coins: coins)
        sortCoins(sort: sort, coins: &updatedCoins)
        return updatedCoins
    }
    
    func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else { return coins }
        
        let lowercasedText = text.lowercased()
        return coins.filter { $0.name.lowercased().contains(lowercasedText) ||
            $0.symbol.lowercased().contains(lowercasedText) ||
            $0.id.lowercased().contains(lowercasedText)
        }
    }
    
    func sortCoins(sort: SortOption, coins: inout [CoinModel]) {
        switch sort {
        case .rank, .holdings:
            coins.sort { $0.rank < $1.rank }
        case .rankReversed, .holdingsReversed:
            coins.sort { $0.rank > $1.rank }
        case .price:
            coins.sort { $0.currentPrice > $1.currentPrice }
        case .priceReversed:
            coins.sort { $0.currentPrice < $1.currentPrice }
        }
    }
    
    func sortPortfolioCoinsIfNeeded(coins: [CoinModel]) -> [CoinModel] {
        // will only sort by holdings or reverse holdings if needed
        switch sortOption {
        case .holdings:
            return coins.sorted { $0.currentHoldingsValue > $1.currentHoldingsValue }
        case .holdingsReversed:
            return coins.sorted { $0.currentHoldingsValue < $1.currentHoldingsValue }
        default:
            return coins
        }
    }
    
    func mapAllCoinsToPortfolioCoins(allCoins: [CoinModel],
                                     portfolioEntities: [PortfolioEntity]) -> [CoinModel] {
        allCoins
            .compactMap { coin -> CoinModel? in
                guard let entity = portfolioEntities.first(where: { $0.coinID == coin.id }) else {
                    return nil
                }
                return coin.updateHoldings(amount: entity.amount)
            }
    }
    
    func mapGlobalMarketData(marketDataModel: MarketDataModel?,
                             portfolioCoins: [CoinModel])-> [StatisticModel] {
        guard let data = marketDataModel else { return [] }
        
        let marketCap = StatisticModel(title: "Market Cap",
                                       value: data.marketCap,
                                       percentageChange: data.marketCapChangePercentage24HUsd)
        
        let volume = StatisticModel(title: "24h Volume",
                                    value: data.volume)
        
        let btcDominance = StatisticModel(title: "BTC Dominance",
                                          value: data.btcDominance)
        
        let portfolioValue = portfolioCoins.reduce(0) {
            $0 + $1.currentHoldingsValue
        }
        
        let previousValue = portfolioCoins
            .map { coin -> Double in
                let current = coin.currentHoldingsValue
                let percentChange = coin.priceChangePercentage24H ?? 0 / 100
                let previous = current / (1 + percentChange)
                
                return previous
            }
            .reduce(0, +)
        
        let percentageChange = ((portfolioValue - previousValue) / previousValue) * 100
        
        let portfolio = StatisticModel(title: "Portfolio Value",
                                       value: portfolioValue.asCurrencyWith2Decimals(),
                                       percentageChange: percentageChange)
        
        return [marketCap, volume, btcDominance, portfolio]
    }
}
