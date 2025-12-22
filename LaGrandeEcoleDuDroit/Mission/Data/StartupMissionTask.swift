class StartupMissionTask {
    private let networkMonitor: NetworkMonitor
    private let missionRepository: MissionRepository
    private let resendMissionUseCase: ResendMissionUseCase
    private let tag = String(describing: StartupMissionTask.self)

    init(
        networkMonitor: NetworkMonitor,
        missionRepository: MissionRepository,
        resendMissionUseCase: ResendMissionUseCase
    ) {
        self.networkMonitor = networkMonitor
        self.missionRepository = missionRepository
        self.resendMissionUseCase = resendMissionUseCase
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
                    await resendMissionUseCase.execute(mission: mission)
                }
            }
        } catch {
            e(tag, "Failed to send unsent missions", error)
        }
    }
}
