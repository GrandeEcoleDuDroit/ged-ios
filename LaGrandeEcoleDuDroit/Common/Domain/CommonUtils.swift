import Foundation

func stringResource(_ value: StringResource) -> String {
    NSLocalizedString(value.rawValue, comment: "")
}

func stringResource(_ value: StringResource, _ args: CVarArg...) -> String {
    String(
        format: NSLocalizedString(value.rawValue, comment: ""),
        arguments: args
    )
}

@MainActor
func performUiBlockingRequest(
    block: @escaping () async throws -> Void,
    onLoading: @escaping () -> Void,
    onError: @escaping (Error) -> Void,
    onFinshed: @escaping () -> Void = {}
) {
    var loadingTask: Task<Void, Error>?
    
    Task { @MainActor in
        do {
            loadingTask = Task { @MainActor in
                try await Task.sleep(for: .milliseconds(300))
                onLoading()
            }
            
            try await block()
        } catch {
            onError(error)
        }
        
        loadingTask?.cancel()
        onFinshed()
    }
}
