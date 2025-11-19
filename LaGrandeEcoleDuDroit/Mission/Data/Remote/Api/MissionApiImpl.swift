import Foundation

class MissionApiImpl: MissionApi {
    private let tokenProvider: TokenProvider
    private let base = "missions"

    init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }
    
    func getMissions() async throws -> (URLResponse, [InboundRemoteMission]) {
        let url = try RequestUtils.getUrl(base: base, endPoint: "")
        
        let session = RequestUtils.getSession()
        let authToken = await tokenProvider.getAuthToken()
        let request = RequestUtils.formatGetRequest(
            url: url,
            authToken: authToken
        )
        
        let (data, urlResponse) = try await session.data(for: request)
        let missions = try JSONDecoder().decode([InboundRemoteMission].self, from: data)
        return (urlResponse, missions)
    }
}
