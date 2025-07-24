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
    
    // MARK: Strings
    private let selectCountryText = L10n.string(for: "form.section.header.country_selector")
    private let pickerTitleText = L10n.string(for: "form.picker.label.country")
    private let submitText = L10n.string(for: "form.button.submit")
    private let navigationTitleText = L10n.string(for: "form.title")
    private let formSectionHeaderText = L10n.string(for: "form.section.header.user_information")
    
    
    public init(viewModel: FormViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(selectCountryText)) {
                    Picker(pickerTitleText, selection: $viewModel.selectedCountryCode) {
                        ForEach(viewModel.availableCountryCodes, id: \.self) { code in
                            HStack {
                                Text("\(code.flagEmoji) \(code.displayName)")
                            }
                            .tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                formContent
                
                Section {
                    Button(action: { viewModel.submit() }) {
                        Text(submitText)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle(navigationTitleText)
        }
    }
    
    private var formContent: some View {
        Group {
            if viewModel.isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } else {
                Section(header: Text(formSectionHeaderText)) {
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
}


// MARK: - Preview Provider

#Preview {
    let loader = YAMLConfigurationLoader.makeForPackageResources()
    let registry = CountryBehaviorRegistry()
    
    let viewModel = FormViewModel(
        configurationLoader: loader,
        behaviorRegistry: registry
    )
    
    FormView(viewModel: viewModel)
}

// MARK: - Preview Provider

#Preview {
    let loader = YAMLConfigurationLoader.makeForPackageResources()
    let registry = CountryBehaviorRegistry()
    
    let viewModel = FormViewModel(
        configurationLoader: loader,
        behaviorRegistry: registry
    )
    
    FormView(viewModel: viewModel)
}
