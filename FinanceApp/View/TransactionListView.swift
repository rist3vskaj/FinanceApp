import SwiftUI

struct TransactionListView: View {
    let direction: Direction
    @StateObject private var vm = TransactionViewModel()
 

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Full‐screen grey
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // MARK: — Title
                HStack {
                    Text(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                        .font(.largeTitle).bold()
                        .padding(.horizontal)
                        .padding(.bottom, 28)
                    Spacer()
                           
                           NavigationLink {
                               HistoryView(direction: direction)
                           } label: {
                               Image(systemName: "clock")
                                   .font(.system(size: 20, weight: .medium))
                                   .padding(8)
                                   .foregroundColor(.purple)
                                   .padding(.top, -50)
                                  
                           }                           .buttonStyle(.plain)
                       
                       
                       
                }  .padding(.horizontal)
                    
           

               

                // MARK: — Total card
                HStack {
                    Text("Всего")
                        .font(.headline)
                    Spacer()
                    Text(vm.totalAmount.formatted(.currency(code: "RUB")))
                        .font(.headline)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)

                // MARK: — Operations list
                VStack(spacing: 0) {
                  ForEach(vm.filteredTransactions) { txn in
                    HStack(spacing: 12) {
                      ZStack {
                        Circle()
                              .fill(Color("MainColor").opacity(0.3))
                          .frame(width: 30, height: 32)
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

                    // draw a divider *after* every row except the last
                    if txn.id != vm.filteredTransactions.last?.id {
                      Divider()
                        // indent so it doesn’t run under the circle
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                    }
                  }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
            } .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 40)
            .task {
                await vm.loadTransactions(for: direction)
            }

            // MARK: — Floating + button
            Button {
                // add action here
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 66, height: 66)
                    .background(Color("MainColor"))
                    .clipShape(Circle())
                    
            }
            .padding(24)
        }
    }
}


#Preview{
    NavigationStack {
        TransactionListView(direction: .outcome)
      }.tint(.purple)
      
}
