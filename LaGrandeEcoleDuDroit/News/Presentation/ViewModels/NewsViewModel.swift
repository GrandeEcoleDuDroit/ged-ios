import SwiftUI

class NewsViewModel: ObservableObject {
    @Published var user: User?
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase = GetCurrentUserUseCase()
    
    func fetchUser() {
        user = getCurrentUserUseCase.execute()
    }
}
