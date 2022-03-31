//
//  ConnectionManager.swift
//  Smartpad-iOS
//
//  Created by Alireza Azimi on 2022-03-08.
//

import Foundation
import MultipeerConnectivity

class ConnectionManager:NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate{

    
    var peerID: MCPeerID!
    var p2pSession: MCSession?
    var p2pBrowser: MCNearbyServiceBrowser!
    var previousCoordinates: CGPoint = CGPoint.init()
    var advertiser: MCNearbyServiceAdvertiser?
    var peerName: String = ""
    var mainVC: MainViewController!

    
    override init(){
        super.init()
        
        startP2PSession()
    }
    func sendMotion(gesture: GesturePacket) {
        guard let p2pSession = p2pSession else {return}
        guard !p2pSession.connectedPeers.isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            let encoder = JSONEncoder()
            guard let command = try? encoder.encode(gesture)
            else {
                print("[ConnectionManager] Failed to encode packet!")
                return
            }

//          UNCOMMENT TO SEE ENCODED PACKET AS STRING :-)
//            print(String(data: command, encoding: String.Encoding.utf8))
            guard let p2pSession = self.p2pSession else {return}
            try? p2pSession.send(command, toPeers: p2pSession.connectedPeers, with: MCSessionSendDataMode.unreliable)
        }
    }
    
    /**
            This method starts broadcasting for peers
     */
    func startP2PSession(){
        let connData = ConnectionData()
        peerID = MCPeerID.init(displayName: connData.getDeviceName())
        p2pSession = MCSession.init(peer: peerID!, securityIdentity: nil, encryptionPreference: .required)
        p2pSession?.delegate = self

    }
    
    
    func startHosting(){
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "smartpad")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopHosting(){
        advertiser?.stopAdvertisingPeer()
    }
    
    func unpairDevice(){
        guard let p2pSession = p2pSession else {
            return
        }
        
        let connData = ConnectionData()
        connData.setSelectedPeer(name: "")
        p2pSession.disconnect()
        advertiser?.stopAdvertisingPeer()
  
    }
    
    func stopP2PSession(){
        guard let p2pSession = p2pSession else {
            return
        }
        
        p2pSession.disconnect()
    }

}

extension ConnectionManager{
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                print("Connected: \(peerID.displayName)")
                let connData = ConnectionData()
                connData.setSelectedPeer(name: peerID.displayName)
                mainVC.connStatus = ConnStatus.PairedAndConnected
                self.advertiser?.stopAdvertisingPeer()
                self.mainVC.updateConnInfoUI()
                
            case .connecting:
                break

            case .notConnected:
//                print("notConnected: \(peerID.displayName)")
                /* We are still paired, just lost connection. Update the UI to indicate that we are attempting to reconnect */
                let connData = ConnectionData()
                if(connData.getSelectedPeer() != ""){
                    if(p2pSession?.connectedPeers.count == 0){
                        // Ensure no peers are connected
                        mainVC.connStatus = ConnStatus.PairedAndDisconnected
                        advertiser?.startAdvertisingPeer()
                        self.mainVC.updateConnInfoUI()
                    }
                } else {
                    mainVC.connStatus = ConnStatus.Unpaired
                    advertiser?.stopAdvertisingPeer()
                    self.mainVC.updateConnInfoUI()
                }


        @unknown default:
            print("unknown state")
            
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // creates dialog box to accept or reject the connection request
        let connData = ConnectionData()
        if(connData.getSelectedPeer() != ""){
            if(connData.getSelectedPeer() == peerID.displayName){
                // accept invite and return
                invitationHandler(true, self.p2pSession)
                
                return
            }
        }
        let ac = UIAlertController(title: "Smartpad", message: "'\(peerID.displayName)' wants to connect", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
            invitationHandler(true, self?.p2pSession)
        }))
        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
            invitationHandler(false, nil)
        }))
        mainVC.present(ac, animated: true)
    }
}
