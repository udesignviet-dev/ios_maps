import SwiftUI
import CoreLocation

struct CheckinSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var syncEngine: SyncEngine
    let coordinate: CLLocationCoordinate2D

    @State private var title = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin checkin") {
                    TextField("Tiêu đề", text: $title)
                    TextField("Ghi chú", text: $note, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Tọa độ") {
                    Text("Lat: \(coordinate.latitude, specifier: "%.6f")")
                    Text("Lng: \(coordinate.longitude, specifier: "%.6f")")
                }
            }
            .navigationTitle("Tạo checkin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        Task {
                            await syncEngine.createCheckin(
                                title: title.isEmpty ? "Checkin" : title,
                                note: note.isEmpty ? nil : note,
                                coordinate: coordinate
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
