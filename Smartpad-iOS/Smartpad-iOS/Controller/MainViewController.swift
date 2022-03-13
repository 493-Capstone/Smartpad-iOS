//
//  MainViewController.swift
//  test-ios-trackpad-concept
//
//  Created by alireza azimi on 2022-01-14.
//

import UIKit
import CoreHaptics
import MultipeerConnectivity

/* From https://www.raywenderlich.com/10608020-getting-started-with-core-haptics */

class MainViewController: UIViewController {
    var connectionManager: ConnectionManager?
    var hapticManager: HapticManager?
    var previousCoordinates: CGPoint = CGPoint.init()
    var connStatus: ConnStatus = ConnStatus.Unpaired

    @IBOutlet var settingsButton: UIButton!

    /* Connection status-dependent label */
    @IBOutlet var connInfoLabel: UILabel!
    /* "Pair now" button */
    @IBOutlet var pairButton: UIButton!
    /* Spinner shown when broadcasting or attempting to reconnect */
    @IBOutlet var connSpinner: UIActivityIndicatorView!

    // TODO: REMOVE WHEN WIRELESS CONNECTION IS ADDED
    @IBOutlet var pairedButton: UIButton!
    @IBOutlet var unpairedButton: UIButton!
    @IBOutlet var disconnectedButton: UIButton!
    @IBOutlet var broadcastButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        /* Setup the connection manager */
        connectionManager = ConnectionManager()
        
        /* Setup the haptic engine */
        hapticManager = HapticManager()

        updateConnInfoUI()
    }

    func getDeltaTranslation(sender: UIPanGestureRecognizer) -> CGPoint {
        let translation: CGPoint = sender.translation(in: sender.view)
        var deltaTranslation = translation
        
        if sender.state != UIGestureRecognizer.State.began {
            deltaTranslation = CGPoint(x: translation.x - previousCoordinates.x, y: translation.y - previousCoordinates.y)
        }
        previousCoordinates = translation
        return deltaTranslation
    }

    
    @IBAction func panMotionSimple(_ sender: UIPanGestureRecognizer) {
        let deltaTranslation = getDeltaTranslation(sender: sender)
        
        hapticManager?.playSlice();

        connectionManager?.sendMotion(gesture: "\(deltaTranslation.x) \(deltaTranslation.y)")    }
    
    @IBAction func settingsButtonPressed() {
        if (connStatus == ConnStatus.UnpairedAndBroadcasting) {
            /* The settings button is actually a cancel button in this case*/
            connStatus = ConnStatus.Unpaired
            updateConnInfoUI()
        }
        else {
            /* Show settings page */
            let vc = storyboard?.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
            vc.modalPresentationStyle = .fullScreen

            vc.connStatus = connStatus
            present(vc, animated: true)
        }
    }

    // TODO: Remove once wireless connection is added
    @IBAction func pairedButtonPressed() {
        connStatus = ConnStatus.PairedAndConnected
        updateConnInfoUI()
    }

    // TODO: Remove once wireless connection is added
    @IBAction func unpairedButtonPressed() {
        connStatus = ConnStatus.Unpaired
        updateConnInfoUI()
    }

    // TODO: Remove once wireless connection is added
    @IBAction func disconnectedButtonPressed() {
        connStatus = ConnStatus.PairedAndDisconnected
        updateConnInfoUI()
    }

    // TODO: Remove once wireless connection is added
    @IBAction func broadcastButtonPressed() {
        connStatus = ConnStatus.UnpairedAndBroadcasting
        updateConnInfoUI()
    }

    @IBAction func pairButtonPressed() {
        connStatus = ConnStatus.UnpairedAndBroadcasting
        updateConnInfoUI()
    }

    /**
     * @brief Show the pairing confirmation prompt
     */
    func showPairConfirmation() {
        // TODO: Replace XYZ with the other device's name
        let foundAlert = UIAlertController(title: "Device found",
                                           message: "XYZ is requesting to pair.",
                                           preferredStyle: .alert)

        /* Accept pairing */
        foundAlert.addAction(UIAlertAction(title:
                                            NSLocalizedString("Accept", comment: ""),
                                           style: .default,
                                           handler: { _ in
            self.connStatus = ConnStatus.PairedAndConnected
            self.updateConnInfoUI()
        }))

        /* Cancel pairing */
        foundAlert.addAction(UIAlertAction(title:
                                            NSLocalizedString("Cancel", comment: ""),
                                           style: .default,
                                           handler: { _ in
            self.connStatus = ConnStatus.Unpaired
            self.updateConnInfoUI()
        }))

        self.present(foundAlert, animated: true, completion: nil)
    }

    /**
     * @brief Updates all of the UI that is related to the current connection status
     */
    func updateConnInfoUI() {
        switch connStatus {
            case ConnStatus.Unpaired:
                settingsButton.setTitle("Settings", for: .normal)

                connInfoLabel.text = "Unpaired"
                connSpinner.isHidden = true
                connSpinner.stopAnimating()
                pairButton.isHidden = false

            case ConnStatus.UnpairedAndBroadcasting:
                /* Use the settings button as a cancel button in this state */
                settingsButton.setTitle("Cancel", for: .normal)

                connInfoLabel.text = "Broadcasting..."
                connSpinner.isHidden = false
                connSpinner.startAnimating()
                pairButton.isHidden = true

                // TODO: Temp timer for showing pair pop-up. Remove when wireless comms are added
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.showPairConfirmation()
                }

            case ConnStatus.PairedAndConnected:
                settingsButton.setTitle("Settings", for: .normal)

                connInfoLabel.text = "Swipe or tap to start"
                connSpinner.isHidden = true
                connSpinner.stopAnimating()
                pairButton.isHidden = true

            case ConnStatus.PairedAndDisconnected:
                settingsButton.setTitle("Settings", for: .normal)

                connInfoLabel.text = "MacOS device not found, attempting to reconnect..."
                connSpinner.isHidden = false
                connSpinner.startAnimating()
                pairButton.isHidden = true
        }

        /* Draw the connection status and the spinner */
        (self.view as! MainView).status = connStatus
        self.view.setNeedsDisplay()
    }
}

