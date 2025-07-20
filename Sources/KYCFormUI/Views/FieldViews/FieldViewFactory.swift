//
//  FieldViewFactory.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import SwiftUI
import KYCFormCore
import KYCFormPresentation

/// A factory view that dynamically creates and returns the appropriate field view
/// based on the `FieldType` of the provided view model.
///
/// This is the core component that enables dynamic form rendering. The main `FormView`
/// will loop through its view models and pass each one to this factory.
struct FieldViewFactory: View {
    
    // The view model for the field we need to render.
    @ObservedObject var viewModel: FieldViewModel
    
    @ViewBuilder
    var body: some View {
        switch viewModel.type {
        case .date:
            DateFieldView(viewModel: viewModel)
            
        case .text, .email, .phone, .number:
            // All of these can be handled by our versatile TextFieldView
            TextFieldView(viewModel: viewModel)
            
        // If we were to add a new FieldType, like .picker,
        // we would add a new case here to return a PickerView.
        }
    }
}
