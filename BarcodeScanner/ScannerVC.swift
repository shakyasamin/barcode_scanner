//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by MicroBanker Nepal Pvt. Ltd. on 27/06/2025.
//

import AVFoundation
import UIKit

enum CameraError: String{
    case invalidDeviceInput  = "Something is worng with the camera. We are unable to access the camera"
    case invalidScannedValue = " The value scanned is not valid.This app scans EAN-8 and EAN-13"
}

protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
    func didSurface(error: CameraError)
}


final class ScannerVC: UIViewController {
    
    let captureSession = AVCaptureSession()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate?
    
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let previewLayer = previewLayer else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        previewLayer.frame = view.layer.bounds
    }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        }catch {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)

            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)

            return
        }
        
        let metaDateOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metaDateOutput) {
            captureSession.addOutput(metaDateOutput)
            
            metaDateOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metaDateOutput.metadataObjectTypes = [.ean8, .ean13]
        }else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)

            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
        
    }
}

extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        scannerDelegate?.didFind(barcode: barcode)
    }
    
}
