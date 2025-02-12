import SwiftUI

extension View {
    func registrationToolbar(step: Int, maxStep: Int) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            ToolbarItem(placement: .principal) {
                Text(getString(.registration))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Text(getString(.registrationStep, step, maxStep))
                    .foregroundStyle(.gray)
            }
        }
    }
}
