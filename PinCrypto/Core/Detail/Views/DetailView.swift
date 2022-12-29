//
// Created on 2022/12/28.
//

import SwiftUI

struct DetailLoadingView: View {
    
    @Binding var coin: CoinModel?
    
    var body: some View {
        ZStack {
            if let coin = coin {
                DetailView(coin: coin)
            }
        }
    }
}

struct DetailView: View {
    
    @StateObject private var vm: DetailViewModel
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    private let spacing: CGFloat = 30
    
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("")
                    .frame(height: 150)
                
                Text("Overview")
                    .font(.title)
                    .foregroundColor(.theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                
                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: spacing,
                    pinnedViews: []) {
                        ForEach(vm.overviewStats) { stat in
                            StatisticView(stat: stat)
                        }
                    }
                
                Text("Additional Details")
                    .font(.title)
                    .foregroundColor(.theme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyVGrid(
                    columns: columns,
                    alignment: .leading,
                    spacing: spacing,
                    pinnedViews: []) {
                        ForEach(vm.additionalStats) { stat in
                            StatisticView(stat: stat)
                        }
                    }
                Divider()
            }
            .padding()
        }
        .navigationTitle(vm.coin.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(coin: dev.coin)
        }
    }
}
