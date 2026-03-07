struct AlertData<T> {
    let title: String
    private(set) var message: String? = nil
    private(set) var data: T? = nil
    var presented: Bool = false
    
    init(_ title: String) where T == Void {
        self.title = title
    }
    
    mutating func present() {
        self.presented = true
    }
    
    mutating func present(data: T) {
        self.data = data
        self.presented = true
    }
    
    mutating func dismiss() {
        self.data = nil
        self.presented = false
    }
}

extension AlertData {
    init(
        _ title: String,
        data: T? = nil
    ) {
        self.title = title
        self.data = data
    }
}
