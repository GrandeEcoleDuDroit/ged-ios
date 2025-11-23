import Testing

@testable import GrandeEcoleDuDroit

class GenerateIdUseCaseTest {
    @Test
    func generatedIdUseCase_stringId_should_generate_unique_id() {
        for _ in 0..<100000 {
            let id1 = GenerateIdUseCase.execute()
            let id2 = GenerateIdUseCase.execute()
            #expect(id1 != id2)
        }
    }
    
    @Test
    func generatedIdUseCase_uuid_should_generate_unique_id() {
        for _ in 0..<100000 {
            let id1 = GenerateIdUseCase.execute()
            let id2 = GenerateIdUseCase.execute()
            #expect(id1 != id2)
        }
    }
}
