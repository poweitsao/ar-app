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
import CoreMotion

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
        context.coordinator.addCircleNode(to: arView.scene.rootNode, withName: "circle1", latitude: 40.285606, longitude: -74.679997) // south ish
        context.coordinator.addCircleNode(to: arView.scene.rootNode, withName: "circle2", latitude: 40.288528, longitude: -74.678673) //North ish 40.288528, -74.678673
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
        
        var motionManager = CMMotionManager()
        var locationManager = CLLocationManager()
        var userLocation = CLLocation()
//        var targetLocation: CLLocation?
        
        var nodeTargetLocations: [String: CLLocation] = [:]
        
        init(arViewReference: ARViewReference) {
            self.arViewReference = arViewReference
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            // Start motion updates
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1
                motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical)
            }
        }
        
        // CLLocationManagerDelegate methods
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                userLocation = location
                // If targetLocation is set, update the position of the node
                updateNodePosition()
            }
        }
        
        func clamp(_ value: Float, min: Float, max: Float) -> Float {
            return value < min ? min : (value > max ? max : value)
        }
        
        func splitNodeName(_ nodeName: String) -> (prefix: String, number: String)? {
            // Regular expression pattern to match the prefix and the number
            let pattern = "^(circle|infoTile)(\\d+)$"

            // Attempt to create a regular expression
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                return nil
            }

            // Perform the search
            let nsString = nodeName as NSString
            let matches = regex.matches(in: nodeName, options: [], range: NSRange(location: 0, length: nsString.length))

            // Extract and return the prefix and number if found
            if let match = matches.first, match.numberOfRanges == 3 {
                let prefix = nsString.substring(with: match.range(at: 1))
                let number = nsString.substring(with: match.range(at: 2))
                return (prefix, number)
            }

            return nil
        }
        
        func roundToTwoDecimalPlaces(value: Float) -> Float {
            return (value * 100).rounded() / 100
        }
        
        func adjustNodePositionToTarget(targetLongitude: Double, targetLatitude: Double, targetDistance: Double, userPosition: SCNVector3) -> SCNVector3 {
            // Convert target longitude and latitude to AR scene coordinates
            let targetPosition = convertGPSToAR(latitude: targetLatitude, longitude: targetLongitude)

            // Calculate the direction vector from the user to the target on the XZ plane
            var direction = SCNVector3(targetPosition.x - userPosition.x, 0, targetPosition.z - userPosition.z)
            
            // Normalize the direction vector
            let length = roundToTwoDecimalPlaces(value: sqrt(direction.x * direction.x + direction.z * direction.z))
            direction = SCNVector3(direction.x / length, 0, direction.z / length)
            
            // Scale the direction vector to the target distance
            let scaledDirection = SCNVector3(direction.x * Float(targetDistance), 0, direction.z * Float(targetDistance))
            
            // Calculate the new node position with the same Y value as the user's position
            let newNodePosition = SCNVector3(userPosition.x + scaledDirection.x, userPosition.y, userPosition.z + scaledDirection.z)

            return newNodePosition
        }
        
        func updateNodePosition() {
            guard let arView = arViewReference.arView else { return }

            let userPosition = arView.pointOfView?.position ?? SCNVector3(0, 0, 0)

            // Iterate through all nodes
            arView.scene.rootNode.enumerateChildNodes { (node, _) in
                if let nodeName = node.name, nodeName.hasPrefix("circle") || nodeName.hasPrefix("infoTile"),
                   let result = splitNodeName(nodeName) {
                    let number = result.number
                    
                    if let targetLocation = nodeTargetLocations[number] {
                        let distance = userLocation.distance(from: targetLocation)
                        if distance < 10 {
                            // Logic to pin the node in 3D space around the user
                        } else {
                            // Here, use the specific target location for this node
                            let newLocalPosition = adjustNodePositionToTarget(targetLongitude: targetLocation.coordinate.longitude, targetLatitude: targetLocation.coordinate.latitude, targetDistance: 2.0, userPosition: userPosition)
                            node.position = newLocalPosition
                        }
                    }
                }
            }
        }

        
        func convertGPSToAR(latitude: Double, longitude: Double) -> SCNVector3 {
//            print("userLocation", userLocation)
            let targetLocation = CLLocation(latitude: latitude, longitude: longitude)

            // Calculate distance
            let distance = userLocation.distance(from: targetLocation)

            // Calculate bearing
            let bearing = bearingToLocationRadian(userLocation, targetLocation: targetLocation)

            // Convert bearing and distance to x and z coordinates
            let z = -Float(distance * cos(bearing)) // Forward/backward axis
            let x = Float(distance * sin(bearing))  // Left/right axis

            // Return SCNVector3
            return SCNVector3(x, 0, z) // Assuming y-axis (vertical) is not affected
        }

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
            let targetLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            // Store the target location in the dictionary
            if let result = splitNodeName(name) {
                let prefix = result.prefix
                let number = result.number
                nodeTargetLocations[number] = targetLocation
            }
            
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
