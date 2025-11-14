import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false

    var body: some View {
        Image(.gedLogo)
            .fitCircle(scale: 2)
            .scaleEffect(isAnimating ? 1 : 0.9)
            .onAppear() {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.background)
    }
}

#Preview {
    SplashScreen()
}
