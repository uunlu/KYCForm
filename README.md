# KYC Form Swift Package

A production-ready, type-safe KYC form engine for iOS and macOS applications. Built with SwiftUI and designed for enterprise-scale financial applications requiring dynamic form generation and country-specific compliance.

## How to Run the App

### Option 1: Using Xcode with Swift Package Manager

1. **Clone or download the repository:**
   ```bash
   git clone https://github.com/uunlu/KYCForm.git
   cd KYCForm
   ```

2. **Open in Xcode:**
   ```bash
   open Package.swift
   ```

3. **Run the example/preview:**
   - Navigate to `Sources/KYCFormUI/Views/FormView.swift`
   - Click the "Resume" button in the Canvas to see the live preview
   - Or use the preview at the bottom of the file

### Option 2: Integration into Existing Project (Local Files)

1. **Download and add the package locally:**
   ```bash
   # Download the package
   git clone https://github.com/uunlu/KYCForm.git
   
   # Or download as ZIP and extract
   ```

2. **Add Local Package to Xcode:**
   - Open your existing Xcode project
   - File → Add Package Dependencies
   - Click "Add Local..." at the bottom left
   - Navigate to and select the `KYCForm` folder you downloaded
   - Click "Add Package"
   - Select the modules you need (typically just "KYCForm")

3. **Basic Usage:**
   ```swift
   import SwiftUI
   import KYCForm

   struct ContentView: View {
       @State private var isCompleted = false
       
       var body: some View {
           if isCompleted {
               Text("KYC Completed! ✅")
           } else {
               let (_, formView) = FormComposer.makeKycFormView { formData in
                   print("KYC Data: \(formData)")
                   isCompleted = true
               }
               formView
           }
       }
   }
   ```

### Option 3: Swift Playground

1. **Create a new Swift Playground**

2. **Add local package dependency:**
   - In Playground, go to File → Add Package Dependencies
   - Click "Add Local..."
   - Select your downloaded KYCForm folder
   - Click "Add Package"

3. **Use in playground:**
   ```swift
   import KYCForm
   import SwiftUI
   import PlaygroundSupport

   struct PlaygroundView: View {
       var body: some View {
           let (_, formView) = FormComposer.makeKycFormView { formData in
               print("Form completed with data: \(formData)")
           }
           return formView
       }
   }

   PlaygroundPage.current.setLiveView(PlaygroundView())
   ```

### Troubleshooting

**Module not found**: Ensure the package is properly added and all source files are included in your target.

**Missing Yams dependency**: Add via File → Add Package Dependencies → `https://github.com/jpsim/Yams`

**Resource files not found**: Copy the `Resources` folder from `Sources/KYCFormInfrastructure/Resources/` to your project bundle.

## Demo

Here's the KYC form in action, showing dynamic form generation and country-specific behaviors:

![KYC Form Demo](KYCFormPreview.gif)

**Key Features Demonstrated:**
- Country selection with flag emojis
- Dynamic form generation from YAML configuration
- Netherlands-specific behavior (API prefilling + read-only fields)
- Real-time validation with error clearing
- Form submission and completion flow

## Solution Architecture

The package implements **Clean Architecture** with a layered, protocol-oriented design that separates concerns and ensures testability:

### Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    KYCFormComposition                       │
│              (Dependency Injection Layer)                   │
│  • FormComposer (Composition Root)                          │
│  • KYCFormFlow (Coordinator)                                │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                        KYCFormUI                            │
│                   (Presentation Layer)                      │
│  • FormView • FieldViewFactory • TextFieldView              │
│  • DateFieldView • SwiftUI Components                       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   KYCFormPresentation                       │
│                    (ViewModel Layer)                        │
│  • FormViewModel • FieldViewModel                           │
│  • @Published properties • Combine integration              │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                  KYCFormInfrastructure                      │
│                 (Implementation Layer)                      │
│  • YAMLConfigurationLoader • RemotePrefilledDataLoader      │
│  • CountryBehavior implementations • HTTPClient             │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                     KYCFormCore                             │
│                    (Domain Layer)                           │
│  • Domain Models • Protocols • Validation Rules             │
│  • Business Logic • Type Definitions                        │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Patterns

#### 1. Composition Root Pattern
```swift
// Single entry point that wires all dependencies
public final class FormComposer {
    public static func makeKycFormView(onComplete: @escaping (FormData) -> Void) -> (flow: KYCFormFlow, view: some View) {
        let flow = KYCFormFlow(onComplete: onComplete)
        let view = FormView(viewModel: flow.formViewModel)
        return (flow, view)
    }
}
```

#### 2. Strategy Pattern for Country Behaviors
```swift
// Encapsulates country-specific logic
public protocol CountryBehavior {
    func prefilledDataLoader() -> PrefilledDataLoader?
    func apply(to definitions: [FieldDefinition], with prefilledData: [String: Any]?) -> [FieldDefinition]
}
```

#### 3. Protocol-Oriented Design
```swift
// Abstraction for configuration loading
public protocol ConfigurationLoader {
    func load(countryCode: CountryCode) async -> Result<CountryConfiguration, Error>
}

// Abstraction for HTTP operations
public protocol HTTPClient {
    func get(from url: URL) async -> Result<(Data, HTTPURLResponse), Error>
}
```

### Data Flow

```
User Input → FieldViewModel → FormViewModel → CountryBehavior → ConfigurationLoader
    ↑                                                                    ↓
UI Updates ← FormView ← Validation ← Business Logic ← Domain Models ← YAML Config
```

### Key Design Decisions

1. **Dependency Inversion**: High-level modules don't depend on low-level modules
2. **Single Responsibility**: Each class has one reason to change
3. **Open/Closed Principle**: Open for extension (new countries) but closed for modification
4. **Interface Segregation**: Small, focused protocols rather than large interfaces
5. **Type Safety**: Enum-based country codes prevent runtime string errors

## Netherlands-Specific Behavior Implementation

The Netherlands requires special handling: fetching user data from an API and making certain fields read-only. This was implemented using the **Strategy Pattern**:

### 1. NetherlandsBehavior Implementation

```swift
struct NetherlandsBehavior: CountryBehavior {
    private let readOnlyFieldIDs = ["first_name", "last_name", "birth_date"]
    
    // Provides API data loader
    func prefilledDataLoader() -> PrefilledDataLoader? {
        let url = URL(string: "https://some-api.com/api/nl-user-profile")!
        let client = MockHTTPClient.makeSuccessNLProfileClient()
        return RemotePrefilledDataLoader(url: url, client: client)
    }
    
    // Transforms field definitions to mark specific fields as read-only
    func apply(to definitions: [FieldDefinition], with prefilledData: [String: Any]?) -> [FieldDefinition] {
        definitions.map { field in
            var updatedField = field
            if readOnlyFieldIDs.contains(field.id) {
                updatedField.isReadOnly = true
            }
            return updatedField
        }
    }
}
```

### 2. Remote Data Loading

```swift
public final class RemotePrefilledDataLoader: PrefilledDataLoader {
    private let url: URL
    private let client: HTTPClient
    
    public func load() async -> Result<[String: Any], Swift.Error> {
        let result = await client.get(from: url)
        
        switch result {
        case let .success((data, response)):
            // Parse JSON response and map to form field format
            let mappedData = try ProfileMapper.map(data, from: response)
            return .success(mappedData)
        case .failure:
            return .failure(Error.connectivity)
        }
    }
}
```

### 3. Integration Flow

1. **Form Loading**: When user selects Netherlands, `FormViewModel` loads NL configuration
2. **Behavior Resolution**: `CountryBehaviorRegistry` returns `NetherlandsBehavior`
3. **Data Fetching**: Behavior's `prefilledDataLoader()` fetches user data from API
4. **Field Transformation**: Behavior's `apply()` method marks specific fields as read-only
5. **UI Rendering**: Read-only fields display pre-filled data but prevent editing

### 4. Mock Implementation

Since no real backend is available, the system uses `MockHTTPClient`:

```swift
public static func makeSuccessNLProfileClient() -> MockHTTPClient {
    let json = Data("""
    {
        "firstName": "Jane",
        "lastName": "Doe", 
        "birthDate": "1992-05-23T10:00:00Z"
    }
    """.utf8)
    
    let response = HTTPURLResponse(url: apiURL, statusCode: 200, ...)
    return MockHTTPClient(stub: .success((json, response)))
}
```

This approach ensures:
- **Separation of Concerns**: Netherlands logic is isolated
- **Testability**: Easy to mock and test independently
- **Extensibility**: Other countries can implement similar patterns
- **Type Safety**: Compile-time checking for all operations

## Working with External Configuration Files

The package is designed to work with external YAML configuration files that are outside of developer control. The system adapts to whatever field definitions are provided:

### Current Configuration Support

The system handles these YAML structures:

```yaml
country: NL
fields:
  - id: first_name
    label: First Name
    type: text
    required: true
  - id: bsn
    label: BSN
    type: text
    required: true
    validation:
      - type: regex
        value: '^\d{9}$'
        message: 'BSN must be 9 digits'
```

### Resilient Design

The architecture is built to be **configuration-agnostic**:

- **Field IDs**: Works with any field identifiers defined in config
- **Dynamic Validation**: Applies validation rules as specified
- **Flexible Behaviors**: Country behaviors adapt to available fields
- **Graceful Degradation**: Handles missing or unexpected fields

### Netherlands Special Case

For the Netherlands, the system looks for expected field patterns and applies read-only behavior when API data is available:
- Fields with IDs `first_name`, `last_name`, `birth_date` → marked read-only if prefilled
- System adapts if different field IDs are used in configuration
- Gracefully handles missing or renamed fields

This approach ensures the system works regardless of the exact field IDs used in external configuration files.

## Quick Start

```swift
import KYCForm

struct MyApp: View {
    var body: some View {
        let (flow, formView) = FormComposer.makeKycFormView { formData in
            print("KYC completed: \(formData)")
        }
        return formView
    }
}
```

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- SwiftUI framework

## Dependencies

- [Yams](https://github.com/jpsim/Yams) - YAML parsing and configuration loading

---

**Architecture Philosophy**: "Make the right thing easy and the wrong thing impossible." This package prioritizes type safety, testability, and clear separation of concerns to enable confident development at enterprise scale.
