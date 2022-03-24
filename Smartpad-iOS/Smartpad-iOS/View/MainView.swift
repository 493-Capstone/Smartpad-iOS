//
//  MainView.swift
//  Smartpad-iOS
//
//  Created by Hudson Shykowski on 2022-03-11.
//

import UIKit

class MainView: UIView {
    var status: ConnStatus = ConnStatus.Unpaired
    
    override func draw(_ rect: CGRect) {
        drawConnStatus()
    }

    /**
     * @brief: Draws the connection indicator in the center of the screen
     */
    func drawConnStatus() {
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: CGRect(x: self.bounds.midX - 100, y: self.bounds.midY - 100, width: 200, height: 200))
        switch status {
            case ConnStatus.Unpaired, ConnStatus.UnpairedAndBroadcasting:
                UIColor.red.setStroke()
                UIColor.red.setFill()

            case ConnStatus.PairedAndDisconnected:
                UIColor.yellow.setStroke()
                UIColor.yellow.setFill()

            case ConnStatus.PairedAndConnected:
                UIColor.green.setStroke()
                UIColor.green.setFill()
        }

        UIColor.black.setStroke()

        path.lineWidth = 5
        path.stroke()
        path.fill()
    }
}
