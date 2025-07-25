import SwiftUI
import SwiftData

struct HistoryView: View {
    let direction: Direction
    @StateObject private var vm: HistoryViewModel

    init(direction: Direction, txService: TransactionsService, bankAccService: BankAccountsService) {
        self.direction = direction
        _vm = StateObject(wrappedValue: HistoryViewModel(direction: direction, txService: txService, bankAccService: bankAccService))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        headerView
                        datePickerView
                        summaryView
                        transactionListView
                        Spacer(minLength: 80)
                    }
                    .padding(.top, 40)
                }
                
                addButton
                    .padding(24)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AnalysisViewControllerPreview(
                            direction: direction,
                            txService: vm.service,
                            bankAccService: vm.bankAccountsService
                        )
                        .edgesIgnoringSafeArea(.all)
                    } label: {
                        Image(systemName: "doc.text")
                            .imageScale(.large)
                            .foregroundColor(.purple)
                    }
                }
            }
            .accentColor(.purple)
            .navigationTitle("Моя история")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: vm.start) { newStart in
                if newStart > vm.end { vm.end = newStart }
                Task { await vm.load() }
            }
            .onChange(of: vm.end) { newEnd in
                if newEnd < vm.start { vm.start = newEnd }
                Task { await vm.load() }
            }
        }
        .accentColor(.purple)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Image("clock")
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var datePickerView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Начало")
                Spacer()
                DatePicker("", selection: $vm.start, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color("MainColor"))
                    .frame(width: 82, height: 23)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color("MainColor").opacity(0.25))
                    .cornerRadius(8)
            }
            .frame(height: 50)
            .padding(.horizontal)
            .padding(.trailing, -18)
            .padding(.leading, -14)
            
            Divider()
            
            HStack {
                Text("Конец")
                Spacer()
                DatePicker("", selection: $vm.end, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color("MainColor"))
                    .frame(width: 82, height: 23)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(Color("MainColor").opacity(0.25))
                    .cornerRadius(8)
            }
            .frame(height: 50)
            .padding(.horizontal)
            .padding(.trailing, -18)
            .padding(.leading, -14)
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var summaryView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                Text("Сортировка")
                Spacer()
                Picker("", selection: $vm.sortOption) {
                    ForEach(HistoryViewModel.SortOption.allCases) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
            
            Divider()
            
            HStack {
                Text("Сумма")
                Spacer()
                Text(vm.total.formatted(.currency(code: "RUB")))
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private var transactionListView: some View {
        VStack(spacing: 0) {
            Text("ОПЕРАЦИИ")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 4)
            
            LazyVStack(spacing: 0) {
                ForEach(vm.transactions) { txn in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color("MainColor").opacity(0.2))
                                .frame(width: 32, height: 32)
                            Text(String(txn.category.emoji))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(txn.category.name)
                            if let c = txn.comment {
                                Text(c)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        Text(txn.amount.formatted(.currency(code: "RUB")))
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    
                    if txn.id != vm.transactions.last?.id {
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
    }
    
    private var addButton: some View {
        Button {
            // add new…
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 66, height: 66)
                .background(Color("MainColor"))
                .clipShape(Circle())
        }
    }
}
