import SwiftUI

struct AuthenticationNavigation: View {
    @State private var path: [AuthRoute] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            AuthenticationDestination(
                onRegisterClick: { path.append(.first) }
            )
            .background(Color.appBackground.ignoresSafeArea(.all))
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
                        .background(Color.appBackground.ignoresSafeArea(.all))

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
                        .background(Color.appBackground.ignoresSafeArea(.all))

                    case let .third(firstName, lastName, schoolLevel):
                        ThirdRegistrationDestination(
                            firstName: firstName,
                            lastName: lastName,
                            schoolLevel: schoolLevel
                        )
                        .background(Color.appBackground.ignoresSafeArea(.all))
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
