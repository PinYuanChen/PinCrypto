//
// Created on 2022/12/22.
//

import UIKit
import Combine

class CoinImageService {
    
    @Published var image: UIImage? = nil
    private var imageSubscription: AnyCancellable?
    private let coin: CoinModel
    private let fileManager = LocalFileManager.instance
    private let folderName = "coin_images"
    private let imageName: String
    
    init(coin: CoinModel) {
        self.coin = coin
        self.imageName = coin.id
        getCoinImage()
    }
    
}

private extension CoinImageService {
    
    func getCoinImage() {
        if let savedImage = fileManager.getImage(
            imageName: imageName,
            folderName: folderName
        ) {
            image = savedImage
            print("Retrieved image from File Manager!")
        } else {
            downloadCoinImage()
            print("Downloading image now")
        }
    }
    
    func downloadCoinImage() {
        guard let url = URL(string: coin.image) else { return }
        
        imageSubscription = NetworkingManager
            .download(url: url)
            .tryMap { data -> UIImage? in
                return UIImage(data: data)
            }
            .sink(receiveCompletion: NetworkingManager.handleCompletion, receiveValue: { [weak self] returnedImage in
                guard let self = self,
                let downloadedImage = returnedImage else { return }
                
                self.image = downloadedImage
                self.imageSubscription?.cancel()
                self.fileManager.saveImage(image: downloadedImage,
                                           imageName: self.imageName,
                                           folderName: self.folderName)
            })
    }
}
