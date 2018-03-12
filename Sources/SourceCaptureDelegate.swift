import Foundation

import Foundation
import AVFoundation

// This class will be used for both audio and video data.
// You can break this up if needed, like in the camera

public class VideoProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
{
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    /// here we receive all video data from the capture session
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        
        // Do video stuff
        
//      // Get some info about the image
//      if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//      {
//          let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
//          let width = CVPixelBufferGetWidth(imageBuffer)
//          let height = CVPixelBufferGetHeight(imageBuffer)
//
//          //print("buffer: w: \(width), h: \(height), bpr: \(bytesPerRow)")
//      }
    }
}

public class AudioProcessor: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate
{
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    /// here we receive all audio buffers from the capture session
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        // stuff with the audio data
    }
}

