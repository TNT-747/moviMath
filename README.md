# Flutter Clean Architecture App

A Flutter application built with Clean Architecture principles for scalability and maintainability.

## 🏗️ Architecture

This project follows **Clean Architecture** with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and shared resources
│   ├── constants/          # App-wide constants and API configuration
│   ├── di/                 # Dependency injection setup (GetIt)
│   ├── error/              # Error handling (Failures & Exceptions)
│   ├── theme/              # Theme configuration
│   └── usecases/           # Base UseCase class
├── data/                    # Data layer
│   ├── datasources/        # Remote (API) and Local data sources
│   ├── models/             # JSON serializable data models
│   └── repositories/       # Repository implementations
├── domain/                  # Business logic layer
│   ├── entities/           # Pure Dart business objects
│   ├── repositories/       # Abstract repository contracts
│   └── usecases/           # Business use cases
└── presentation/            # UI layer
    ├── bloc/               # BLoC state management
    ├── screens/            # Screen widgets
    └── widgets/            # Reusable UI components
```

## 📦 Packages

### State Management
- **flutter_bloc** (^8.1.3) - BLoC pattern for predictable state management
- **equatable** (^2.0.5) - Value equality for Dart objects

### Networking
- **dio** (^5.4.0) - Powerful HTTP client with interceptors and error handling

### Local Storage
- **hive** (^2.2.3) - Fast, lightweight NoSQL database
- **hive_flutter** (^1.1.0) - Hive integration for Flutter

### Dependency Injection
- **get_it** (^7.6.4) - Service locator pattern for dependency injection

### Navigation
- **go_router** (^13.0.0) - Declarative routing solution

### Utilities
- **dartz** (^0.10.1) - Functional programming (Either type for error handling)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK (included with Flutter)

### Installation

1. **Clone the repository** (or navigate to the project directory)

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration
Update the API base URL in `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

### Dependency Injection
Register your dependencies in `lib/core/di/injection_container.dart`:

```dart
// Data Sources
sl.registerLazySingleton<RemoteDataSource>(
  () => RemoteDataSourceImpl(dio: sl()),
);

// Repositories
sl.registerLazySingleton<UserRepository>(
  () => UserRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ),
);

// Use Cases
sl.registerLazySingleton(() => GetUser(sl()));

// BLoCs
sl.registerFactory(() => UserBloc(getUser: sl()));
```

## 📝 Development Workflow

### Creating a New Feature

1. **Define the Entity** (domain/entities/)
   ```dart
   class User {
     final String id;
     final String name;
     
     User({required this.id, required this.name});
   }
   ```

2. **Create the Repository Contract** (domain/repositories/)
   ```dart
   abstract class UserRepository {
     Future<Either<Failure, User>> getUser(String id);
   }
   ```

3. **Create the Use Case** (domain/usecases/)
   ```dart
   class GetUser extends UseCase<User, String> {
     final UserRepository repository;
     
     GetUser(this.repository);
     
     @override
     Future<Either<Failure, User>> call(String id) {
       return repository.getUser(id);
     }
   }
   ```

4. **Create the Model** (data/models/)
   ```dart
   class UserModel extends User {
     UserModel({required super.id, required super.name});
     
     factory UserModel.fromJson(Map<String, dynamic> json) {
       return UserModel(
         id: json['id'],
         name: json['name'],
       );
     }
   }
   ```

5. **Implement Data Sources** (data/datasources/)
   - Remote data source (API calls)
   - Local data source (Hive/cache)

6. **Implement Repository** (data/repositories/)

7. **Create BLoC** (presentation/bloc/)

8. **Build UI** (presentation/screens/ & widgets/)

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 Theming

The app supports both light and dark themes. Customize themes in `lib/core/theme/app_theme.dart`.

## 📄 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please follow the Clean Architecture principles when adding new features.
