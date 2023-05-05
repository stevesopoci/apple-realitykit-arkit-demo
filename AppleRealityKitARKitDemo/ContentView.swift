//
//  ContentView.swift
//  AppleRealityKitARKitDemo
//
//  Created by Steve Sopoci on 5/05/23.
//

import SwiftUI
import RealityKit
import ARKit

var arView: ARView!
var spiderman: SpiderMan._SpiderMan!

struct ContentView : View {
    
    @State var id: Int = 0
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            switch(self.id) {
            case 0:
                Text("Open your mouth!")
                    .font(.largeTitle)
                    .background(Color.black)
                    .foregroundColor(.white)
            case 2:
                Text("Tap your helmet!")
                    .font(.largeTitle)
                    .background(Color.black)
                    .foregroundColor(.white)
            default:
                Text("")
                    .font(.largeTitle)
                    .background(Color.black)
                    .foregroundColor(.white)
            }
        }
        
        ZStack(alignment: .bottom) {
        ARViewContainer(id: $id).edgesIgnoringSafeArea(.all)

            HStack(){
                
                Spacer()
                
                Button(action: {
                    self.id = self.id <= 0 ? 0 : self.id - 1
                }) {
                    Image(systemName: "arrowtriangle.backward.fill").font(.system(size: 56.0, weight: .bold)).foregroundColor(Color(.white))
                }
                
                Spacer()
                
                Button(action: {
                    self.TakePhoto()
                }) {
                    Image(systemName: "circle.fill").font(.system(size: 80.0, weight: .bold)).foregroundColor(Color(.white))
                }
                
                Spacer()
                
                Button(action: {
                    self.id = self.id >= 2 ? 2 : self.id + 1
                }) {
                    Image(systemName: "arrowtriangle.forward.fill").font(.system(size: 56.0, weight: .bold)).foregroundColor(Color(.white))
                }
                
                Spacer()
            }
        }
    }
    
    func TakePhoto() {
        arView.snapshot(saveToHDR: false) { (image) in
            let compressedImage = UIImage(data: (image?.pngData())!)
            UIImageWriteToSavedPhotosAlbum(compressedImage!, nil, nil, nil)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    @Binding var id: Int
    
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        spiderman = nil
        
        arView.scene.anchors.removeAll()
        
        let arConfiguration = ARFaceTrackingConfiguration()
        uiView.session.run(arConfiguration, options:[.resetTracking, .removeExistingAnchors])
        
        switch(id) {
        case 0:
            let arAnchor = try! SpiderMan.load_SpiderMan()
            uiView.scene.anchors.append(arAnchor)
            spiderman = arAnchor
        case 1:
            let arAnchor = try! SpiderMan.loadVenom()
            uiView.scene.anchors.append(arAnchor)
        case 2:
            let arAnchor = try! SpiderMan.loadVulture()
            uiView.scene.anchors.append(arAnchor)
        default:
            break
        }
    }
    
    func makeCoordinator() -> ARDelegateHandler {
        ARDelegateHandler(self)
    }
    
    class ARDelegateHandler: NSObject, ARSessionDelegate {
        
        var isSpiderDone = true

        var arViewContainer: ARViewContainer
        
        init(_ control: ARViewContainer) {
            arViewContainer = control
            super.init()
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            
            guard spiderman != nil else { return }
            
            var faceAnchor: ARFaceAnchor?
            
            for anchor in anchors {
                if let a = anchor as? ARFaceAnchor {
                    faceAnchor = a
                }
            }
            
            let blendShapes = faceAnchor?.blendShapes
            let jawOpen = blendShapes?[.jawOpen]?.floatValue
            
            if (self.isSpiderDone == true && jawOpen! > 0.75) {
                
                self.isSpiderDone = false
                
                spiderman.notifications.showSpider.post()
                
                spiderman.actions.isSpiderDone.onAction = { _ in
                    self.isSpiderDone = true
                }
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
