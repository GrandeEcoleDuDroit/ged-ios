import Foundation

extension Mission {
    func toRemote() -> OutboundRemoteMission? {
        let schoolevelNumbers = schoolLevels.map { $0.number }
        guard let schoolLevelNumbersJson = try? JSONEncoder().encode(schoolevelNumbers) else {
            return nil
        }
        
        let managersIds = managers.map { $0.id }
        guard let managersIdsJson = try? JSONEncoder().encode(managersIds) else {
            return nil
        }
        
        let participantIds = participants.map { $0.id }
        guard let participantIdsJson = try? JSONEncoder().encode(participantIds) else {
            return nil
        }
        
        let remoteMissionTasks = tasks.map { $0.toRemote() }
        guard let remoteMissionTasksJson = try? JSONEncoder().encode(remoteMissionTasks) else {
            return nil
        }
        
        let imageFileName: String? = switch state {
            case .draft: nil
            case let .publishing(imagePath): MissionUtils.ImageFile.getFileNameFromPath(path: imagePath)
            case let .published(imageUrl): MissionUtils.ImageFile.getFileNameFromUrl(url: imageUrl)
            case let .error(imagePath): MissionUtils.ImageFile.getFileNameFromPath(path: imagePath)
        }
        
        return OutboundRemoteMission(
            missionId: id,
            missionTitle: title,
            missionDescription: description,
            missionSchoolLevels: String(data: schoolLevelNumbersJson, encoding: .utf8) ?? "[]",
            missionDate: date.toEpochMilli(),
            missionStartDate: startDate.toEpochMilli(),
            missionEndDate: endDate.toEpochMilli(),
            missionDuration: duration,
            missionManagerIds: String(data: managersIdsJson, encoding: .utf8) ?? "[]",
            missionParticipantIds: String(data: participantIdsJson, encoding: .utf8) ?? "[]",
            missionMaxParticipants: maxParticipants,
            missionTasks: String(data: remoteMissionTasksJson, encoding: .utf8) ?? "",
            missionImageFileName: imageFileName
        )
    }
}

extension LocalMission {
    func toMission(getImagePath: (String) -> String?) -> Mission? {
        guard let missionId = missionId,
              let missionTitle = missionTitle,
              let missionDescription = missionDescription,
              let missionDate = missionDate,
              let missionStartDate = missionStartDate,
              let missionEndDate = missionEndDate,
              let missionManagers = missionManagers,
              let missionState = missionState
        else { return nil }
        
        let schoolLevelNumbers = (
            try? JSONDecoder().decode(
                [Int].self,
                from: (missionSchoolLevels ?? "[]").data(using: .utf8) ?? Data()
            )
        ) ?? []
        
        let localManagers = (
            try? JSONDecoder().decode(
                [LocalUser].self,
                from: (missionManagers).data(using: .utf8) ?? Data()
            )
        ) ?? []
        
        let localParticipants = (
            try? JSONDecoder().decode(
                [LocalUser].self,
                from: (missionParticipants ?? "[]").data(using: .utf8) ?? Data()
            )
        ) ?? []
        
        let localMissionTasks = (
            try? JSONDecoder().decode(
                [LocalMissionTask].self,
                from: (missionTasks ?? "[]").data(using: .utf8) ?? Data()
            )
        ) ?? []
        
        let imagePath: String? = if let missionImageFileName {
            getImagePath(missionImageFileName)
        } else {
            nil
        }
        
        let state: Mission.MissionState = switch missionState {
            case _ where missionState == Mission.MissionState.MissionStateType.draft.rawValue: .draft
                
            case _ where missionState == Mission.MissionState.MissionStateType.publishing.rawValue:
                    .publishing(imagePath: imagePath)
                
            case _ where missionState == Mission.MissionState.MissionStateType.published.rawValue:
                    .published(imageUrl: MissionUtils.ImageFile.url(fileName: missionImageFileName))
                
            default: Mission.MissionState.error(imagePath: imagePath)
        }
        
        return Mission(
            id: missionId,
            title: missionTitle,
            description: missionDescription,
            date: missionDate,
            startDate: missionStartDate,
            endDate: missionEndDate,
            schoolLevels: schoolLevelNumbers.map { SchoolLevel.fromNumber($0) },
            managers: localManagers.map { $0.toUser() },
            participants: localParticipants.map { $0.toUser() },
            maxParticipants: Int(missionMaxParticipants),
            tasks: localMissionTasks.map { $0.toMissionTask() },
            state: state
        )
    }
    
    func modify(mission: Mission) {
        let schoolevelNumbers = mission.schoolLevels.map { $0.number }
        let schoolLevelNumbersJsonData = try? JSONEncoder().encode(schoolevelNumbers)
    
        let localManagers = mission.managers.map { $0.toLocal() }
        let localManagersJsonData = try? JSONEncoder().encode(localManagers)
        
        let localParticipants = mission.participants.map { $0.toLocal() }
        let localParticipantsJsonData = try? JSONEncoder().encode(localParticipants)
        
        let localMissionTasks = mission.tasks.map { $0.toLocal() }
        let localMissionTasksJsonData = try? JSONEncoder().encode(localMissionTasks)
        
        let imageFileName: String? = switch mission.state {
            case .draft: nil
            case let .publishing(imagePath): MissionUtils.ImageFile.getFileNameFromPath(path: imagePath)
            case let .published(imageUrl): MissionUtils.ImageFile.getFileNameFromUrl(url: imageUrl)
            case let .error(imagePath): MissionUtils.ImageFile.getFileNameFromPath(path: imagePath)
        }
        
        missionId = mission.id
        missionTitle = mission.title
        missionDescription = mission.description
        
        if let data = schoolLevelNumbersJsonData {
            missionSchoolLevels = String(data: data, encoding: .utf8) ?? missionSchoolLevels
        }
        
        missionDate = mission.date
        missionStartDate = mission.startDate
        missionEndDate = mission.endDate
        missionDuration = mission.duration
        
        if let data = localManagersJsonData {
            missionManagers = String(data: data, encoding: .utf8) ?? missionManagers
        }
        
        if let data = localParticipantsJsonData {
            missionParticipants = String(data: data, encoding: .utf8) ?? missionParticipants
        }

        missionMaxParticipants = Int32(truncatingIfNeeded: mission.maxParticipants)
        
        if let data = localMissionTasksJsonData {
            missionTasks = String(data: data, encoding: .utf8) ?? missionTasks
        }
        
        missionImageFileName = imageFileName
        missionState = mission.state.description
    }
    
    func equals(_ mission: Mission) -> Bool {
        let schoolevelNumbers = mission.schoolLevels.map { $0.number }
        let schoolLevelNumbersJsonData = try? JSONEncoder().encode(schoolevelNumbers)
    
        let localManagers = mission.managers.map { $0.toLocal() }
        let localManagersJsonData = try? JSONEncoder().encode(localManagers)
        
        let localParticipants = mission.participants.map { $0.toLocal() }
        let localParticipantsJsonData = try? JSONEncoder().encode(localParticipants)
        
        let localMissionTasks = mission.tasks.map { $0.toLocal() }
        let localMissionTasksJsonData = try? JSONEncoder().encode(localMissionTasks)
        
        let imageFileName: String? = switch mission.state {
            case .draft: nil
            case let .publishing(imagePath): MissionUtils.ImageFile.getFileNameFromPath(path: imagePath)
            case let .published(imageUrl): MissionUtils.ImageFile.getFileNameFromUrl(url: imageUrl)
            case let .error(imagePath): MissionUtils.ImageFile.getFileNameFromPath(path: imagePath)
        }
        
        let sameSchoolLevels = if let data = schoolLevelNumbersJsonData {
            missionSchoolLevels == (String(data: data, encoding: .utf8) ?? "")
        } else {
            true
        }
        
        let sameManagers = if let data = localManagersJsonData {
            missionManagers == (String(data: data, encoding: .utf8) ?? "")
        } else {
            true
        }
        
        let sameParticipants = if let data = localParticipantsJsonData {
            missionParticipants == (String(data: data, encoding: .utf8) ?? "")
        } else {
            true
        }
        
        let sameMissionTasks = if let data = localMissionTasksJsonData {
            missionTasks == (String(data: data, encoding: .utf8) ?? "")
        } else {
            true
        }
        
        return (
            missionId == mission.id &&
            missionTitle == mission.title &&
            missionDescription == mission.description &&
            sameSchoolLevels &&
            missionDate == mission.date &&
            missionStartDate == mission.startDate &&
            missionEndDate == mission.endDate &&
            missionDuration == mission.duration &&
            sameManagers &&
            sameParticipants &&
            missionMaxParticipants == Int32(truncatingIfNeeded: mission.maxParticipants) &&
            sameMissionTasks &&
            missionImageFileName == imageFileName &&
            missionState == mission.state.description
        )
    }
}

extension InboundRemoteMission {
    func toMission() -> Mission {
        let schoolLevelNumbers = (
            try? JSONDecoder().decode(
                [Int].self,
                from: missionSchoolLevels?.data(using: .utf8) ?? Data()
            )
        ) ?? []

        return Mission(
            id: missionId,
            title: missionTitle,
            description: missionDescription,
            date: missionDate.toDate(),
            startDate: missionStartDate.toDate(),
            endDate: missionEndDate.toDate(),
            schoolLevels: schoolLevelNumbers.map { SchoolLevel.fromNumber($0) },
            managers: missionManagers.map { $0.toUser() },
            participants: missionParticipants?.map { $0.toUser() } ?? [],
            maxParticipants: missionMaxParticipants,
            tasks: missionTasks?.map { $0.toMissionTask() } ?? [],
            state: Mission.MissionState.published(imageUrl: MissionUtils.ImageFile.url(fileName: missionImageFileName))
        )
    }
}

extension AddMissionParticipant {
    func toRemote() -> RemoteAddMissionParticipant {
        RemoteAddMissionParticipant(
            missionId: missionId,
            missionSchoolLevels: schoolLevels.map { $0.number },
            missionMaxParticipants: maxParticipants,
            missionParticipantsNumber: participantsNumber,
            userId: user.id,
            userSchoolLevel: user.schoolLevel.number
        )
    }
}

extension MissionReport {
    func toRemote() -> RemoteMissionReport {
        RemoteMissionReport(
            missionId: missionId,
            reporter: reporter.toRemote(),
            reason: reason.rawValue
        )
    }
}

private extension MissionReport.Reporter {
    func toRemote() -> RemoteMissionReport.RemoteReporter {
        RemoteMissionReport.RemoteReporter(
            fullName: fullName,
            email: email
        )
    }
}
