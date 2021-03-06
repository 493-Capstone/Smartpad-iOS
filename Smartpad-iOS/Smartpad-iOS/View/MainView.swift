//
//  MainView.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

/**
 * Draws the connection status circle.
 *
 * Required for connection status functional requirement FR15
 *
 * Required for user interface requirement UIR-5 (device reconnect UI)
 */

import UIKit

class MainView: UIView {
    
    override func draw(_ rect: CGRect) {
        drawConnStatus()
    }

    /* Diameter in pixels when the vertical size is not compact */
    private let normalDiameter = CGFloat(200.0)

    /* Diameter in pixels when the vertical size is compact */
    private let compactDiameter = CGFloat(150.0)

    /* Line width in pixels*/
    private let lineWidth = CGFloat(5.0)

    /**
     * @brief: Draws the connection indicator in the center of the screen
     */
    func drawConnStatus() {
        var path = UIBezierPath()

        /* If the height is compact, draw a smaller connection status indicator*/
        let diameter = (UIScreen.main.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact)
                        ? (compactDiameter) : (normalDiameter)

        path = UIBezierPath(ovalIn: CGRect(x: self.bounds.midX - (diameter / 2),
                                           y: self.bounds.midY - (diameter / 2),
                                           width: diameter, height: diameter))

        switch ConnectionManagerAccess.connectionManager.getConnStatus() {
            case .Unpaired, .UnpairedAndBroadcasting:
                UIColor.red.setStroke()
                UIColor.red.setFill()

            case .PairedAndDisconnected:
                UIColor.yellow.setStroke()
                UIColor.yellow.setFill()

            case .PairedAndConnected:
                UIColor.green.setStroke()
                UIColor.green.setFill()
        }

        UIColor.black.setStroke()

        path.lineWidth = lineWidth
        path.stroke()
        path.fill()
    }
}
