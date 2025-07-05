//
//  ScannerQRViewController.swift
//  Gil
//
//  Created by Antonio Banda  on 26/06/25.
//

import UIKit
import AVFoundation

class ScannerQRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var eventRecived : EventDto?
    let serviceManager = ServiceManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermission()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        var qrCode : String=""

        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            qrCode = stringValue
        }
        
        
        if(isConnected){
            print(qrCode)
            checkGuest(guestId:qrCode){
                
            }
            
            /*if let qrCodeVal = Int(qrCode){
                checkGuest(guestId:qrCodeVal){
                    
                }
            }else{
                let alertLoading = Utils.ValidatingAlert.showAlert(on: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let checkImage = UIImage(systemName: "xmark.circle.fill")!
                    Utils.ValidatingAlert.replaceLoadingWithImageError(in: alertLoading, image: checkImage)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        alertLoading.dismiss(animated: true){
                            self.dismiss(animated: true)
                        }
                    }
                }
            }*/
        }else{
            Utils.Snackbar.snackbarWithAction(message: "no_internet_connection".localized(), bgColor: Constants.Colors.red!, titleAction:"close".localized() ,duration: 5.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.dismiss(animated: true){
                    self.dismiss(animated: true)
                }
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    @objc
    func checkGuest(guestId : String, completion: @escaping () -> Void) {
        let alertLoading = Utils.ValidatingAlert.showAlert(on: self)
        serviceManager.checkMyGuest(guestId: guestId, eventId: (eventRecived?.eventId)!) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let myCheck):
                        switch myCheck.guestsResponse {
                        case "0":
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                let checkImage = UIImage(systemName: "xmark.circle.fill")!
                                Utils.ValidatingAlert.replaceLoadingWithImageError(in: alertLoading, image: checkImage)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    alertLoading.dismiss(animated: true){
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                            print("valor 0")
                        case "1":
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                let checkImage = UIImage(systemName: "xmark.circle.fill")!
                                Utils.ValidatingAlert.replaceLoadingWithImageScanB(in: alertLoading, image: checkImage)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    alertLoading.dismiss(animated: true){
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                            print("valor 1")
                        case "2":
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                let checkImage = UIImage(systemName: "checkmark.circle.fill")!
                                Utils.ValidatingAlert.replaceLoadingWithImageOk(in: alertLoading, image: checkImage)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    alertLoading.dismiss(animated: true){
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                        default:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                let checkImage = UIImage(systemName: "xmark.circle.fill")!
                                Utils.ValidatingAlert.replaceLoadingWithImageError(in: alertLoading, image: checkImage)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    alertLoading.dismiss(animated: true){
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                        }
                    case .failure(let error):
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .notFound:
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.green!, duration: 5.0)
                        default:
                            Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        }
                    } else {
                        Utils.Snackbar.snackbarNoAction(message: "server_error".localized(), bgColor: Constants.Colors.red!, duration: 5.0)
                        // Si es otro tipo de error
                        print("Error al actualizar invitaciones desde el api : \(error)")
                    }
                    
                }
                completion()
            }
            
        }
       
    }
    
    func checkPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        case .notDetermined:
            // Aún no ha pedido permiso, lo pedimos
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.captureSession.startRunning()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showPermissionAlert()
            }

        @unknown default:
            DispatchQueue.main.async {
                self.showPermissionAlert()
            }
        }
    }

    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "camera_permission_title".localized(),
            message: "camera_permission_message".localized(),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "camera_permission_settings".localized(), style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        present(alert, animated: true)
    }
    
   
}
