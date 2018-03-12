/*:
 By [@spllr](http://github.com/spllr) over at [Stone Soup](http://stonesoup.io).
 
 # Build Your Own Camera
 
 In this playground we will build a basic camera using `AVFoundation`.
 
 The aim of this playground is to give you a simple, but complete, starting point to build your own camera Apps.
 
 */
import PlaygroundSupport
import AVFoundation

/*:
 ## Getting Started
 
 Lets build a basic media capture stack.
 
 We will make a capture session and attach a video and an audio input to it.
 
 Adding some capture outputs will allow us to do something useful with the camera data.
 */

/*:
 ## Build the Capture Session
 
 We will need an instance of `AVCaptureSession` to build our camera.
 */

let session = AVCaptureSession()

/*:
 ### Add The Video Device
 
 We will add a new input. The input will add the default video device of the current iPhone or Mac to the session.
 */

if let videoDevice = AVCaptureDevice.default(for: .video)
{
    do
    {
        let videoInput = try AVCaptureDeviceInput(device: videoDevice)
        
        if session.canAddInput(videoInput)
        {
            session.beginConfiguration()
            
            session.addInput(videoInput)
            
            session.commitConfiguration()
        }
        
        else
        {
            print("could not add video input to session")
        }
    }
        
    catch
    {
        print("could not create video input: \(error.localizedDescription)")
    }
}

else
{
    print("could not get default video device")
}


/*:
 ### Add The Audios Device
 
 We now add an input to capture audio. We will use the default microphone of the current machine as a audio device of the session.
 */

// I have encoountered some issues attaching two channels (audio and video) in a Swift For iPad. So we will only capture audio on macos for now.

#if os(OSX)
    
if let audioDevice = AVCaptureDevice.default(for: .audio)
{
    do
    {
        let audioInput = try AVCaptureDeviceInput(device: audioDevice)
        
        if session.canAddInput(audioInput)
        {
            session.beginConfiguration()
            
            session.addInput(audioInput)
            
            session.commitConfiguration()
        }
            
        else
        {
            print("could not add audio input")
        }
    }
        
    catch
    {
        print("could not create audio input: \(error.localizedDescription)")
    }
}
    
else
{
    print("could not get default audio devicd")
}
    
#endif


/*:
 ### Show The Video
 
 We can show the video using a preview video [layer](https://developer.apple.com/documentation/quartzcore/calayer).
 
 _When working on macos, you should have a at AVKit, which provides some nice higher level objecs for video recoding UI._
 */

let previewLayer = AVCaptureVideoPreviewLayer(session: session)
previewLayer.videoGravity = .resizeAspect

/*:
 Depending on the platform you want are running, you create an `UIView` or a `UIView` for `macos` and `iOS` respectively.
 
 We will import the correct framework for the current platform. `AppKit` for _macos_, and `UIKit` for _iOS_.
 */

// Use AppKit when on macos

#if os(OSX)
import AppKit
    
let view = NSView()
view.layer = previewLayer
    
    
// Otherwise use UIKit
#else
import UIKit
    
/*:
 For iOS we will use a `UIView` subclass making it a bit easier to layout the video preview layer.
*/
    
class VideoViewView: UIView
{
    override func layoutSublayers(of layer: CALayer)
    {
        super.layoutSublayers(of: layer)
        
        previewLayer.frame = self.bounds

        // make sure the video is in the correct orientation
            previewLayer.connection?.videoOrientation = .landscapeRight
    }
}

let view = VideoViewView()

view.layer.addSublayer(previewLayer)

    

#endif

/*:
 ## Prepare For Data Capture
 
 In order to make use of the video and audio data we need an object to receive and process the data.
 
 You can find the implementation of this object in `SourceCaptureDelegate.swift` in the `Sources` folder of this playground.
 
 Also see the [AVCaptureVideoDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate) and [AVCaptureAudioDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcaptureaudiodataoutputsamplebufferdelegate) protocol documentation.
 
 ### Output Video
 
 Now that we have data coming in from the camera, we should do something with this data.
 
 #### Raw Data
 
 In this playground we will not go into detail on how to process video and audio buffer.
 
 But in order to receive the raw video and audio packets, you will need to implement your own class(es).
 
 The classes should conform to the
*/

let videoProcessor = VideoProcessor()


// route the video to the SourceCaptureDelegate instance

var videoDataOutput = AVCaptureVideoDataOutput()

//: The data output delegate method will be called on it's own [dispatch queue](https://developer.apple.com/documentation/dispatch).

let videoQueue = DispatchQueue(label: "capture.video")

/*:
 By setting the `videoProcessor` as the sample buffer delegate of the an `AVCaptureVideoDataOutput`, will received all video data via a call to `videoProcessor.captureOutput(_, didOutput:, from:)`.
 */

videoDataOutput.setSampleBufferDelegate(videoProcessor, queue: videoQueue)

//: We can now add the video output to the av session.

session.beginConfiguration()

session.addOutput(videoDataOutput)

session.commitConfiguration()


//: ### Output Audio

let audioProcessor = AudioProcessor()

let audioDataOutput = AVCaptureAudioDataOutput()

//: The audio data will be processed on a seperate operation queue.

let audioQueue = DispatchQueue(label: "capture.audio")

//: And as we did with the video processor, we set the audio processor as the sample buffer delegate and add the audio data output to the session.

audioDataOutput.setSampleBufferDelegate(audioProcessor, queue: audioQueue)

session.beginConfiguration()

session.addOutput(audioDataOutput)

session.commitConfiguration()


/*:
 ### Start The Session
 
 Now we devices inputing audio and video data, outputs receiving the data, and a way to view what the camera is filming.
 
 Time to start running the session.
 */

session.startRunning()

//: We can show the view in the live view of the playground.

PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true

