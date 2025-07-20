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
    
    /// A private initializer to prevent anyone from creating an instance of this class.
    /// Its methods should be accessed statically.
    private init() {}
    
    /// Creates and returns a fully configured KYC form view.
    ///
    /// This is the public API for the package. A host application will call this method
    /// to get the SwiftUI view for the KYC flow.
    ///
    /// - Parameter onComplete: A closure that is called when the form is successfully
    ///   submitted, providing the collected `FormData`.
    /// - Returns: An opaque SwiftUI `View` that can be displayed by the host application.
    @MainActor
    public static func makeKycFormView(onComplete: @escaping (FormData) -> Void) -> some View {
        
        // 1. Create the Infrastructure components
        let configurationLoader = YAMLConfigurationLoader.makeForPackageResources()
        let behaviorRegistry = CountryBehaviorRegistry()
        
        // 2. Create the Presentation component (ViewModel)
        let formViewModel = FormViewModel(
            configurationLoader: configurationLoader,
            behaviorRegistry: behaviorRegistry
        )
        
        // 3. Create the UI component (View)
        let formView = FormView(
            viewModel: formViewModel,
            onComplete: onComplete
        )
        
        return formView
    }
}
