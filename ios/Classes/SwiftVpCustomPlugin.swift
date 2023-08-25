import Flutter
import UIKit
import Foundation
import AVKit

public class SwiftVpCustomPlugin: NSObject, FlutterPlugin, AVPlayerViewControllerDelegate {
     public static var shared : SwiftVpCustomPlugin!
     var avPlayer: AVPlayer!
     var avPlayerViewController: AVPlayerViewController!
     var avPlayerItem: AVPlayerItem!
     var avAsset: AVAsset!
     var playerItemContext = 0
     var avPlayerItemStatus: AVPlayerItem.Status = .unknown
     var isReadyToPlay: Bool = false

     var currentUserId:String!
     var currentProfileId:String!
     var currentVideoId:String!
     var itemVideoType:String! = nil
     var currentPlayPosition: CMTime!
     var lastPlayPosition: Double!
    
    var caller : FlutterMethodCall!
    var isCustomPlayer : Bool = false
    var customPlayerUrl : String!
     public static func register(with registrar: FlutterPluginRegistrar) {
         let channel = FlutterMethodChannel(name: "vp_custom", binaryMessenger: registrar.messenger())

         let instance = SwiftVpCustomPlugin()
         registrar.addMethodCallDelegate(instance, channel: channel)
         shared = instance
     }

     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
         let flutterViewController: UIViewController =
         (UIApplication.shared.delegate?.window??.rootViewController)!;
         switch(call.method){
         case "play":
             self.play(result: result, call: call, controller: flutterViewController)
             break;
         case "custom_player":
             self.caller = call
             self.customPlay(controller: flutterViewController, call: call)
             break
         default:
             print("method wasn't found : ",call.method);
         }
     }
    
    func customPlay(controller : UIViewController,call: FlutterMethodCall, time : Double = 0){
        self.isCustomPlayer = true
        self.avPlayerItemStatus = .unknown
        self.isReadyToPlay = false
        guard let args = call.arguments else {
            return
        }
        if let myArgs = args as? [String: Any],
           let itemVideoUrl : String = myArgs["mediaUrl"] as? String,
           let playPosition : String = myArgs["playPosition"] as? String
        {
            self.customPlayerUrl = itemVideoUrl
            let videoURL = URL(string: itemVideoUrl)
            self.currentPlayPosition = CMTime(seconds: time, preferredTimescale: .max)
            self.lastPlayPosition = self.currentPlayPosition.seconds
            
            self.avAsset = AVAsset(url: videoURL!)
            self.avPlayerItem = AVPlayerItem(asset: self.avAsset)
            self.avPlayer = AVPlayer(playerItem: self.avPlayerItem)
            self.avPlayerViewController = AVPlayerViewController()
            self.avPlayerViewController.player = self.avPlayer
            self.avPlayerViewController.allowsPictureInPicturePlayback = true
            self.avPlayerViewController.delegate = self
            self.avPlayerItem.addObserver(self,
                                          forKeyPath: #keyPath(AVPlayerItem.status),
                                          options: [.old, .new],
                                          context: &self.playerItemContext)
            
            controller.present(self.avPlayerViewController, animated: true) {
                try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            }
        }
        
    }
    
     func play(result: @escaping FlutterResult,call: FlutterMethodCall,controller : UIViewController, time : Double = 0){
         self.isCustomPlayer = false
         self.avPlayerItemStatus = .unknown
         self.isReadyToPlay = false
         guard let args = call.arguments else {
             return
         }
         if let myArgs = args as? [String: Any],
            let itemVideoUrl : String = myArgs["mediaUrl"] as? String,
            let userId : String = myArgs["userId"] as? String,
            let profileId : String = myArgs["profileId"] as? String,
            let playPosition : String = myArgs["playPosition"] as? String,
            let videoType : String = myArgs["type"] as? String,
            let id = myArgs["id"] as? String
         {
             if(videoType != nil){
                 self.itemVideoType = videoType
             }
             self.currentUserId = userId
             self.currentProfileId = profileId
             self.currentVideoId = id

             let videoURL = URL(string: itemVideoUrl)
             self.currentPlayPosition = CMTime(value: CMTimeValue(Int32(playPosition)!), timescale: 1000)
             self.lastPlayPosition = self.currentPlayPosition.seconds


             self.avAsset = AVAsset(url: videoURL!)
             self.avPlayerItem = AVPlayerItem(asset: self.avAsset)
             self.avPlayer = AVPlayer(playerItem: self.avPlayerItem)
             self.avPlayerViewController = AVPlayerViewController()
             self.avPlayerViewController.player = self.avPlayer
             self.avPlayerViewController.allowsPictureInPicturePlayback = true


             // Register as an observer of the player item's status property
             self.avPlayerItem.addObserver(self,
                                           forKeyPath: #keyPath(AVPlayerItem.status),
                                           options: [.old, .new],
                                           context: &self.playerItemContext)
             self.avPlayerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.old, .new],
                                           context: &self.playerItemContext)
             self.avPlayerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.old, .new],
                                           context: &self.playerItemContext)
             self.avPlayerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: [.old, .new],
                                           context: &self.playerItemContext)
             self.avPlayerItem.addObserver(self, forKeyPath: "rate", options: [.old, .new],
                                           context: &self.playerItemContext)
             self.avPlayerItem.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)

             controller.present(self.avPlayerViewController, animated: true) {
                 try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: [])
                 if #available(iOS 13.0, *) {
                     self.avPlayerViewController.isModalInPresentation = true
                 } else {
                     self.avPlayerViewController.modalPresentationStyle = .fullScreen
                 }
                 if(self.avPlayer != nil){
                     if #available(iOS 10.0, *) {
                         self.avPlayerItem?.preferredForwardBufferDuration = TimeInterval(5)
                         self.avPlayer?.automaticallyWaitsToMinimizeStalling = self.avPlayerItem?.isPlaybackBufferEmpty ?? false
                         self.avPlayer?.currentItem?.preferredForwardBufferDuration = TimeInterval(5)
                         self.avPlayer?.play()
                     } else {
                         self.avPlayer?.play()
                     }
                 }

                 Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in

                     if ((self?.avPlayerViewController.isBeingDismissed)! || self?.avPlayerViewController.next == nil) {
                         print("AVPlayer Disappered")
                         timer.invalidate()
                         self?.avPlayerViewController.player?.pause()
                         self?.avPlayerViewController.player = AVPlayer()
                         if(self?.avPlayer != nil){
                             self?.avPlayer.pause()
                         }
                         if(self?.isReadyToPlay ?? false) {
                             let jsonObject: Any  =
                             [
                                 "mediaId": self?.currentVideoId as Any,
                                 "time": self?.avPlayer!.currentTime().seconds as Any,
                                 "duration": self?.avPlayer!.currentItem!.asset.duration.seconds as Any,
                                 "userId": self?.currentUserId as Any,
                                 "profileId": self?.currentProfileId as Any,
                                 "lang":"ar",
                                 "type":self?.itemVideoType as Any
                             ]
                             if(self?.avPlayer != nil){
                                 self?.avPlayer.replaceCurrentItem(with: nil)
                             }
                             result(jsonObject)
                         } else {
                             result(true)
                         }

                     }
                 }
             }
         }
     }

     public override func observeValue(forKeyPath keyPath: String?,
                                of object: Any?,
                                change: [NSKeyValueChangeKey : Any]?,
                                context: UnsafeMutableRawPointer?) {
         // Only handle observations for the playerItemContext
         guard context == &playerItemContext else {
             super.observeValue(forKeyPath: keyPath,
                                of: object,
                                change: change,
                                context: context)
             return
         }


         if keyPath == #keyPath(AVPlayerItem.status) {
             if let statusNumber = change?[.newKey] as? NSNumber {
                 avPlayerItemStatus = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
             } else {
                 avPlayerItemStatus = .unknown
             }
             switch avPlayerItemStatus {
             case .readyToPlay:
                 print("readyToPlay")
                 self.isReadyToPlay = true
                 // Player item is ready to play.
                 print("observeValue status : readyToPlay");
                 //                     print("currentPlayPosition : ",currentPlayPosition)
                 if(self.avPlayerViewController != nil){
                     if(currentPlayPosition.seconds > 0){
                         avPlayer.seek(to: currentPlayPosition)
                     }
                 } else {
                     print("self.avPlayerViewController nill")
                     avPlayer.pause()
                 }
                 break
             case .failed:
                 // Player item failed. See error.
                 print("observeValue status : failed ");
                 avPlayer.pause()
                 break

             case .unknown:
                 // Player item is not yet ready.
                 print("observeValue status : unknown");
                 break
             }
         }

         if object is AVPlayerItem {
             //            print(keyPath)
             switch keyPath {
             case "playbackBufferEmpty":
                 // Show loader
                 break
             case "playbackLikelyToKeepUp":
                 // Hide loader
                 var isPlaying: Bool {
                     if (self.avPlayer.rate != 0 && self.avPlayer.error == nil) {
                         return true
                     } else {
                         return false
                     }
                 }
                 if(isPlaying){
                     print("playbackLikelyToKeepUp",isPlaying)
                     if #available(iOS 10.0, *) {
                         //                        self.avPlayer?.automaticallyWaitsToMinimizeStalling = false
                         self.avPlayerItem?.preferredForwardBufferDuration = TimeInterval(5)
                         self.avPlayer?.automaticallyWaitsToMinimizeStalling = self.avPlayerItem?.isPlaybackBufferEmpty ?? false
                         self.avPlayer?.currentItem?.preferredForwardBufferDuration = TimeInterval(5)
                         //                        self.avPlayer?.playImmediately(atRate: 1.0)
                         self.avPlayer?.play()
                     } else {
                         avPlayer?.play()
                     }
                 } else {
                     print("playbackLikelyToKeepUp",isPlaying)
                 }
                 break
             case "playbackBufferFull":
                 // Hide loader
                 var isPlaying: Bool {
                     if (self.avPlayer.rate != 0 && self.avPlayer.error == nil) {
                         return true
                     } else {
                         return false
                     }
                 }
                 if(isPlaying){
                     print("playbackBufferFull",isPlaying)
                     //                    avPlayer.play()
                     if #available(iOS 10.0, *) {
                         //                        self.avPlayer?.automaticallyWaitsToMinimizeStalling = false
                         self.avPlayerItem?.preferredForwardBufferDuration = TimeInterval(5)
                         self.avPlayer?.automaticallyWaitsToMinimizeStalling = self.avPlayerItem?.isPlaybackBufferEmpty ?? false
                         self.avPlayer?.currentItem?.preferredForwardBufferDuration = TimeInterval(5)
                         //                        self.avPlayer?.playImmediately(atRate: 1.0)
                         self.avPlayer?.play()
                     } else {
                         self.avPlayer?.play()
                     }
                 } else {
                     print("playbackBufferFull",isPlaying)
                 }
                 break
             case .none:
                 break
             case .some(_):
                 break
             }
         }
     }

     public func StopActivePlaying() {
         if(self.avPlayer != nil){
             self.avPlayer.pause()
         }

     }


     public func CloseOpenConnection() {
         var isAudioSessionUsingAirplayOutputRoute: Bool {

             let audioSession = AVAudioSession.sharedInstance()
             let currentRoute = audioSession.currentRoute

             for outputPort in currentRoute.outputs {
                 if outputPort.portType == AVAudioSession.Port.airPlay {
                     return true
                 }
             }

             return false
         }
         if(isAudioSessionUsingAirplayOutputRoute){

         } else if(UIScreen.screens.count >= 2){

         } else {
             if(!self.isCustomPlayer){
                 if(self.avPlayer != nil){
                     self.avPlayer.pause()
                 }
             }
         }
     }
    
    public func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        if(self.isCustomPlayer && self.avPlayer != nil && self.caller != nil){
            let flutterViewController: UIViewController =
            (UIApplication.shared.delegate?.window??.rootViewController)!;
            self.customPlay(controller: flutterViewController, call: self.caller, time: self.avPlayer.currentTime().seconds)
        }
    }

 }
