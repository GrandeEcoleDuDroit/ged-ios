
protocol Route : Hashable {}

protocol MainRoute: Route {}

struct RouteToNavigate {
    let mainRoute: any MainRoute
    let routes: [any Route]
}
