class StartupMissionTask {
    private let networkMonitor: NetworkMonitor
    private let missionRepository: MissionRepository
    private let recreateMissionUseCase: RecreateMissionUseCase
    private let tag = String(describing: StartupMissionTask.self)

    init(
        networkMonitor: NetworkMonitor,
        missionRepository: MissionRepository,
        recreateMissionUseCase: RecreateMissionUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.missionRepository = missionRepository
        self.recreateMissionUseCase = recreateMissionUseCase
    }
    
    func run() {
        Task {
            await networkMonitor.connected.values.first { $0 }
            await sendUnsentMissions()
        }
    }
    
    private func sendUnsentMissions() async {
        do {
            let missions = try await missionRepository.getLocalMissions()
            for mission in missions {
                if case .publishing = mission.state {
                    await recreateMissionUseCase.execute(mission: mission)
                }
            }
        } catch {
            w(tag, "Failed to send unsent missions: \(error.localizedDescription)")
        }
    }
}
