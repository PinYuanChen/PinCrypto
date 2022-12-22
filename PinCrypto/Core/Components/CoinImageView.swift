//
// Created on 2022/12/22.
//

import SwiftUI

class CoinImageViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var isLoading = false
    
    init() {
        getImage()
    }
    
    private func getImage() {
        
    }
}

struct CoinImageView: View {
    
    @State var vm = CoinImageViewModel()
    
    var body: some View {
        ZStack {
            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else if vm.isLoading {
                ProgressView()
            } else {
                Image(systemName: "questionmark")
                    .foregroundColor(.theme.secondaryText)
            }
        }
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static var previews: some View {
        CoinImageView()
            .previewLayout(.sizeThatFits)
    }
}
