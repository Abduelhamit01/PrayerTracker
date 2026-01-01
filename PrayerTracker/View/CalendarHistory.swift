import SwiftUI
import UIKit

struct CalendarHistory: View {
    @State private var date = Date()
    var body: some View {
        NavigationStack{
            VStack{
                DatePicker(
                    "Start Date",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.bottom, 90)
                
                VStack {
                    Text("Legende")
                    HStack{
                        Text("🟢 Alles erledigt")
                        Text("🔴 Verpasste Gebete")
                        Text("🔵 Heute")
                    }
                }
                .padding(.top, 40)
            }
            .navigationTitle("Prayer History")
        }
    }
}
    
    #Preview {
        CalendarHistory()
    }
