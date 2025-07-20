//
//  DateFieldView.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import SwiftUI
import KYCFormCore
import KYCFormPresentation

struct DateFieldView: View {
    @ObservedObject var viewModel: FieldViewModel
    
    @State private var selectedDate: Date = .now
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.isReadOnly {
                // For read-only, we just display the pre-filled string value.
                TextFieldView(viewModel: viewModel)
            } else {
                // For editable fields, we show the DatePicker.
                DatePicker(
                    selection: $selectedDate,
                    displayedComponents: .date
                ) {
                    Text(viewModel.label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .onChange(of: selectedDate) {
                    // When the user picks a new date, update the ViewModel's string value.
                    viewModel.value = formatDate(selectedDate)
                }
                .onAppear {
                    // When the view first appears, set the date picker's initial
                    // date from the viewmodel's value.
                    self.selectedDate = parseDate(from: viewModel.value) ?? .now
                }
                
                // Display validation errors if any
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Private Helpers
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    private func parseDate(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }
}

// MARK: - Preview
#Preview {
    let dateDefinition = FieldDefinition(id: "birth_date", label: "Birth Date", type: .date)
    let dateViewModel = FieldViewModel(definition: dateDefinition)
    
    let readOnlyDateDefinition = FieldDefinition(id: "issue_date", label: "Issue Date", type: .date, isReadOnly: true)
    let readOnlyDateViewModel = FieldViewModel(definition: readOnlyDateDefinition, prefilledValue: Date())
    
    return Form {
        DateFieldView(viewModel: dateViewModel)
        DateFieldView(viewModel: readOnlyDateViewModel)
    }
    .padding()
}
