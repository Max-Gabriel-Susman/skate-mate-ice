import SwiftUI

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()
    
    var body: some View {
        NavigationView {
            List(bleManager.peripherals, id: \.identifier) { peripheral in
                VStack(alignment: .leading) {
                    Text(peripheral.name ?? "Unknown")
                        .font(.headline)
                    Text(peripheral.identifier.uuidString)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .onTapGesture {
                    bleManager.connect(to: peripheral)
                }
            }
            .navigationTitle("BLE Devices")
            .onAppear {
                bleManager.startScanning()
            }
        }
    }
}
