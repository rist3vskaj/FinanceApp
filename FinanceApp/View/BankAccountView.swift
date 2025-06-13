//import SwiftUI
//
//struct BankAccountView: View {
//    @StateObject private var viewModel = BankAccountViewModel()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            if viewModel.isLoading {
//                ProgressView("Loading account…")
//            } else if let error = viewModel.errorMessage {
//                Text("Error: \(error)")
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//            } else if let account = viewModel.account {
//                Text("💳 \(account.name)")
//                    .font(.title2)
//                Text("Balance: \(account.balance.formatted(.currency(code: "USD")))")
//                    .font(.title)
//                    .bold()
//            } else {
//                Text("No account data")
//            }
//        }
//        .padding()
//        .onAppear {
//            Task {
//                await viewModel.loadAccount()
//            }
//        }
//    }
//}
