//
// Created on 2022/12/28.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
    
    @Published var overviewStats = [StatisticModel]()
    @Published var additionalStats = [StatisticModel]()
    
    @Published var coin: CoinModel
    
    init(coin: CoinModel) {
        self.coin = coin
        self.coinDetailService = CoinDetailDataService(coin: coin)
        self.addSubscribers()
    }
    
    private let coinDetailService: CoinDetailDataService
    private var cancellables = Set<AnyCancellable>()
}

private extension DetailViewModel {
    func addSubscribers() {
        coinDetailService
            .$coinDetail
            .combineLatest($coin)
            .map { (coinDetailModel, coinModel) -> (overview: [StatisticModel], additional: [StatisticModel]) in
                
                let price = coinModel.currentPrice.asCurrencyWith6Decimals()
                let pricePercentChange = coinModel.priceChangePercentage24H
                let priceStat = StatisticModel(title: "Current Price", value: price, percentageChange: pricePercentChange)
                
                let marketCap = "$" + (coinModel.marketCap?.formattedWithAbbreviations() ?? "")
                let marketPercentCapChange = coinModel.marketCapChangePercentage24H
                let marketCapStat = StatisticModel(title: "Market Capitalization", value: marketCap, percentageChange: marketPercentCapChange)
                
                let rank = "\(coinModel.rank)"
                let rankStat = StatisticModel(title: "Rank", value: rank)
                
                let volume = "$" + (coinModel.totalVolume?.formattedWithAbbreviations() ?? "")
                let volumeStat = StatisticModel(title: "Volume", value: volume)
                
                let overViewAry = [priceStat, marketCapStat, rankStat, volumeStat]
                
                
                // additional
                let high = coinModel.high24H?.asCurrencyWith6Decimals() ?? "N/A"
                let highStat = StatisticModel(title: "24h High", value: high)
                
                let low = coinModel.low24H?.asCurrencyWith6Decimals() ?? "N/A"
                let lowStat = StatisticModel(title: "24h Low", value: low)
                
                let priceChange = coinModel.priceChange24H?.asCurrencyWith6Decimals() ?? "N/A"
                let pricePercentChange2 = coinModel.priceChangePercentage24H
                let priceChangeStat = StatisticModel(title: "24h Price Change", value: priceChange, percentageChange: pricePercentChange2)
                
                let marketCapChange = "$" + (coinModel.marketCapChange24H?.formattedWithAbbreviations() ?? "")
                let marketPercentCapChange2 = coinModel.marketCapChangePercentage24H
                let marketCapChangeStat = StatisticModel(title: "24h Market Cap Change", value: marketCapChange, percentageChange: marketPercentCapChange2)
                
                let blockTime = coinDetailModel?.blockTimeInMinutes ?? 0
                let blockTimeString = blockTime == 0 ? "n/a" : "\(blockTime)"
                let blockStat = StatisticModel(title: "Block Time", value: blockTimeString)
                
                let hashing = coinDetailModel?.hashingAlgorithm ?? "n/a"
                let hashingStat = StatisticModel(title: "Hashing Algorithm", value: hashing)
                
                let additionalArray = [
                    highStat, lowStat, priceChangeStat, marketCapChangeStat, blockStat, hashingStat
                ]
                
                
                return (overViewAry, additionalArray)
            }
            .sink { [weak self] returnedArrays in
                self?.overviewStats = returnedArrays.overview
                self?.additionalStats = returnedArrays.additional
            }
            .store(in: &cancellables)
    }
}
