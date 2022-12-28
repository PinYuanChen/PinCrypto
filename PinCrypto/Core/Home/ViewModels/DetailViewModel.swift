//
// Created on 2022/12/28.
//

import Foundation
import Combine

class DetailViewModel: ObservableObject {
    
    init(coin: CoinModel) {
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
            .sink { returnedCoinDetail in
                print(returnedCoinDetail)
            }
            .store(in: &cancellables)
    }
}
