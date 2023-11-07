//
//  ARViewContainer.swift
//  PoweiARApp
//
//  Created by Powei on 11/2/23.
//

import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(createTileNode())

        arView.scene = scene
        arView.session.run(ARWorldTrackingConfiguration())
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    private func createTileNode() -> SCNNode {
        let fixedWidth: CGFloat = 400 // The width you want for your UIView
        // Create your view with the SwiftUI view injected and a specific width.
        let uiView = UIView.from(swiftUIView: InfoTile().background(Color.clear).clipped(), width: fixedWidth)

        // Now the uiView has the correct size, you can create the SCNPlane
        let plane = SCNPlane(width: fixedWidth / 1000.0, height: uiView.frame.height / 1000.0) // Convert points to meters
        plane.firstMaterial?.diffuse.contents = uiView
        plane.firstMaterial?.isDoubleSided = true
        plane.cornerRadius = 0.05

        let planeNode = SCNNode(geometry: plane)
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
}
