# KYC Form Swift Package

A production-ready, type-safe KYC form engine for iOS and macOS applications. Built with SwiftUI and designed for enterprise-scale financial applications requiring dynamic form generation and country-specific compliance.

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

## Architecture

The package follows Clean Architecture principles with clear separation of concerns:

```
KYCFormCore         → Domain models, protocols, and business rules
KYCFormInfrastructure → YAML parsing, HTTP clients, country behaviors
KYCFormPresentation → ViewModels and presentation logic
KYCFormUI           → SwiftUI views and field renderers
KYCFormComposition  → Dependency injection and composition root
```

**Key Design Principles:**
- **Protocol-Oriented**: Easy to mock, test, and extend
- **Type-Safe**: `CountryCode` enum prevents runtime errors
- **Immutable**: Configuration data is immutable after loading
- **Thread-Safe**: Proper concurrency handling throughout
- **Testable**: Clean boundaries enable comprehensive testing

## Features

### ✅ Dynamic Form Generation
Forms are generated from YAML configuration files per country:

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
  - id: birth_date
    label: Birth Date
    type: date
    required: true
```

### ✅ Country-Specific Behaviors
Netherlands automatically pre-fills data from API and marks fields read-only:

```swift
// Automatically handles NL special case
let (flow, formView) = FormComposer.makeKycFormView { formData in
    // formData contains validated user input
    submitToBackend(formData)
}
```

### ✅ Comprehensive Validation Engine
- **Required field validation** with localized messages
- **Regex pattern matching** for format validation
- **Length constraints** for text fields
- **Date validation** (no future dates, age requirements)
- **Value range validation** for numeric fields
- **Composable validation rules** for complex requirements

### ✅ Production-Ready Features
- **Internationalization** support with `Localizable.xcstrings`
- **Accessibility** compliance with VoiceOver support
- **Thread-safe** date formatting with thread-local storage
- **Error handling** with proper user feedback
- **Loading states** for async operations

## Usage Examples

### Basic Implementation
```swift
struct BasicKYCView: View {
    @State private var isCompleted = false
    
    var body: some View {
        if isCompleted {
            SuccessView()
        } else {
            let (_, formView) = FormComposer.makeKycFormView { formData in
                handleKYCCompletion(formData)
                isCompleted = true
            }
            formView
        }
    }
}
```

### Navigation Integration
```swift
struct KYCFlowCoordinator: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            StartView()
                .navigationDestination(for: String.self) { route in
                    if route == "kyc" {
                        createKYCForm()
                    }
                }
        }
    }
    
    private func createKYCForm() -> some View {
        let (flow, formView) = FormComposer.makeKycFormView { formData in
            Task {
                await submitKYCData(formData)
                path.removeLast()
            }
        }
        return formView
    }
}
```

### Advanced Flow Control
```swift
struct AdvancedKYCView: View {
    @State private var submissionState: SubmissionState = .idle
    
    var body: some View {
        let (flow, formView) = FormComposer.makeKycFormView { formData in
            Task {
                submissionState = .submitting
                do {
                    try await submitToBackend(formData)
                    submissionState = .success
                } catch {
                    submissionState = .error(error)
                }
            }
        }
        
        return formView
            .onReceive(flow.formViewModel.$isLoading) { isLoading in
                // React to loading state changes
            }
            .overlay(alignment: .center) {
                if case .submitting = submissionState {
                    ProgressView("Submitting...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }
            }
    }
}
```

## Supported Countries

| Country | Code | Special Behavior |
|---------|------|------------------|
| Netherlands | NL | API pre-fill + read-only fields |
| Germany | DE | Standard validation |
| United States | US | Standard validation |

## Adding New Countries

### 1. Create YAML Configuration
```yaml
# Sources/KYCFormInfrastructure/Resources/fr.yaml
country: FR
fields:
  - id: first_name
    label: Prénom
    type: text
    required: true
  - id: nir
    label: NIR (Social Security Number)
    type: text
    required: true
    validation:
      - type: regex
        value: '^\d{15}$'
        message: 'NIR must be 15 digits'
```

### 2. Add to CountryCode Enum
```swift
public enum CountryCode: String, CaseIterable {
    case netherlands = "NL"
    case germany = "DE"
    case unitedStates = "US"
    case france = "FR" // Add new country
    
    public var displayName: String {
        switch self {
        case .netherlands: return "Netherlands"
        case .germany: return "Germany"
        case .unitedStates: return "United States"
        case .france: return "France" // Add display name
        }
    }
    
    public var flagEmoji: String {
        switch self {
        case .netherlands: return "🇳🇱"
        case .germany: return "🇩🇪"
        case .unitedStates: return "🇺🇸"
        case .france: return "🇫🇷" // Add flag emoji
        }
    }
}
```

### 3. Add Country-Specific Behavior (Optional)
```swift
struct FranceBehavior: CountryBehavior {
    func prefilledDataLoader() -> PrefilledDataLoader? {
        // Return nil for no pre-filling, or implement custom loader
        return nil
    }
    
    func apply(to definitions: [FieldDefinition], with prefilledData: [String: Any]?) -> [FieldDefinition] {
        // Apply France-specific field modifications
        return definitions
    }
}

// Register in CountryBehaviorRegistry
public convenience init() {
    let specificBehaviors: [CountryCode: CountryBehavior] = [
        .netherlands: NetherlandsBehavior(),
        .france: FranceBehavior() // Add here
    ]
    // ...
}
```

## Validation Rules

The package provides a comprehensive validation system:

```swift
// Built-in validation rules
RequiredValidationRule(message: "This field is required")
RegexValidationRule(pattern: "^\\d{9}$", message: "Must be 9 digits")
LengthValidationRule(min: 2, max: 50, message: "Must be 2-50 characters")
ValueRangeValidationRule<Int>(min: 18, max: 99, message: "Age must be 18-99")
MaximumDateValidationRule(date: Date(), message: "Cannot be future date")
MinimumDateValidationRule(date: oldestDate, message: "Invalid birth date")
```

### Custom Validation Rules
```swift
struct EmailValidationRule: ValidationRule {
    func validate(_ value: Any?) -> ValidationError? {
        guard let email = value as? String else { return nil }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email) ? nil :
               ValidationError(message: "Invalid email format")
    }
}
```

## Testing

Comprehensive test suite with high coverage:

```bash
swift test --enable-code-coverage
```

**Test Categories:**
- ✅ Core domain logic and validation rules
- ✅ YAML configuration parsing and error handling
- ✅ Country-specific behaviors and data loading
- ✅ Form submission and data transformation
- ✅ UI component rendering and interaction
- ✅ Thread safety and concurrency
- ✅ Localization and accessibility

## Performance Considerations

### Thread-Safe Date Formatting
Uses thread-local storage to prevent `DateFormatter` race conditions:

```swift
public static var displayDateFormatter: DateFormatter {
    threadLocalFormatter(key: displayKey) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
```

### Memory Management
- **Immutable configurations** reduce memory overhead
- **Lazy loading** of country configurations
- **Automatic cleanup** of form state on completion

### Async Operations
- **Structured concurrency** with proper task management
- **Cancellation support** for form loading operations
- **Main actor isolation** for UI updates

## Security Considerations

- **Input validation** prevents injection attacks
- **Type safety** eliminates many runtime vulnerabilities
- **Immutable data structures** prevent accidental mutations
- **Protocol boundaries** limit access to sensitive operations

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- SwiftUI framework

## Dependencies

- [Yams](https://github.com/jpsim/Yams) - YAML parsing and configuration loading

## Migration Guide

### From Legacy Form Systems
1. **Extract field definitions** into YAML configuration files
2. **Map validation logic** to `ValidationRule` implementations
3. **Implement country behaviors** for special cases
4. **Update UI bindings** to use `FieldViewModel` properties

### Version Compatibility
- **Backwards compatible** configuration format
- **Incremental migration** support for existing forms
- **Deprecation warnings** for legacy APIs

## License

MIT License - See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add comprehensive tests
4. Submit a pull request

---

**Architecture Philosophy**: "Make the right thing easy and the wrong thing impossible." This package prioritizes type safety, testability, and clear separation of concerns to enable confident development at enterprise scale.
