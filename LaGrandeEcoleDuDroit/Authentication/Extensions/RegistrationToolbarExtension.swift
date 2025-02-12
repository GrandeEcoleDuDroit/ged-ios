import SwiftUI

extension View {
    func registrationToolbar(step: Int, maxStep: Int) -> some View {
        self
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
            ToolbarItem(placement: .principal) {
                Text(getString(gedString: GedString.registration))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Text(getString(gedString: GedString.registration_step, step, maxStep))
                    .foregroundStyle(.gray)
            }
        }
    }
}
