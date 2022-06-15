import MapKit
import SwiftUI
import Foundation
import CoreLocation

struct ContentView: View {
  @State private var directions: [String] = []
  @State private var showDirections = false
  @StateObject var locationManager = LocationManager()
//  @ObservedObject var locationManager: LocationManager

    var body: some View {
      VStack {
        HStack {
          MapView(directions: $directions)
        }
        HStack {
          Button(action: {
            self.showDirections.toggle()
          }, label: {
            Text("Show directions")
          })
          .disabled(directions.isEmpty)
          .padding()
        }
        HStack {
          Text(locationManager.locationString)
            .font(.callout)
        }
        
        HStack {
          Spacer()
          Button(action: {
            locationManager.stopLocationServices()
          }, label: {
            Text("Stop location")
          })
          .font(.callout)
          Spacer()
          Button(action: {
            locationManager.startLocationServices()
          }, label: {
            Text("Start location")
          })
          .font(.callout)
          Spacer()
        }
        

      } ///_Vstack
      .sheet(isPresented: $showDirections, content: {
        VStack {
          Text("Directions").font(.largeTitle).bold().padding()
          Divider().background(Color.blue)
          List {
            ForEach(0..<self.directions.count, id: \.self) { i in
              Text(self.directions[i]).padding()
            }
          } ///_List
        } ///_VStack
      }) ///_Sheet
    } ///_Body
} ///_Struct

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MapView: UIViewRepresentable {
  typealias UIViewType = MKMapView
  @Binding var directions: [String]
  
  func makeCoordinator() -> MapViewCoordinator {
    return MapViewCoordinator()
  }
  
  /// Creates LocationManager class access to MapView Struct.
//  func makeCoordinatorLocationManager() -> LocationManager {
//    return LocationManager()
//  }
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator ///Tämä delegoi class MapViewCoordinatorin UI:hin
    
    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 40.71, longitude: -74), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    mapView.setRegion(region, animated: true)
    
    // NYC
    let place1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.71, longitude: -74))
    
    // Boston
    let place2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.05))
    
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: place1)
    request.destination = MKMapItem(placemark: place2)
    request.transportType = .automobile
    
    let directions = MKDirections(request: request)
    directions.calculate { response, error in
      guard let route = response?.routes.first else { return }
      mapView.addAnnotations([place1, place2])
      mapView.addOverlay(route.polyline)
      mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
      self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
    }
    
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: Context) {
  }
  
  // MARK: Coordinator Class
  class MapViewCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = .blue
      renderer.lineWidth = 5
      return renderer
    }
  }

} ///_Struct MapView UIViewRepresentable
