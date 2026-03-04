actor MissionTaskQueue {
    private(set) var tasks: [String: Task<Void, Never>] = [:]

    func addTask(_ task: Task<Void, Never>, for key: String) {
        tasks[key] = task
    }
    
    func removeTask(for key: String) {
        tasks[key] = nil
    }
    
    func cancelTask(for key: String) {
        tasks[key]?.cancel()
        tasks[key] = nil
    }
}
