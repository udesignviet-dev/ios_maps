# Mule Hazard Map iOS

Đây là project Xcode SwiftUI đã được đóng gói lại từ bộ source ban đầu.

## Quan trọng về Appetize / website test iOS

Website test iOS không nhận source code. Appetize cần một trong hai dạng sau:

- `.zip` chứa thư mục `MuleHazardMap.app` đã build cho iOS Simulator
- `.ipa` đã build/archive cho thiết bị thật

File zip này là **project Xcode**, chưa phải `.app` vì cần macOS + Xcode/iOS SDK để compile.

## Cách build file `.app` để upload Appetize

1. Mở `MuleHazardMap.xcodeproj` bằng Xcode trên Mac.
2. Sửa `Config/Config.xcconfig`:
   - `MHM_API_BASE_URL`
   - `GOONG_API_KEY`
   - `PRODUCT_BUNDLE_IDENTIFIER`
3. Chọn scheme `MuleHazardMap`.
4. Chọn một iPhone Simulator.
5. Bấm Run hoặc Build.
6. Lấy app trong DerivedData, thường nằm ở:

```text
~/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug-iphonesimulator/MuleHazardMap.app
```

7. Nén đúng thư mục `.app`:

```bash
cd ~/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug-iphonesimulator
zip -r MuleHazardMap-appetize.zip MuleHazardMap.app
```

8. Upload `MuleHazardMap-appetize.zip` lên Appetize.

## Sửa lỗi đã thực hiện

- Thêm `MuleHazardMap.xcodeproj`.
- Thêm `Config/Config.xcconfig`.
- Bổ sung các key bắt buộc trong `Info.plist`.
- Sửa API SwiftUI iOS 17 về tương thích iOS 16.
- Thêm import `Combine` cho các `ObservableObject`.
- Thêm import `UIKit` cho phần dùng `UIImage`.

## Build bằng GitHub Actions trên Windows

Project đã có sẵn workflow `.github/workflows/build-ios-simulator.yml`.

Sau khi upload project lên GitHub:

1. Vào tab **Actions**.
2. Chọn **Build iOS Simulator App**.
3. Bấm **Run workflow**.
4. Khi workflow chạy xong, tải artifact **MuleHazardMap-appetize**.
5. Giải nén artifact để lấy `MuleHazardMap-appetize.zip`.
6. Upload file zip đó lên Appetize.

Lưu ý: `Config/Config.xcconfig` đang dùng giá trị mẫu. Nếu muốn app kết nối website thật, hãy sửa `MHM_API_BASE_URL` và `GOONG_API_KEY` trước khi build. Không đưa API key thật lên repo public.
