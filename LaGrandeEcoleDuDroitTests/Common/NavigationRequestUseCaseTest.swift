import Testing

@testable import GrandeEcoleDuDroit

class NavigationRequestUseCaseTest {
    @Test
    func navigate_should_update_routeToNavigate() async {
        // Given
        let routeToNavigate = (
            MessageMainRoute.conversation,
            [MessageRoute.chat(conversation: conversationFixture)]
        )
        let useCase = NavigationRequestUseCase()
        
        // When
        useCase.navigate(
            to: RouteToNavigate(
                mainRoute: routeToNavigate.0,
                routes: routeToNavigate.1
            )
        )
        var iterator = useCase.routeToNavigate.values.makeAsyncIterator()
        let result = await iterator.next()
        
        // Then
        let mainRoute = result?.mainRoute as? MessageMainRoute
        let routes = result?.routes.map { $0 as? MessageRoute }
        
        #expect(
            mainRoute == routeToNavigate.0 &&
            routes == routeToNavigate.1
        )
    }
    
    @Test
    func resetRoute_should_set_routeToNavigate_to_nil() async {
        // Given
        let routeToNavigate = (
            MessageMainRoute.conversation,
            [MessageRoute.chat(conversation: conversationFixture)]
        )
        let useCase = NavigationRequestUseCase()
        
        // When
        useCase.navigate(
            to: RouteToNavigate(
                mainRoute: routeToNavigate.0,
                routes: routeToNavigate.1
            )
        )
        useCase.resetRoute()
        var iterator = useCase.routeToNavigate.values.makeAsyncIterator()
        let result = await iterator.next()
        
        // Then
        let mainRoute = result?.mainRoute as? MessageMainRoute
        let routes = result?.routes.map { $0 as? MessageRoute }
        
        #expect(
            mainRoute == nil &&
            routes == nil
        )
    }
}
