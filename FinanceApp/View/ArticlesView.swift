
import SwiftUI

struct ArticlesView : View {
    
    @StateObject var vm = CategoryViewModel()
    
    var body : some View {
        NavigationStack {
            List {
                ZStack {
                    VStack {
                        ForEach(vm.categories, id:\.id){
                            category in
                            HStack {
                                Text(String(category.emoji))
                                Text(category.name)
                            }
                        }
                    }
                }
               
            }
            .navigationTitle("Мои статьи")
            .task {await vm.fetchCategories()}
        }
        
        
    }
    
    
}

#Preview {
    
    ArticlesView()
}

