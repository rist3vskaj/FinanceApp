//import SwiftUI
//
//struct TransactionListView: View {
//    @StateObject private var viewModel = TransactionViewModel()
//    
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter
//    }()
//
//    var body: some View {
//        NavigationView {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading transactions...")
//                } else if let error = viewModel.errorMessage {
//                    Text("Error: \(error)")
//                        .foregroundColor(.red)
//                        .padding()
//                } else {
//                    List(viewModel.transactions) { tx in
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text("Amount: \(tx.amount.formatted(.currency(code: "USD")))")
//                                .font(.headline)
//                            Text("Date: \(dateFormatter.string(from: tx.date))")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                            if let desc = tx.description {
//                                Text(desc)
//                                    .font(.body)
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//            }
//            .navigationTitle("Transactions")
//        }
//        .onAppear {
//            Task {
//                await viewModel.loadTransactions()
//            }
//        }
//    }
//}
