//
// Created on 2022/12/26.
//

import SwiftUI

struct PortfolioView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var vm: HomeViewModel
    @State private var selectedCoin: CoinModel? = nil
    @State private var quantityText = ""
    @State private var showCheckMark = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                portfolioInputSection
            }
            .navigationTitle("Edit Portfolio")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton(presentationMode: presentationMode)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingNavBarButton
                }
            })
        }
    }
}

struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
            .environmentObject(dev.homeVM)
    }
}

private extension PortfolioView {
    var coinLogoList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(vm.allCoins) { coin in
                    CoinLogoView(coin: coin)
                        .frame(width: 75)
                        .padding(4)
                        .onTapGesture {
                            withAnimation(.easeIn) {
                                selectedCoin = coin
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke( selectedCoin?.id == coin.id ? Color.theme.green : .clear, lineWidth: 1)
                        )
                }
            }
            .frame(height: 120)
            .padding(.leading)
        }
    }
    
    func getCurrentValue() -> Double {
        if let quantity = Double(quantityText) {
            return quantity * (selectedCoin?.currentPrice ?? 0)
        }
        return 0
    }
    
    var portfolioInputSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SearchBarView(searchText: $vm.searchText)
            coinLogoList
            
            if selectedCoin != nil {
                VStack(spacing: 20) {
                    HStack {
                        Text("Current price of \(selectedCoin?.symbol.uppercased() ?? ""):")
                        Spacer()
                        Text(selectedCoin?.currentPrice.asCurrencyWith6Decimals() ?? "")
                    }
                    Divider()
                    HStack {
                        Text("Amount holding:")
                        Spacer()
                        TextField("Ex: 1.4", text: $quantityText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    Divider()
                    HStack {
                        Text("Current value:")
                        Spacer()
                        Text(getCurrentValue().asCurrencyWith2Decimals())
                    }
                }
                .animation(.none, value: selectedCoin?.id)
                .padding()
                .font(.headline)
            }
        }
    }
    
    var trailingNavBarButton: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark")
                .opacity(showCheckMark ? 1.0 : 0.0)
            Button {
                savedButtonPressed()
            } label: {
                Text("Save".uppercased())
            }
            .opacity(
                (selectedCoin != nil && selectedCoin?.currentHoldings != Double(quantityText)) ?
                1.0 : 0.0
            )
        }
        .font(.headline)
    }
    
    func savedButtonPressed() {
        guard let coin = selectedCoin else { return }
        
        // save to portfolio
        
        // show check mark
        withAnimation(.easeIn) {
            showCheckMark = true
            removeSelectedCoin()
        }
        
        // hide the keyboard
        UIApplication.shared.endEditing()
        
        // hide check mark
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut) {
                showCheckMark = false
            }
        }
    }
    
    func removeSelectedCoin() {
        selectedCoin = nil
        vm.searchText = ""
    }
}
