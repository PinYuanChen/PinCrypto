//
// Created on 2022/12/22.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var allCoins = [CoinModel]()
    @Published var portfolioCoins = [CoinModel]()
    @Published var searchText = ""
    
    private let dataService = CoinDataService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        dataService
            .$allCoins
            .sink { [weak self] returnCoins in
                guard let self = self else { return }
                self.allCoins = returnCoins
            }
            .store(in: &cancellables)
    }
}
