import Foundation

/// Enum representing different API endpoints for TMDB
enum Endpoint {
    case popular(page: Int = 1)
    case search(query: String, page: Int = 1)
    case details(id: Int)
    case videos(id: Int)
    case credits(id: Int)
    
    /// Path component for each endpoint
    private var path: String {
        switch self {
        case .popular:
            return "/movie/popular"
        case .search:
            return "/search/movie"
        case .details(let id):
            return "/movie/\(id)"
        case .videos(let id):
            return "/movie/\(id)/videos"
        case .credits(let id):
            return "/movie/\(id)/credits"
        }
    }
    
    /// Query parameters for each endpoint
    private var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        switch self {
        case .popular(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .search(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        default:
            break
        }
        
        // Always include API key
        items.append(URLQueryItem(name: "api_key", value: API.apiKey))
        return items
    }
    
    /// Full URL constructed from base URL, path, and query items
    var url: URL? {
        guard var components = URLComponents(string: API.baseURL) else { return nil }
        components.path += path
        components.queryItems = queryItems
        return components.url
    }
}
