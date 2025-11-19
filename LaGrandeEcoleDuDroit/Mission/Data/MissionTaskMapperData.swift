extension MissionTask {
    func toLocal() -> LocalMissionTask {
        LocalMissionTask(
            missionTaskId: id,
            missionTaskValue: value
        )
    }
    
    func toRemote() -> RemoteMissionTask {
        RemoteMissionTask(
            missionTaskId: id,
            missionTaskValue: value
        )
    }
}

extension LocalMissionTask {
    func toMissionTask() -> MissionTask {
        MissionTask(
            id: missionTaskId,
            value: missionTaskValue
        )
    }
}

extension RemoteMissionTask {
    func toMissionTask() -> MissionTask {
        MissionTask(
            id: missionTaskId,
            value: missionTaskValue
        )
    }
}
