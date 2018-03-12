/*:
 By [@spllr](http://github.com/spllr) over at [Stone Soup](http://stonesoup.io).
 
 # Build Your Own Camera
 
 In this playground we will build a basic camera using `AVFoundation`.

 The aim of this Playground is to give you a simple, but complete, starting point to build your own camera Apps.
 
 This Playground will run on both iOS and macos, so make sure you select the correct platform from the Utilities pane (cmd + alt + 0).

 Lets get started and import the frameworks we will need.
 */
import PlaygroundSupport

// importing AVFoundation gives access to all the API needed to build our camera.
import AVFoundation

// Import AppKit on macos
#if os(OSX)
import AppKit
    
// Otherwise import UIKit
#else
import UIKit
#endif


/*:
 ## Getting Started
 
 To capture data from the cameras and microphones available on your machine we need an `AVCaptureSession` instance.
 
 We will make a capture session and attach a video and an audio input to it.
 
 Adding capture outputs to the session which allows us to do something useful with the camera data.
 
 ## Build the Capture Session
 
 We will need an instance of `AVCaptureSession` to build our camera.
 */

let session = AVCaptureSession()

/*:
 ### Add The Video Device
 
 We will add a new input.
 
 The input will connect the default video device of the current iPhone or Mac to the session.
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
 ### Add The Audio Device
 
 We now add an input to capture audio.
 
 We will connect the default microphone of the current machine to the capture session.
 */

// I've encoountered some issues attaching two channels (audio and video) in a Swift For iPad. So we will only capture audio on macos for now.

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
 
 We can show the video of the capture session using a preview video [layer](https://developer.apple.com/documentation/quartzcore/calayer).
 
 _NOTE: When working on macos, you should have a look at at AVKit. There you will find some plug and play UI you can use to control the sessions recording.
 */

let previewLayer = AVCaptureVideoPreviewLayer(session: session)

previewLayer.videoGravity = .resizeAspect

/*:
 Depending on the platform you want are running, we create a `NSView` or a `UIView` for `macos` and `iOS` respectively.
 */


// When os macos, use NSView
#if os(OSX)
    
let view = NSView()
view.layer = previewLayer
    
// Otherwise use UIView
#else
    
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

view.frame = CGRect(x: 0, y: 0, width: 700, height: 300)


/*:
 ## Prepare For Data Capture
 
 To make use of the video and audio data we need an object to receive and process the data.
 
 You can find the implementation of this object in `SourceCaptureDelegate.swift` in the `Sources` folder of this playground.
 
 Also see the [AVCaptureVideoDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutputsamplebufferdelegate) and [AVCaptureAudioDataOutputSampleBufferDelegate](https://developer.apple.com/documentation/avfoundation/avcaptureaudiodataoutputsamplebufferdelegate) protocol documentation.
 
 ### Output Video
 
 Now that we have video data coming in from the camera, we should do something with it.
 
 #### Raw Data
 
 To receive the raw video and audio packets, you will need to implement your own class(es).
 
 The classes should conform to the `AVCaptureVideoDataOutputSampleBufferDelegate` protocol.
 
 Our class should implement the `captureOutput(_, didOutput:, from:)` function where it will receive each video buffers in order.
*/

let videoProcessor = VideoProcessor()


/*:
 Using a `AVCaptureVideoDataOutput` we can direct the video data to our `VideoProcessor`.
 */

var videoDataOutput = AVCaptureVideoDataOutput()


/*:
 We want the calls to `videoDataOutput.captureOutput` to happen on a seperate [dispatch queue](https://developer.apple.com/documentation/dispatch).
 
 This will leave the main queue free to do other work.
 */

let videoQueue = DispatchQueue(label: "capture.video")

/*:
 By using the `videoProcessor` as the sample buffer delegate of the `videoDataOutput`, will start receiving received all video data via our `videoProcessor.captureOutput(_, didOutput:, from:)` function.
 */

videoDataOutput.setSampleBufferDelegate(videoProcessor, queue: videoQueue)

//: Connect the video output to the capture session.

if session.canAddOutput(videoDataOutput)
{
    session.beginConfiguration()
    
    session.addOutput(videoDataOutput)
    
    session.commitConfiguration()
}

else
{
    print("could not add video output to session")
}



/*:
 ### Output Audio
 
 Now repeat the process with the audio.
 */

let audioProcessor = AudioProcessor()

let audioDataOutput = AVCaptureAudioDataOutput()

//: The audio data will be processed on a seperate operation queue.

let audioQueue = DispatchQueue(label: "capture.audio")

//: As we did with the video processor, we use the audio processor as the sample buffer delegate of the audio data output.

audioDataOutput.setSampleBufferDelegate(audioProcessor, queue: audioQueue)

//: Connect the audio data output to the session

if session.canAddOutput(audioDataOutput)
{
    session.beginConfiguration()
    
    session.addOutput(audioDataOutput)
    
    session.commitConfiguration()
}

else
{
    print("could not add output to session")
}


/*:
 ### Start The Session
 
 Devices can now input audio and video data, outputs can receive all this data, and there a way to view what the camera is filming.
 
 Time to start running the session.
 */

//: We can show the view in the live view of the playground.

PlaygroundPage.current.liveView = view

PlaygroundPage.current.needsIndefiniteExecution = true


session.startRunning()


