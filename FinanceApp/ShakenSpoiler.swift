import SwiftUI
import UIKit

// MARK: — 1) ShakeDetector
struct ShakeDetector: UIViewControllerRepresentable {
  var onShake: () -> Void

  func makeUIViewController(context: Context) -> UIViewController {
    let vc = DetectorViewController()
    vc.onShake = onShake
    return vc
  }
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

  private class DetectorViewController: UIViewController {
    var onShake: (() -> Void)?
    override func viewDidLoad() {
      super.viewDidLoad()
      becomeFirstResponder()
    }
    override var canBecomeFirstResponder: Bool { true }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
      super.motionEnded(motion, with: event)
      if motion == .motionShake {
        onShake?()
      }
    }
  }
}

// MARK: — 2) Spoiler
struct Spoiler<Content: View>: View {
  @Binding var isHidden: Bool
  let content: () -> Content

  var body: some View {
    ZStack {
      content()
      if isHidden {
          Color("MainColor")
          .opacity(0.8)
          .transition(.opacity)
          .animation(.easeInOut(duration: 0.25), value: isHidden)
          .cornerRadius(12)
          .frame(width: 362)
      }
    }
    .clipped()
  }
}
