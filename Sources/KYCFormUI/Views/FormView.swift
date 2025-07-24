//
//  FormView.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import SwiftUI
import KYCFormCore
import KYCFormPresentation
import KYCFormInfrastructure

public struct FormView: View {
    @ObservedObject private var viewModel: FormViewModel
    
    public init(viewModel: FormViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Select Country")) {
                    Picker("Country", selection: $viewModel.selectedCountryCode) {
                        ForEach(viewModel.availableCountryCodes, id: \.self) { code in
                            Text(countryName(for: code)).tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // This is where the main content lives.
                formContent
                
                Section {
                    Button(action: { viewModel.submit() }) { // Simplified action
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("KYC Form")
        }
    }
    
    // We extract the form content into a computed property.
    private var formContent: some View {
        // We use a Group to apply modifiers to the content inside.
        Group {
            if viewModel.isLoading {
                Section { // Wrap ProgressView in a Section for better layout
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } else {
                Section(header: Text("Your Information")) {
                    ForEach(viewModel.fieldViewModels) { fieldViewModel in
                        FieldViewFactory(viewModel: fieldViewModel)
                    }
                }
            }
        }
        .id(viewModel.selectedCountryCode)
    }
    
    // MARK: - Private Methods
    
    private func loadForm() {
        Task {
            await viewModel.loadForm(for: viewModel.selectedCountryCode)
        }
    }
    
    private func countryName(for code: String) -> String {
        switch code {
        case "NL": return "Netherlands"
        case "DE": return "Germany"
        case "US": return "United States"
        default: return code
        }
    }
}


// MARK: - Preview Provider

#Preview {
    // 1. Create the dependencies needed by the FormViewModel.
    let loader = YAMLConfigurationLoader.makeForPackageResources()
    let registry = CountryBehaviorRegistry()
    
    // 2. Create the FormViewModel with the real dependencies.
    let viewModel = FormViewModel(
        configurationLoader: loader,
        behaviorRegistry: registry
    )
    
    // 3. Return the FormView.
    FormView(viewModel: viewModel)
}

// MARK: - Preview Provider

#Preview {
    // 1. Create the dependencies needed by the FormViewModel.
    let loader = YAMLConfigurationLoader.makeForPackageResources()
    let registry = CountryBehaviorRegistry()
    
    // 2. Create the FormViewModel with the real dependencies.
    let viewModel = FormViewModel(
        configurationLoader: loader,
        behaviorRegistry: registry
    )
    
    // 3. Return the FormView.
    FormView(viewModel: viewModel)
}
