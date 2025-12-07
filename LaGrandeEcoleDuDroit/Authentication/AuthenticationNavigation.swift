import SwiftUI

struct AuthenticationNavigation: View {
    @State private var path: [AuthRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            AuthenticationDestination(
                onRegisterClick: { path.append(.first) }
            )
            .background(.appBackground)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                    case .first:
                        FirstRegistrationDestination { firstName, lastName in
                            path.append(
                                .second(
                                    firstName: firstName,
                                    lastName: lastName
                                )
                            )
                        }
                        .background(.appBackground)
                        
                    case let .second(firstName, lastName):
                        SecondRegistrationDestination(
                            firstName: firstName,
                            lastName: lastName
                        ) { schoolLevel in
                            path.append(
                                .third(
                                    firstName: firstName,
                                    lastName: lastName,
                                    schoolLevel: schoolLevel
                                )
                            )
                        }
                        .background(.appBackground)
                        
                    case let .third(firstName, lastName, schoolLevel):
                        ThirdRegistrationDestination(
                            firstName: firstName,
                            lastName: lastName,
                            schoolLevel: schoolLevel
                        )
                        .background(.appBackground)
                }
            }
        }
    }
}

private enum AuthRoute: Hashable {
    case first
    case second(firstName: String, lastName: String)
    case third(firstName: String, lastName: String, schoolLevel: SchoolLevel)
}
