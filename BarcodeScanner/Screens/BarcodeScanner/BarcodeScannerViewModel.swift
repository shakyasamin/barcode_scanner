//
//  BarcodeScannerViewModel.swift
//  BarcodeScanner
//
//  Created by MicroBanker Nepal Pvt. Ltd. on 27/06/2025.
//

import SwiftUI

final class BarcodeScannerViewModel: ObservableObject {
    @Published  var scannedCode = ""
    @Published  var alertItem: AlertItem?
    
    var statusText: String {
        scannedCode.isEmpty ? "Not Yet Scanned" : scannedCode
    }
    
    var statusTextColor: Color {
        scannedCode.isEmpty ? .red : .green
    }
}
