import SwiftUI
import MapKit
import CoreLocation

struct MapScreen: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var syncEngine: SyncEngine
    @StateObject private var locationManager = LocationManager()
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 21.0285, longitude: 105.8542)
    @State private var isShowingCheckin = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                MHMMapView(
                    hazards: syncEngine.hazards,
                    checkins: syncEngine.checkins,
                    userCoordinate: locationManager.coordinate,
                    centerCoordinate: $centerCoordinate
                )
                .ignoresSafeArea()

                VStack(spacing: 10) {
                    statusBar
                    actionBar
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 18)
            }
            .navigationTitle("Mule Hazard Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Logout") { authStore.logout() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await syncEngine.sync() }
                    } label: {
                        if syncEngine.isSyncing { ProgressView() } else { Image(systemName: "arrow.clockwise") }
                    }
                }
            }
            .task {
                locationManager.request()
                await syncEngine.sync()
            }
            .onChange(of: locationManager.coordinate?.latitude) { _ in
                if let coordinate = locationManager.coordinate {
                    centerCoordinate = coordinate
                }
            }
            .sheet(isPresented: $isShowingCheckin) {
                CheckinSheet(coordinate: centerCoordinate)
                    .presentationDetents([.medium])
            }
        }
    }

    private var statusBar: some View {
        HStack(spacing: 12) {
            Label("\(syncEngine.hazards.count) hazard", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Label("\(syncEngine.checkins.count) checkin", systemImage: "mappin.circle.fill")
                .foregroundStyle(.orange)
            Spacer()
        }
        .font(.footnote.bold())
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                if let coordinate = locationManager.coordinate {
                    centerCoordinate = coordinate
                } else {
                    locationManager.request()
                }
            } label: {
                Label("Vị trí", systemImage: "location.fill")
            }

            Spacer()

            Button {
                isShowingCheckin = true
            } label: {
                Label("Checkin", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .font(.headline)
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
