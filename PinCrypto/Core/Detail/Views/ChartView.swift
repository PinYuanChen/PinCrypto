//
// Created on 2022/12/29.
//

import SwiftUI

struct ChartView: View {
    
    let data: [Double]
    
    init(coin: CoinModel) {
        self.data = coin.sparklineIn7D?.price ?? []
    }
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for index in data.indices {
                    let xPosition = geometry.size.width / CGFloat(data.count) * CGFloat(index + 1)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: 0, y: 0))
                    }
                    path.addLine(to: CGPoint(x: xPosition, y: 0))
                }
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(coin: dev.coin)
    }
}
