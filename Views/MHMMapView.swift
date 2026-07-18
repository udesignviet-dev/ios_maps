import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct MHMMapView: UIViewRepresentable {
    let hazards: [MHMHazard]
    let checkins: [MHMCheckin]
    let userCoordinate: CLLocationCoordinate2D?
    @Binding var centerCoordinate: CLLocationCoordinate2D

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.mapType = .standard

        let region = MKCoordinateRegion(
            center: centerCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self

        if shouldMoveMap(mapView) {
            let region = MKCoordinateRegion(
                center: centerCoordinate,
                span: mapView.region.span.latitudeDelta > 0 ? mapView.region.span : MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
            mapView.setRegion(region, animated: true)
        }

        let existing = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existing)
        mapView.addAnnotations(hazards.map { MHMAnnotation(hazard: $0) })
        mapView.addAnnotations(checkins.map { MHMAnnotation(checkin: $0) })
    }

    private func shouldMoveMap(_ mapView: MKMapView) -> Bool {
        let current = mapView.centerCoordinate
        let distance = CLLocation(latitude: current.latitude, longitude: current.longitude)
            .distance(from: CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude))
        return distance > 25
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MHMMapView

        init(_ parent: MHMMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.centerCoordinate = mapView.centerCoordinate
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? MHMAnnotation else { return nil }
            let identifier = annotation.kind.rawValue
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.annotation = annotation
            view.canShowCallout = true
            view.markerTintColor = annotation.kind == .hazard ? .systemRed : .systemOrange
            view.glyphImage = UIImage(systemName: annotation.kind == .hazard ? "exclamationmark.triangle.fill" : "mappin.circle.fill")
            return view
        }
    }
}

final class MHMAnnotation: NSObject, MKAnnotation {
    enum Kind: String {
        case hazard
        case checkin
    }

    let id: Int
    let kind: Kind
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(hazard: MHMHazard) {
        self.id = hazard.id
        self.kind = .hazard
        self.coordinate = hazard.coordinate.clLocation
        self.title = hazard.title
        self.subtitle = [hazard.type, hazard.severity].compactMap { $0 }.joined(separator: " • ")
    }

    init(checkin: MHMCheckin) {
        self.id = checkin.id
        self.kind = .checkin
        self.coordinate = checkin.coordinate.clLocation
        self.title = checkin.title
        self.subtitle = checkin.note
    }
}
