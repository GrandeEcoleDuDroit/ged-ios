import SwiftUI

extension View {
    func alertImageTooLargeError(isPresented: Binding<Bool>, maxSize: Int64 = CommonPresentationUtils.maxImageFileSize) -> some View {
        self.alert(
            stringResource(.imageTooLargeErrorTitle),
            isPresented: isPresented,
            actions: {
                Button(stringResource(.ok)) {
                    isPresented.wrappedValue = false
                }
            },
            message: {
                Text(CommonPresentationUtils.imageTooLargeErrorMessage(maxSize: maxSize))
            }
        )
    }
}
