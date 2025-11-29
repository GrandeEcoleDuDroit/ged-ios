import Testing

@testable import GrandeEcoleDuDroit

class GenerateIdUseCaseTest {
    @Test
    func generatedIdUseCase_stringId_should_generate_unique_id() {
        let generationidUseCase = GenerateIdUseCase()
        
        for _ in 0..<100000 {
            let id1 = generationidUseCase.execute()
            let id2 = generationidUseCase.execute()
            #expect(id1 != id2)
        }
    }
    
    @Test
    func generatedIdUseCase_uuid_should_generate_unique_id() {
        let generationidUseCase = GenerateIdUseCase()

        for _ in 0..<100000 {
            let id1 = generationidUseCase.execute()
            let id2 = generationidUseCase.execute()
            #expect(id1 != id2)
        }
    }
}
