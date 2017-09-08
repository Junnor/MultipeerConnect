//
//  ColorServiceManager.swift
//  ColorColor
//
//  Created by ju on 2017/9/7.
//  Copyright © 2017年 ju. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ColorServiceManagerDelegate: class {
    
    func connectedDevicesChanged(managr: ColorServiceManager, connectedDevices: [String])
    func colorChanged(manager: ColorServiceManager, colorString: String)
}

class ColorServiceManager: NSObject {
    
    weak var delegate: ColorServiceManagerDelegate?
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    private let colorServiceType = "example-color"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let servieAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    override init() {
        self.servieAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: colorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: colorServiceType)
        super.init()
        
        self.servieAdvertiser.delegate = self
        self.servieAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.servieAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    
    func send(colorName: String) {
        print("send color: \(colorName), to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(colorName.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch let error {
                print("send color error: \(error)")
            }
        }
    }
    
}


extension ColorServiceManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer error: \(error)")
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer peerID: \(peerID)")
        
        invitationHandler(true, session)
    }
}

extension ColorServiceManager: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer peerID: \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers error: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer peerID: \(peerID)")
        print("invitePeer: \(peerID)")
        
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
}

extension ColorServiceManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer: \(peerID) didChange state: \(state)")
        
        delegate?.connectedDevicesChanged(managr: self, connectedDevices: session.connectedPeers.map {$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive data: \(data) ")
        
        let colorName = String(data: data, encoding: .utf8)!
        
        let color = colorName.components(separatedBy: "!")
        delegate?.colorChanged(manager: self, colorString: color.first!)
        
        //        delegate?.colorChanged(manager: self, colorString: colorName)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceive stream ")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
}

