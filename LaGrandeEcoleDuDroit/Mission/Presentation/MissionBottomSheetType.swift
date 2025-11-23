enum MissionBottomSheetType: Identifiable {
    case addTask
    case editTask(missionTask: MissionTask)
    case selectManager

    var id: Int {
        switch self {
            case .addTask: 0
            case .editTask: 1
            case .selectManager: 2
        }
    }
}
