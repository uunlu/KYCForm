//
//  FormComposer.swift
//  KYCForm
//
//  Created by Ugur Unlu on 20/07/2025.
//

import Foundation
import SwiftUI
import KYCFormCore
import KYCFormInfrastructure
import KYCFormPresentation
import KYCFormUI

/// The main entry point for the KYCForm package.
///
/// This composer class acts as the Composition Root. It is responsible for creating and
/// connecting all the necessary components from the various modules to construct a fully
/// functional KYC form view.
public final class FormComposer {
    private init() {}
    
    /// Creates and returns a fully configured KYC form view managed by a flow coordinator.
    ///
    /// This is the public API for SwiftUI applications. It sets up the entire flow
    /// and returns both the coordinator (for programmatic control) and the view.
    ///
    /// - Parameter onComplete: A closure that is called when the form is successfully submitted.
    /// - Returns: A tuple containing the `KYCFormFlow` coordinator and the SwiftUI `View`.
    @MainActor
    public static func makeKycFormView(onComplete: @escaping (FormData) -> Void) -> (flow: KYCFormFlow, view: some View) {
        
        // 1. Create the flow coordinator, passing in the completion handler.
        let flow = KYCFormFlow(onComplete: onComplete)
        
        // 2. Create the UI View, passing it the ViewModel from the flow.
        let view = FormView(viewModel: flow.formViewModel)
        
        return (flow, view)
    }
}
