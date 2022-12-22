//
// Created on 2022/12/22.
//

import SwiftUI
import Combine

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading = false
    
    private let coin: CoinModel
    private let dataService: CoinImageService
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        self.coin = coin
        self.dataService = CoinImageService(coin: coin)
        addSubscribers()
        isLoading = true
    }
    
    private func addSubscribers() {
        dataService
            .$image
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isLoading = false
            } receiveValue: { [weak self] returnedImage in
                guard let self = self else { return }
                self.image = returnedImage
            }
            .store(in: &cancellables)

    }
}
