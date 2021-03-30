//
//  Camera.swift
//  devilcore
//
//  Created by Mu Young Ko on 2021/03/28.
//

import Foundation
import UIKit
import AVKit
import Photos

@objc
public class DevilCamera: NSObject
//                          , NextLevelDelegate, NextLevelDeviceDelegate, NextLevelVideoDelegate, NextLevelPhotoDelegate
{
//    public func nextLevelDevicePositionWillChange(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelDevicePositionDidChange(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didChangeDeviceOrientation deviceOrientation: NextLevelDeviceOrientation) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didChangeDeviceFormat deviceFormat: AVCaptureDevice.Format) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didChangeCleanAperture cleanAperture: CGRect) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didChangeLensPosition lensPosition: Float) {
//
//    }
//
//    public func nextLevelWillStartFocus(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelDidStopFocus(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelWillChangeExposure(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelDidChangeExposure(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelWillChangeWhiteBalance(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelDidChangeWhiteBalance(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didUpdateVideoZoomFactor videoZoomFactor: Float) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, willProcessRawVideoSampleBuffer sampleBuffer: CMSampleBuffer, onQueue queue: DispatchQueue) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, renderToCustomContextWithImageBuffer imageBuffer: CVPixelBuffer, onQueue queue: DispatchQueue) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, willProcessFrame frame: AnyObject, timestamp: TimeInterval, onQueue queue: DispatchQueue) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didSetupVideoInSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didSetupAudioInSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didStartClipInSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didCompleteClip clip: NextLevelClip, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didAppendVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didSkipVideoSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didAppendVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didSkipVideoPixelBuffer pixelBuffer: CVPixelBuffer, timestamp: TimeInterval, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didAppendAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didSkipAudioSampleBuffer sampleBuffer: CMSampleBuffer, inSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didCompleteSession session: NextLevelSession) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didCompletePhotoCaptureFromVideoFrame photoDict: [String : Any]?) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, willCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didCapturePhotoWithConfiguration photoConfiguration: NextLevelPhotoConfiguration) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didProcessPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didProcessRawPhotoCaptureWith photoDict: [String : Any]?, photoConfiguration: NextLevelPhotoConfiguration) {
//
//    }
//
//    public func nextLevelDidCompletePhotoCapture(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didFinishProcessingPhoto photo: AVCapturePhoto) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didUpdateVideoConfiguration videoConfiguration: NextLevelVideoConfiguration) {
//
//    }
//
//    public func nextLevel(_ nextLevel: NextLevel, didUpdateAudioConfiguration audioConfiguration: NextLevelAudioConfiguration) {
//
//    }
//
//    public func nextLevelSessionWillStart(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelSessionDidStart(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelSessionDidStop(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelSessionWasInterrupted(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelSessionInterruptionEnded(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelCaptureModeWillChange(_ nextLevel: NextLevel) {
//
//    }
//
//    public func nextLevelCaptureModeDidChange(_ nextLevel: NextLevel) {
//
//    }
    
 
    @objc public func capture(_ vc:UIViewController) {
        
//        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (response) in
//            if(response) {
//                print("adfsf")
//            }
//        }
//        let photos = PHPhotoLibrary.authorizationStatus()
//        PHPhotoLibrary.requestAuthorization({(newStatus) in
//                 if newStatus ==  PHAuthorizationStatus.authorized {
//                  /* do stuff here */
//            }
//        })
//
//        
//        let screenBounds = UIScreen.main.bounds
//        let previewView = UIView(frame: screenBounds)
//        previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        previewView.backgroundColor = UIColor.black
//        NextLevel.shared.previewLayer.frame = previewView.bounds
//        previewView.layer.addSublayer(NextLevel.shared.previewLayer)
//        vc.view.addSubview(previewView)
//        
//        NextLevel.shared.delegate = self
//        NextLevel.shared.deviceDelegate = self
//        NextLevel.shared.videoDelegate = self
//        NextLevel.shared.photoDelegate = self
//
//        // modify .videoConfiguration, .audioConfiguration, .photoConfiguration properties
//        // Compression, resolution, and maximum recording time options are available
//        NextLevel.shared.videoConfiguration.maximumCaptureDuration = CMTimeMakeWithSeconds(5, preferredTimescale: 600)
//        NextLevel.shared.audioConfiguration.bitRate = 44000
//        do{
//            try NextLevel.shared.start()
//        } catch _ {
//            
//        }
//        NextLevel.shared.record()
    }
}
