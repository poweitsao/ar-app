//
//  ARViewContainer.swift
//  PoweiARApp2
//
//  Created by Po on 12/1/23.
//
import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.scene = SCNScene()
        arView.session.run(ARWorldTrackingConfiguration())

        // Add gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)

        // Add the circle node
        context.coordinator.addCircleNode(to: arView.scene.rootNode)

        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        func createCircularImage(diameter: CGFloat, color: UIColor) -> UIImage {
            let size = CGSize(width: diameter, height: diameter)
            let rect = CGRect(origin: .zero, size: size)

            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()!
            
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: rect)

            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()

            return image
        }

        func addCircleNode(to rootNode: SCNNode) {
            let circleImage = createCircularImage(diameter: 100, color: .blue) // Adjust diameter as needed

            let circleNode = SCNNode(geometry: SCNPlane(width: 0.1, height: 0.1)) // 10cm x 10cm plane
            circleNode.geometry?.firstMaterial?.diffuse.contents = circleImage
            circleNode.position = SCNVector3(x: 0, y: 0, z: -0.5) // 50cm in front of the camera
            circleNode.name = "circle" // Set name to identify the node
            rootNode.addChildNode(circleNode)
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = recognizer.view as? ARSCNView else { return }

            let location = recognizer.location(in: arView)
            let hitResults = arView.hitTest(location, options: nil)

            if let hitResult = hitResults.first {
                // Check if the circle node was tapped
                expandNode(hitResult.node)
            }
        }
        
        func snapshotView<T: View>(_ view: T, completion: @escaping (UIImage) -> Void) {
            let controller = UIHostingController(rootView: view)
            let view = controller.view

            let targetSize = CGSize(width: 300, height: 200) // Adjust size as needed
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            view?.backgroundColor = .clear

            // Delay to allow SwiftUI view to layout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let renderer = UIGraphicsImageRenderer(size: targetSize)
                let image = renderer.image { _ in
                    view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
                }
                completion(image)
            }
        }



        func expandNode(_ node: SCNNode) {
            if node.name == "circle" {
                // Expand to info tile
                snapshotView(InfoTileView()) { image in
                    // Main thread needed to update UI
                    DispatchQueue.main.async {
                        // Change the geometry to represent an info tile
                        node.geometry = SCNPlane(width: 0.3, height: 0.2) // Adjust size as needed
                        // Update the content of the node with the SwiftUI view snapshot
                        node.geometry?.firstMaterial?.diffuse.contents = image
                        node.name = "infoTile"
                    }
                }
            } else if node.name == "infoTile" {
                // Collapse back to circle
                node.geometry = SCNPlane(width: 0.1, height: 0.1)
                node.geometry?.firstMaterial?.diffuse.contents = createCircularImage(diameter: 100, color: .blue)
                node.name = "circle"
            }
        }

    }
}
