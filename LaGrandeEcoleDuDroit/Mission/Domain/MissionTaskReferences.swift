actor MissionTaskReferences {
    private(set) var tasks: [String: Task<Void, Never>] = [:]

    func addTaskReference(_ task: Task<Void, Never>, for key: String) {
        tasks[key] = task
    }
    
    func removeTaskReference(for key: String) {
        tasks[key] = nil
    }
}
