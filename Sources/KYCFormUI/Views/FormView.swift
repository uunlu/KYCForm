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
    @StateObject private var viewModel: FormViewModel
    private let onComplete: (FormData) -> Void
    
    @State private var submissionResult: FormData?
    @State private var showingSubmissionSummary = false
    
    // The init goes back to being simple. No Task here.
    public init(viewModel: FormViewModel, onComplete: @escaping (FormData) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
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
                    Button(action: submitForm) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("KYC Form")
            .alert("Submission Successful", isPresented: $showingSubmissionSummary) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(submissionResult?.description ?? "No data.")
            }
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
    
    private func submitForm() {
        if let formData = viewModel.submit() {
            self.submissionResult = formData
            self.showingSubmissionSummary = true
            onComplete(formData)
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
    FormView(viewModel: viewModel) { formData in
        // The onComplete closure for the preview can just print the data.
        print("Preview form submitted with data: \(formData)")
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
    return FormView(viewModel: viewModel) { formData in
        // The onComplete closure for the preview can just print the data.
        print("Preview form submitted with data: \(formData)")
    }
}
