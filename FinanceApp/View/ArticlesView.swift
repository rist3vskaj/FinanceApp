import SwiftUI

struct ArticlesView: View {
    @StateObject private var vm = CategoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Мои статьи")
                        .font(.largeTitle.bold())
                        .padding(.horizontal)
                        .padding(.top, 24)

                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search", text: $vm.searchText)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .padding(.top, 20)
                    Text("Cтатьи")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, -10)
                  
                    // Filtered list
                    VStack(spacing: 0) {
                       
                        
                        ForEach(vm.filteredCategories) { category in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color("MainColor").opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Text(String(category.emoji))
                                        .font(.title3)
                                }

                                Text(category.name)
                                    .font(.body)

                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)

                            if category.id != vm.filteredCategories.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(Color(.systemGroupedBackground))
            .task {
                await vm.fetchCategories()
            }
        }
    }
}



import SwiftUI
import SwiftData

struct ArticlesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: true)
                let container = try ModelContainer(
                    for: TransactionModel.self, BackupOperationModel.self,
                    configurations: config
                )
                let txService = TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc", container: container)
                return AnyView(
                    NavigationStack {
                        ArticlesView()
                            .environmentObject(txService)
                            .environmentObject(BankAccountsService())
                            .environmentObject(CategoriesService())
                            .environmentObject(NetworkUIUtil())
                            .modelContainer(container)
                    }
                )
            } catch {
                return AnyView(
                    Text("Failed to create preview: \(error.localizedDescription)")
                )
            }
        }
    }
}
