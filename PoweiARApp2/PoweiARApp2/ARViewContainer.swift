//
//  ARViewContainer.swift
//  PoweiARApp2
//
//  Created by Po on 12/1/23.
//
import SwiftUI
import ARKit
import SceneKit
import CoreLocation

class ARViewReference {
    var arView: ARSCNView?
}

struct ARViewContainer: UIViewRepresentable {
    var arViewReference = ARViewReference()
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.scene = SCNScene()
        arView.session.run(ARWorldTrackingConfiguration())

        // Add gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)

        // Add the circle node
        context.coordinator.addCircleNode(to: arView.scene.rootNode, withName: "circle", latitude: 40.285538, longitude: -74.677366)
//        context.coordinator.addCircleNode(to: arView.scene.rootNode, withName: "circle", position: SCNVector3(x: 0.3, y: 0, z: -1))
//        context.coordinator.addCircleNode(to: arView.scene.rootNode, withName: "circle", position: SCNVector3(x: 0.6, y: 0, z: -1))
//        context.coordinator.addCircleNode(to: arView.scene.rootNode, withName: "circle", position: SCNVector3(x: 0, y: 0, z: -1))
        arViewReference.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(arViewReference: arViewReference)
    }

    class Coordinator: NSObject, CLLocationManagerDelegate {
        var arViewReference: ARViewReference
        
        var locationManager = CLLocationManager()
        var userLocation = CLLocation()
        var targetLocation: CLLocation?
        
        init(arViewReference: ARViewReference) {
            self.arViewReference = arViewReference
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // CLLocationManagerDelegate methods
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                userLocation = location
                // If targetLocation is set, update the position of the node
                if targetLocation != nil {
                    updateNodePosition()
                }
            }
        }
        
        func clamp(_ value: Float, min: Float, max: Float) -> Float {
            return value < min ? min : (value > max ? max : value)
        }
        
        func updateNodePosition() {
            guard let targetLocation = targetLocation, let arView = arViewReference.arView else { return }

            let distance = userLocation.distance(from: targetLocation)
            if distance < 10 {
                // Logic to pin the node in 3D space around the user
            } else {
                // Recalculate the node's position as the user moves
                var newLocalPosition = convertGPSToAR(latitude: targetLocation.coordinate.latitude, longitude: targetLocation.coordinate.longitude)
                newLocalPosition.z = clamp(newLocalPosition.z, min: -1, max: 1)
                newLocalPosition.x = clamp(newLocalPosition.x, min: -1, max: 1)
                print("newLocalPosition", newLocalPosition)
                // Update the position of the node
                if let node = arView.scene.rootNode.childNode(withName: "circle", recursively: true) {
                    node.position = newLocalPosition
                }
            }
        }
        
        func convertGPSToAR(latitude: Double, longitude: Double) -> SCNVector3 { // WIP, not using user's heading to put the marker at the right spatial place, but icon shows up
            targetLocation = CLLocation(latitude: latitude, longitude: longitude)
            // Initial basic conversion, you may need to refine this for accuracy
            print("userLocation", userLocation)
            let distance = userLocation.distance(from: targetLocation!)
            // Convert distance to an SCNVector3. This example assumes directly ahead, adjust as needed.
            return SCNVector3(0, 0, -Float(distance))
        }
        
//        func convertGPSToAR(latitude: Double, longitude: Double) -> SCNVector3 {
//            print("userLocation", userLocation)
//            let targetLocation = CLLocation(latitude: latitude, longitude: longitude)
//
//            // Calculate distance
//            let distance = userLocation.distance(from: targetLocation)
//
//            // Calculate bearing
//            let bearing = bearingToLocationRadian(userLocation, targetLocation: targetLocation)
//
//            // Convert bearing and distance to x and z coordinates
//            let z = -Float(distance * cos(bearing)) // Forward/backward axis
//            let x = Float(distance * sin(bearing))  // Left/right axis
//
//            // Return SCNVector3
//            return SCNVector3(x, 0, z) // Assuming y-axis (vertical) is not affected
//        }

        // Helper function to compute bearing
        func bearingToLocationRadian(_ userLocation: CLLocation, targetLocation: CLLocation) -> Double {
            let lat1 = userLocation.coordinate.latitude.toRadians()
            let lon1 = userLocation.coordinate.longitude.toRadians()

            let lat2 = targetLocation.coordinate.latitude.toRadians()
            let lon2 = targetLocation.coordinate.longitude.toRadians()

            let dLon = lon2 - lon1

            let y = sin(dLon) * cos(lat2)
            let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
            let radiansBearing = atan2(y, x)

            return radiansBearing
        }
        
        func addCircleNode(to rootNode: SCNNode, withName name: String, latitude: Double, longitude: Double) {
            let localPosition = convertGPSToAR(latitude: latitude, longitude: longitude)
            print("localPosition", localPosition)
            
            snapshotView(width: 300, height: 200, CircleView()) { image in
                // Main thread needed to update UI
                DispatchQueue.main.async {
                    let node = SCNNode(geometry: SCNPlane(width: 0.2, height: 0.1))
                    // Change the geometry to represent an info tile
                    node.geometry = SCNPlane(width: 0.3, height: 0.2) // Adjust size as needed
                    // Update the content of the node with the SwiftUI view snapshot
                    node.geometry?.firstMaterial?.diffuse.contents = image
                    node.position = localPosition
                    node.name = name
                    
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
            
            if let nodeName = node.name, nodeName.hasPrefix("circle") {
                // Extract the number after "circle"
                let number = String(nodeName.dropFirst("circle".count))
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
                        node.name = "infoTile" + number
                    }
                }

            } else if let nodeName = node.name, nodeName.hasPrefix("infoTile") {
                // Extract the number after "infoTile"
                let number = String(nodeName.dropFirst("infoTile".count))
                
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
                        node.name = "circle" + number
                    }
                }
            }
            
            let billboardConstraint = SCNBillboardConstraint()
                billboardConstraint.freeAxes = .all
                node.constraints = [billboardConstraint]
        }

    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}
