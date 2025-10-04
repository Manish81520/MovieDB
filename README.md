# MovieDB iOS App
A modern iOS application for browsing popular movies with comprehensive error handling.
## 🎬 Features
- **Popular Movies Browser**: Browse trending and popular movies
- **Movie Details**: View detailed information about each movie
- **Favorites Management**: Save and manage your favorite movies
- **Search Functionality**: Search for movies by title
- **Smart Error Handling**: Comprehensive error handling and user feedback
## 🏗️ Architecture
The app follows a clean MVVM architecture with the following structure:
```
MovieDB/
├── App/                    # App lifecycle and configuration
├── Constants/
├── Features/              # Feature-based modules
│   ├── Home/             # Popular movies listing
│   ├── MovieDetail/      # Movie details screen
│   ├── Search/           # Movie search functionality
│   └── Favorite/         # Favorites management
├── Models/               # Data models
├── Networking/           # API and network layer
├── Persistence/          # Core Data and local storage
├── Utilities/              # Shared utilities and components
└── Resources/           # Assets and resources
```
## 🔧 Key Components
### Networking Layer
- **APIService**: Handles all API communications with comprehensive error handling
- **NetworkError**: Robust error handling with detailed error messages
- **EndPoints**: Centralized API endpoint management
### Data Models
- **Movie**: Main movie response model
- **MovieResponse**: Individual movie data structure
- **VideoDetail**: Detailed movie information
### Features
- **HomeViewModel**: Manages popular movies with error handling
- **MovieDetailViewModel**: Handles detailed movie information
- **SearchViewModel**: Manages search functionality
- **FavoriteViewModel**: Manages favorites with Core Data
## 🚀 Getting Started
### Prerequisites
- Xcode 12.0 or later
- iOS 13.0 or later
- Swift 5.0 or later
### Installation
1. Clone the repository:
  ```bash
  git clone <repository-url>
  cd MovieDB-Dev
  ```
2. Open the project in Xcode:
  ```bash
  open MovieDB.xcodeproj
  ```
3. Build and run the project
### API Configuration
The app uses The Movie Database (TMDB) API. Make sure to:
1. Obtain an API key from [TMDB](https://www.themoviedb.org/settings/api)
2. Configure the API key in your project settings
3. Update the base URL if needed in `BaseURL.swift`

## 🔄 Error Handling
The app implements comprehensive error handling:
- **Network Errors**: User-friendly error messages with retry options
- **API Errors**: Clear error feedback and recovery mechanisms
- **Data Parsing Errors**: Graceful handling of malformed responses
- **Core Data Errors**: Proper error handling for local storage
  
## 🛠️ Development
### Adding New Features
1. Create feature folder in `Features/`
2. Follow MVVM pattern with ViewModel and Controller
3. Add appropriate models in `Models/`
4. Update networking layer if needed
### Adding New API Endpoints
1. Add endpoint to `EndPoints.swift`
2. Update `APIService.swift` if needed
3. Create corresponding data models
### Code Style
- Follow Swift naming conventions
- Use meaningful variable and function names
- Add documentation for public APIs
- Maintain consistent indentation and formatting
  
## 🤝 Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request
## 📞 Support
For support or questions, please contact [manishrthingalaya@gmail.com]
## 🔮 Future Enhancements
- [ ] Movie trailers and videos
- [ ] User reviews and ratings
- [ ] Advanced filtering and sorting
- [ ] Dark mode support
- [ ] iPad optimization
- [ ] Widget support
- [ ] Push notifications for new releases
---
**Built with ❤️ using Swift and UIKit**
