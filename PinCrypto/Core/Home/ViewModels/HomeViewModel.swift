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
        $searchText
            .combineLatest(dataService.$allCoins)
            .map { (text, startingCoins) -> [CoinModel] in
                
                guard !text.isEmpty else { return startingCoins }
                
                let lowercasedText = text.lowercased()
                return startingCoins.filter { $0.name.lowercased().contains(lowercasedText) ||
                    $0.symbol.lowercased().contains(lowercasedText) ||
                    $0.id.lowercased().contains(lowercasedText)
                }
            }
            .sink { [weak self] returnedCoins in
                self?.allCoins = returnedCoins
            }
            .store(in: &cancellables)
    }
}
