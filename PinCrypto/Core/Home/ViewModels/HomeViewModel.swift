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
    
    private let coinDataService = CoinDataService()
    private let marketDataService = MarketDataService()
    private let portfolioDataService = PortfolioDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        
        // update all coins
        $searchText
            .combineLatest(coinDataService.$allCoins)
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .map(filterCoins)
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
        
        // update portfolio with filtered coins
        $allCoins
            .combineLatest(portfolioDataService.$savedEntities)
            .map(mapAllCoinsToPortfolioCoins)
            .sink { [weak self] returnedCoins in
                self?.portfolioCoins = returnedCoins
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
    func filterCoins(text: String, coins: [CoinModel]) -> [CoinModel] {
        guard !text.isEmpty else { return coins }
        
        let lowercasedText = text.lowercased()
        return coins.filter { $0.name.lowercased().contains(lowercasedText) ||
            $0.symbol.lowercased().contains(lowercasedText) ||
            $0.id.lowercased().contains(lowercasedText)
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
