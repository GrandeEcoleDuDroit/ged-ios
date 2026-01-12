import SwiftUI

extension View {
    func alertImageTooLargeError(isPresented: Binding<Bool>) -> some View {
        self.alert(
            stringResource(.imageTooLargeErrorTitle),
            isPresented: isPresented,
            actions: {
                Button(stringResource(.ok)) {
                    isPresented.wrappedValue = false
                }
            },
            message: {
                Text(stringResource(.imageTooLargeErrorMessage, CommonUtilsPresentation.maxImageFileSizeString))
            }
        )
    }
}
