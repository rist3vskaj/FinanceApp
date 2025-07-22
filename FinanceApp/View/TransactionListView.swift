import SwiftUI

struct TransactionListView: View {
    let direction: Direction

    @EnvironmentObject private var txService: TransactionsService
    @EnvironmentObject private var accountsService: BankAccountsService
    @EnvironmentObject private var networkUIUtil: NetworkUIUtil
    @EnvironmentObject private var categoriesService: CategoriesService

    @StateObject private var vm: TransactionViewModel
    @State private var editingTx: Transaction?
    @State private var showingCreate = false

    init(direction: Direction) {
        self.direction = direction
        _vm = StateObject(
            wrappedValue: TransactionViewModel(direction: direction,
                                               service: TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc"))
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        totalCard
                        transactionList
                    }
                    .padding(.top)
                }
                .navigationBarHidden(true)
                .fullScreenCover(item: $editingTx,
                                onDismiss: reload
                ) { tx in
                    TransactionFormView(mode: .edit(tx), direction: direction)
                      .environmentObject(txService)
                      .environmentObject(accountsService)
                      .environmentObject(networkUIUtil)
                      .environmentObject(categoriesService)
                }
                .fullScreenCover(isPresented: $showingCreate,
                                onDismiss: reload // Added onDismiss for create
                ) {
                  TransactionFormView(mode: .create, direction: direction)
                    .environmentObject(txService)
                    .environmentObject(accountsService)
                    .environmentObject(networkUIUtil)
                    .environmentObject(categoriesService)
                }
                .task {
                    vm.service = txService
                    await vm.loadTransactions()
                }
                .overlay(alignment: .bottomTrailing) {
                    addButton
                        .padding(24)
                }
            }
        }
    }

    // MARK: – Subviews

    private var header: some View {
        HStack {
            Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                .font(.largeTitle).bold()
            Spacer()
            NavigationLink(destination: historyView) {
                Image(systemName: "clock")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.purple)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemGray6))
        .frame(maxWidth: .infinity)
        .zIndex(1)
    }

    private var historyView: some View {
        HistoryView(direction: direction)
            .environmentObject(txService)
            .environmentObject(accountsService)
            .environmentObject(networkUIUtil)
            .environmentObject(categoriesService)
    }

    private var totalCard: some View {
        HStack {
            Text("Всего").font(.headline)
            Spacer()
            Text(vm.totalAmount.formatted(.currency(code: "RUB")))
                .font(.headline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var transactionList: some View {
        VStack(spacing: 0) {
            ForEach(vm.filteredTransactions) { tx in
                Button { editingTx = tx } label: {
                    transactionRow(tx)
                }
                .buttonStyle(.plain)

                if tx.id != vm.filteredTransactions.last?.id {
                    Divider()
                        .padding(.leading, 56)
                        .padding(.trailing, 16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func transactionRow(_ tx: Transaction) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("MainColor").opacity(0.3))
                    .frame(width: 30, height: 30)
                Text(String(tx.category.emoji))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.category.name)
                if let c = tx.comment {
                    Text(c)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(tx.amount.formatted(.currency(code: "RUB")))
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }

    private var addButton: some View {
        Button { showingCreate = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 66, height: 66)
                .background(Color("MainColor"))
                .clipShape(Circle())
        }
    }

    // MARK: – Forms

    private func editForm(for tx: Transaction) -> some View {
      TransactionFormView(
        mode: .edit(tx),
        direction: direction
      )
      .environmentObject(txService)
      .environmentObject(accountsService)
      .environmentObject(networkUIUtil)
      .environmentObject(categoriesService)
    }

    private var createForm: some View {
      TransactionFormView(
        mode: .create,
        direction: direction
      )
      .environmentObject(txService)
      .environmentObject(accountsService)
      .environmentObject(networkUIUtil)
      .environmentObject(categoriesService)
    }

    // MARK: – Helpers

    private func reload() {
        Task {
            await vm.loadTransactions()
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TransactionListView(direction: .outcome)
        .environmentObject(TransactionsService(token: "KG8ToQeYtryu7MJ24PIhmdtc"))
        .environmentObject(BankAccountsService())
        .environmentObject(NetworkUIUtil())
        .environmentObject(CategoriesService())
    }
  }
}
