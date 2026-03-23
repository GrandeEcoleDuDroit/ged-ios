import Foundation

class UpdateMissionUseCase {
    private let missionRepository: MissionRepository
    
    init(missionRepository: MissionRepository) {
        self.missionRepository = missionRepository
    }
    
    func execute(user: User, mission: Mission, imageData: Data?) async throws {
        var missionToUpdate = mission
        let missionSchoolLevelsSet = Set(mission.schoolLevels)
        var fileData: FileData?
        
        if let imageData, let imageExtension = imageData.imageExtension() {
            let fileName = "\(MissionUtils.Image.generateFileName(missionId: mission.id)).\(imageExtension)"
            let path = MissionUtils.Image.getRelativePath(fileName: fileName)
            fileData = FileData(path: path, data: imageData)
            missionToUpdate.state = .published(imageUrl: fileName)
        }
        
        missionToUpdate.participants = missionToUpdate.participants.filter {
            missionSchoolLevelsSet.contains($0.schoolLevel)
        }
        
        try await missionRepository.updateMission(user: user, mission: missionToUpdate, fileData: fileData)
    }
}
