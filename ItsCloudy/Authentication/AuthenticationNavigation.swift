import SwiftUI

struct AuthenticationNavigation: View {
    @State private var path: [AuthenticationRoute] = []
    @StateObject private var appStateManager = AppStateManager()

    var body: some View {
        NavigationStack(path: $path) {
            AuthenticationDestination(
                onRegisterClick: { path.append(.firstRegistration) },
                onForgottenPasswordClick: { path.append(.forgottenPassword) }
            )
            .background(Color.appBackground.ignoresSafeArea(.all))
            .navigationDestination(for: AuthenticationRoute.self) { route in
                switch route {
                    case .firstRegistration:
                        FirstRegistrationDestination { firstName, lastName in
                            path.append(
                                .secondRegistration(
                                    firstName: firstName,
                                    lastName: lastName
                                )
                            )
                        }
                        .background(Color.appBackground.ignoresSafeArea(.all))

                    case let .secondRegistration(firstName, lastName):
                        SecondRegistrationDestination(
                            firstName: firstName,
                            lastName: lastName
                        ) { schoolLevel in
                            path.append(
                                .thirdRegistration(
                                    firstName: firstName,
                                    lastName: lastName,
                                    schoolLevel: schoolLevel
                                )
                            )
                        }
                        .background(Color.appBackground.ignoresSafeArea(.all))

                    case let .thirdRegistration(firstName, lastName, schoolLevel):
                        ThirdRegistrationDestination(
                            firstName: firstName,
                            lastName: lastName,
                            schoolLevel: schoolLevel
                        )
                        .background(Color.appBackground.ignoresSafeArea(.all))
                        .environmentObject(appStateManager)
                        
                    case .forgottenPassword:
                        ForgottenPasswordDestination()
                            .background(Color.appBackground.ignoresSafeArea(.all))
                }
            }
        }
        .loading(appStateManager.state.loading)
    }
}

private enum AuthenticationRoute: Hashable {
    case firstRegistration
    case secondRegistration(firstName: String, lastName: String)
    case thirdRegistration(firstName: String, lastName: String, schoolLevel: SchoolLevel)
    case forgottenPassword
}
