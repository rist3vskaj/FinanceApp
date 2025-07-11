import SwiftUI
struct DateTotalCard: View {
  @Binding var start: Date
  @Binding var end: Date
  let total: Decimal

  var body: some View {
    VStack(spacing: 0) {
      HStack { Text("Начало"); Spacer(); DatePicker("", selection: $start, displayedComponents: .date).labelsHidden() }
      Divider()
      HStack { Text("Конец"); Spacer(); DatePicker("", selection: $end, displayedComponents: .date).labelsHidden() }
      Divider()
      HStack { Text("Сумма"); Spacer(); Text(total.formatted(.currency(code: "RUB"))) }
    }
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    .padding(.horizontal)
  }
}
