import Foundation

class GenerateIdUseCase {
    func execute() -> String {
        UUID().uuidString
    }
}
