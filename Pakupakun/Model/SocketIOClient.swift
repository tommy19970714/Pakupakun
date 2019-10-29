//
//  SocketIOClient.swift
//  DetectFaceLandmarks
//
//  Created by tommy19970714 on 2019/10/26.
//  Copyright © 2019 mathieu. All rights reserved.
//

import Foundation
import SocketIO


extension Notification.Name {
    static let receiveSocket = Notification.Name("recieveSocket")
}

class SocketIOClient {
    static let shared = SocketIOClient()
    
    let manager = SocketManager(socketURL: URL(string: "http://35.192.202.74")!, config: [.log(false), .compress])
    var socket: SocketIO.SocketIOClient?
    
    init() {
        socket = manager.defaultSocket
    }
    
    func connect() {
        release()
        
        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket?.on(clientEvent: .disconnect) {data, ack in
            print("socket disconnected")
        }
        
        socket?.on("requestPrediction") { [weak self] (data, ack) in
            print(data)
            guard let json = (data[0] as? String)?.data(using: .utf8) else { return }
            let text = try! JSONDecoder().decode([String].self, from: json)
            print(text)
            NotificationCenter.default.post(name: .receiveSocket, object: nil, userInfo: ["text": text])
        }
        socket?.connect()
    }
    
    func send(string: String) {
        socket?.emit("sendImage", string)
    }
    
    func sendText(stringArray: [String]) {
        let jsonData = try! JSONSerialization.data(withJSONObject: stringArray)
        let jsonStr = String(bytes: jsonData, encoding: .utf8)!
        socket?.emit("sendText", jsonStr)
    }
    
    func release() {
        socket?.disconnect()
        socket?.off("message")
        socket?.off(clientEvent: .connect)
        socket?.off(clientEvent: .disconnect)
    }
    
    deinit {
        socket?.disconnect()
    }
    
}

