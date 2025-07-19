import SwiftUI

class NetworkUIUtil: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // UIKit version for AnalysisViewController
    private let activityIndicator: UIActivityIndicatorView
    
    init() {
        self.activityIndicator = UIActivityIndicatorView(style: .large)
        self.activityIndicator.color = .gray
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // UIKit: Show loading indicator
    func showLoading(in view: UIView) {
        if activityIndicator.superview == nil {
            view.addSubview(activityIndicator)
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        activityIndicator.startAnimating()
    }
    
    // UIKit: Hide loading indicator
    func hideLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // UIKit: Show error alert
    func showError(_ error: Error, in viewController: UIViewController) {
        let message = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
    
    // UIKit: Perform async operation
    func perform<T>(
        in viewController: UIViewController,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        showLoading(in: viewController.view)
        do {
            let result = try await operation()
            hideLoading()
            return result
        } catch {
            hideLoading()
            showError(error, in: viewController)
            throw error
        }
    }
    
    // SwiftUI: Perform async operation
    func perform<T>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        await MainActor.run { isLoading = true }
        do {
            let result = try await operation()
            await MainActor.run { isLoading = false }
            return result
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            }
            throw error
        }
    }
}
