import SwiftUI

private struct Toast: View {
    @State private var message: String
    @State private var isShowingCenter = false
    @State private var isShowingBottom = false
    @State private var isShowingLoading = false
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Show center toast") {
                isShowingCenter = true
            }
            .padding()
            .background(Color.blue)
            .clipShape(.rect(cornerRadius: 10))
            
            Button("Show bottom toast") {
                isShowingBottom = true
            }
            .padding()
            .background(Color.blue)
            .clipShape(.rect(cornerRadius: 10))
            
            Button("Show loading toast") {
                isShowingLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isShowingLoading = false
                }
            }
            .padding()
            .background(Color.blue)
            .clipShape(.rect(cornerRadius: 10))
        }
        .toast(isPresented: $isShowingCenter, message: message, position: .center)
        .toast(isPresented: $isShowingBottom, message: message)
        .toast(isPresented: $isShowingLoading, message: getString(.loading), position: .center, type: .loading)
    }
}

#Preview {
    Toast("There is a toast message")
}
