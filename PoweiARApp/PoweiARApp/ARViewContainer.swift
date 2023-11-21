//
//  ARViewContainer.swift
//  PoweiARApp
//
//  Created by Powei on 11/2/23.
//

import SwiftUI
import ARKit

class ExpandState: ObservableObject {
    @Published var isExpanded: Bool = false
}

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var expandState: ExpandState

    
//    @Binding var isExpanded: Bool  // Binding to control expand/collapse from outside

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(createTileNode())

        arView.scene = scene
        arView.session.run(ARWorldTrackingConfiguration())
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGesture)

        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update the tile node when isExpanded changes
        print("updateUIView called!")
        updateTileNode(in: uiView)
    }
    
    private func updateTileNode(in arView: ARSCNView) {
        // Remove existing node if it exists
        arView.scene.rootNode.childNode(withName: "infoTileNode", recursively: false)?.removeFromParentNode()

        // Create and add new node
        print("updateTileNode called!")
        let tileNode = createTileNode()
        arView.scene.rootNode.addChildNode(tileNode)
        
    }
    
    class Coordinator {
        var parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            print("Tap recognized.")
            // Perform hit test
            if let arView = gesture.view as? ARSCNView {
                let location = gesture.location(in: arView)
                let hitTestResults = arView.hitTest(location)

                // Debug: Print names of all hit nodes
                for result in hitTestResults {
                    if let nodeName = result.node.name {
                        print("Hit node name: \(nodeName)")
                    } else {
                        print("Hit node with no name")
                    }
                }

                // Check if 'infoTileNode' was tapped
                if hitTestResults.first(where: { $0.node.name == "infoTileNode" }) != nil {
                    print("InfoTile node was tapped.")
//                    self.parent.isExpanded.toggle()
                    self.parent.expandState.isExpanded.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01){
                        print("isExpanded state is now \(self.parent.expandState.isExpanded)")
                    }
                } else {
                    print("InfoTile node was NOT tapped.")
                }
            }
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createTileNode() -> SCNNode {
        let fixedWidth: CGFloat = 1000 // The width you want for your UIView


//        let uiView = UIView.from(swiftUIView: InfoTile(isExpanded: expandState.isExpanded).background(Color.clear).clipped(), width: fixedWidth)
        let uiViewOne = UIView.from(swiftUIView: StationLabel().background(Color.clear).clipped(), width: fixedWidth)

        // Use the passed height if available, otherwise calculate as before
        let tileHeight = uiViewOne.frame.height // Convert points to meters
        print("tileHeight:", tileHeight)
        
        let uiViewTwo = UIView.from(swiftUIView: StationLabel().background(Color.clear).clipped(), height: tileHeight)
        
        let tileWidth = uiViewTwo.frame.width // Convert points to meters
        print("tileWidth:", tileWidth)
        
        
        let uiView = UIView.from(swiftUIView: StationLabel().background(Color.clear).clipped(), width: tileWidth, height: tileHeight)

        let plane = SCNPlane(width: tileWidth / 1000.0, height: tileHeight / 1000.0)
        
        let material = SCNMaterial()
        material.diffuse.contents = uiViewTwo // Your UIView with the StationLabel
        material.isDoubleSided = true

        // Set the transparency mode to .rgbZero so that only the alpha channel controls the transparency.
//        material.transparencyMode = .rgbZero

        // Setting the blending mode might also help in certain cases.
//        material.blendMode = .alpha

//        plane.materials = [material]
        
        plane.firstMaterial?.diffuse.contents = uiViewTwo
        plane.firstMaterial?.isDoubleSided = true
        plane.cornerRadius = 0.05

        let planeNode = SCNNode(geometry: plane)
        planeNode.name = "infoTileNode"
        planeNode.position = SCNVector3(x: 0, y: 0, z: -1) // Position the node in front of the camera

        return planeNode
    }



}
extension UIView {
    static func from<T: View>(swiftUIView: T, width: CGFloat) -> UIView {
        let hostingController = UIHostingController(rootView: swiftUIView)
        // Set the view's frame with the desired width and a high height to allow the content to define its height.
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude)
        hostingController.view.backgroundColor = .clear
        hostingController.view.sizeToFit()

        // Lay out the view and get the actual height it needs.
        let size = hostingController.view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: size.height)
        return hostingController.view
    }
    
    static func from<T: View>(swiftUIView: T, height: CGFloat) -> UIView {
        let hostingController = UIHostingController(rootView: swiftUIView)
        // Set the view's frame with the desired width and a high height to allow the content to define its height.
        hostingController.view.frame = CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height)
        hostingController.view.backgroundColor = .clear
        hostingController.view.sizeToFit()

        // Lay out the view and get the actual height it needs.
        let size = hostingController.view.systemLayoutSizeFitting(
            CGSize(width: UIView.layoutFittingCompressedSize.width, height: height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: size.width, height: height)
        return hostingController.view
    }
    
    static func from<T: View>(swiftUIView: T, width: CGFloat, height: CGFloat) -> UIView {
        let hostingController = UIHostingController(rootView: swiftUIView)
        // Set the view's frame with the desired width and a high height to allow the content to define its height.
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        hostingController.view.backgroundColor = .clear
        hostingController.view.sizeToFit()

        // Lay out the view and get the actual height it needs.
        let size = hostingController.view.systemLayoutSizeFitting(
            CGSize(width: width, height: height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        hostingController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        return hostingController.view
    }
}
