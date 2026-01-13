import SwiftUI
import Combine

class SecondRegistrationViewModel: ViewModel {
    @Published var schoolLevel: SchoolLevel
    let schoolLevels: [SchoolLevel] = SchoolLevel.all
    
    init() {
        self.schoolLevel = SchoolLevel.ged1
    }
}
