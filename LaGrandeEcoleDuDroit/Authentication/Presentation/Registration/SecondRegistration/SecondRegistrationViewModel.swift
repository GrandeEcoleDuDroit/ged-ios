import SwiftUI
import Combine

class SecondRegistrationViewModel: ViewModel {
    @Published var schoolLevel: SchoolLevel
    let schoolLevels: [SchoolLevel] = SchoolLevel.allCases
    
    init() {
        self.schoolLevel = SchoolLevel.ged1
    }
}
