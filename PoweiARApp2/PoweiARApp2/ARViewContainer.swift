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
        func addCircleNode(to rootNode: SCNNode) {            
            snapshotView(width: 300, height: 200, CircleView()) { image in
                // Main thread needed to update UI
                DispatchQueue.main.async {
                    let node = SCNNode(geometry: SCNPlane(width: 0.2, height: 0.1))
                    // Change the geometry to represent an info tile
                    node.geometry = SCNPlane(width: 0.3, height: 0.2) // Adjust size as needed
                    // Update the content of the node with the SwiftUI view snapshot
                    node.geometry?.firstMaterial?.diffuse.contents = image
                    node.position = SCNVector3(x: 0, y: 0, z: -1)
                    node.name = "circle"
                    
                    // Billboard constraint
                    let billboardConstraint = SCNBillboardConstraint()
                    billboardConstraint.freeAxes = .all
                    node.constraints = [billboardConstraint]
                    rootNode.addChildNode(node)
                }
            }
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
        
        func snapshotView<T: View>(width: Double, height: Double, _ view: T, completion: @escaping (UIImage) -> Void) {
            let controller = UIHostingController(rootView: view)
            let view = controller.view

            let targetSize = CGSize(width: width, height: height) // Adjust size as needed
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
                let width: Double = 400
                let height: Double = 800
                snapshotView(width: width, height: height, InfoTileView()) { image in
                    // Main thread needed to update UI
                    DispatchQueue.main.async {
                        // Change the geometry to represent an info tile
                        node.geometry = SCNPlane(width: width/1000, height: height/1000) // Adjust size as needed
                        // Update the content of the node with the SwiftUI view snapshot
                        node.geometry?.firstMaterial?.diffuse.contents = image
                        node.name = "infoTile"
                    }
                }
            } else if node.name == "infoTile" {
                // Collapse back to circle
                let width: Double = 300
                let height: Double = 200
                snapshotView(width: width, height: height, CircleView()) { image in
                    // Main thread needed to update UI
                    DispatchQueue.main.async {
                        // Change the geometry to represent an info tile
                        node.geometry = SCNPlane(width: width/1000, height: height/1000) // Adjust size as needed
                        // Update the content of the node with the SwiftUI view snapshot
                        node.geometry?.firstMaterial?.diffuse.contents = image
                        node.position = SCNVector3(x: 0, y: 0, z: -1)
                        node.name = "circle"
                    }
                }
            }
            
            let billboardConstraint = SCNBillboardConstraint()
                billboardConstraint.freeAxes = .all
                node.constraints = [billboardConstraint]
        }

    }
}
