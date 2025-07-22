import SwiftUI
import UIKit

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
        DispatchQueue.main.async {
            if self.activityIndicator.superview == nil {
                view.addSubview(self.activityIndicator)
                NSLayoutConstraint.activate([
                    self.activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    self.activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }
            self.activityIndicator.startAnimating()
        }
    }
    
    // UIKit: Hide loading indicator
    func hideLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    // UIKit: Show error alert
    func showError(_ error: Error, in viewController: UIViewController) {
        DispatchQueue.main.async {
            let message = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
            let alert = UIAlertController(
                title: "Ошибка",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }
    
    // UIKit: Perform async operation
    func perform<T>(
        in viewController: UIViewController,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        DispatchQueue.main.async {
            self.showLoading(in: viewController.view)
        }
        do {
            let result = try await operation()
            DispatchQueue.main.async {
                self.hideLoading()
            }
            return result
        } catch {
            DispatchQueue.main.async {
                self.hideLoading()
                self.showError(error, in: viewController)
            }
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
