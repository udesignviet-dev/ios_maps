import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authStore: AuthStore
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Mule Hazard Map")
                        .font(.largeTitle.bold())
                    Text("Đăng nhập bằng tài khoản website để đồng bộ dữ liệu.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    TextField("Username hoặc email", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    SecureField("Mật khẩu", text: $password)
                        .textContentType(.password)
                        .padding(14)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if let message = authStore.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await authStore.login(username: username, password: password) }
                } label: {
                    HStack {
                        if authStore.isBusy { ProgressView().tint(.white) }
                        Text("Đăng nhập")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(username.isEmpty || password.isEmpty || authStore.isBusy)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Đăng nhập")
        }
    }
}
