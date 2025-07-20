//
//  TextFieldView.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import SwiftUI
import KYCFormCore
import KYCFormPresentation

struct TextFieldView: View {
    
    @ObservedObject var viewModel: FieldViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Field Label
            Text(viewModel.label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // The main input field
            if viewModel.isReadOnly {
                // Read-only state: Display as simple text
                Text(viewModel.value)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(.systemGray))
                    .cornerRadius(8)
            } else {
                // Editable state: Display as a TextField
                let textField = TextField(viewModel.placeholder, text: $viewModel.value)
                
#if os(iOS)
                textField
                    .keyboardType(keyboardType(for: viewModel.type))
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                    )
#else
                // On macOS, keyboardType is not available, so we omit it.
                textField
                    .padding(10)
                    .background(Color(.systemGray))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(viewModel.errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
                    )
#endif
            }
            
            if !viewModel.helpText.isEmpty {
                Text(viewModel.helpText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Validation Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.vertical, 6)
    }
#if os(iOS)
    private func keyboardType(for fieldType: FieldType) -> UIKeyboardType {
        switch fieldType {
        case .number:
            return .decimalPad
        case .email:
            return .emailAddress
        case .phone:
            return .phonePad
        default:
            return .default
        }
    }
#endif
}

#Preview {
    // Create a sample FieldDefinition for an editable field
    let editableDefinition = FieldDefinition(
        id: "first_name",
        label: "First Name",
        type: .text,
        isRequired: true,
        helpText: "Enter your given name as it appears on your passport."
    )
    let editableViewModel = FieldViewModel(definition: editableDefinition)
    
    // Create a sample FieldDefinition for a read-only field
    let readOnlyDefinition = FieldDefinition(
        id: "last_name",
        label: "Last Name",
        type: .text,
        isReadOnly: true
    )
    let readOnlyViewModel = FieldViewModel(definition: readOnlyDefinition, prefilledValue: "Doe")
    
    // Create a sample FieldDefinition for a field with an error
    let errorDefinition = FieldDefinition(
        id: "email",
        label: "Email Address",
        type: .email
    )
    let errorViewModel = FieldViewModel(definition: errorDefinition)
    
    // Using a NavigationStack provides a more realistic preview environment
    return NavigationStack {
        Form {
            Section("Editable Field") {
                TextFieldView(viewModel: editableViewModel)
            }
            
            Section("Read-Only Field") {
                TextFieldView(viewModel: readOnlyViewModel)
            }
            
            Section("Error State") {
                TextFieldView(viewModel: errorViewModel)
            }
        }
        .navigationTitle("TextField Preview")
    }
}
