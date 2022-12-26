//
// Created on 2022/12/26.
//

import SwiftUI

struct XMarkButton: View {
    
    var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

//struct XMarkButton_Previews: PreviewProvider {
//    static var previews: some View {
//        XMarkButton(presentationMode: )
//    }
//}
