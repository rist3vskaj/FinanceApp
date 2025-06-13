//import SwiftUI
//
//struct CategoryListView: View {
//    @StateObject private var viewModel = CategoryViewModel()
//
//    var body: some View {
//        NavigationView {
//            Group {
//                if viewModel.isLoading {
//                    ProgressView("Loading categories...")
//                } else if let error = viewModel.errorMessage {
//                    Text(error)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                        .padding()
//                } else {
//                    List(viewModel.categories) { category in
//                        HStack {
//                            Text(String(category.icon))
//                                .font(.largeTitle)
//                            VStack(alignment: .leading) {
//                                Text(category.name)
//                                    .font(.headline)
//                                Text(category.direction.rawValue.capitalized)
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Categories")
//        }
//        .onAppear {
//            Task {
//                    await viewModel.fetchCategories()
//                }
//        }
//    }
//}
