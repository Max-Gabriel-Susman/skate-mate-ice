//
//  Skate_Mate_IceApp.swift
//  Skate Mate Ice
//
//  Created by Max Gabriel Susman on 8/3/24.
//

import SwiftUI
import Foundation
import CoreBluetooth

@main
struct Skate_Mate_IceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var peripherals = [CBPeripheral]()
    @Published var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("Started scanning for peripherals")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Unknown state")
        case .resetting:
            print("Resetting")
        case .unsupported:
            print("Unsupported")
        case .unauthorized:
            print("Unauthorized")
        case .poweredOff:
            print("Powered off")
        case .poweredOn:
            print("Powered on")
            startScanning()
        @unknown default:
            print("Unknown state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Discovered characteristic: \(characteristic.uuid)")
                // Read or write to the characteristic here
            }
        }
    }
}

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
