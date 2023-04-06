# QRBill

Generate QR codes compatible with the Swiss "QR-Rechnung" in Swift.  
Run the target `QRBillTestApp` to see it in action.

# Supported platforms

Works on macOS and iOS.

# State and compatibility

* ⚠️ Limited testing
* ⚠️ No guarantees whatsoever
* ⚠️ Does not include the Swiss flag in the center
* Seems to work for some very specific use-cases.

# Usage

### Specify the dependendy


In Package.swift:

```swift
// in your package:
dependencies: [
    .package(url: "https://github.com/andreasley/QRBill.git", branch: "master")
]

// in your target:
dependencies: [
    .product(name: "QRBill", package: "QRBill")
]),

```
In Xcode:
[Adding package dependencies to your app](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)


### Import the module

```swift
import QRBill
```

### Prepare the data

```swift
let data = QRBill.Data(
    iban: "CH00 1234 5678 9012 3456 7",
    amount: 123.45,
    currency: .chf,
    creditor: .structured(name: "Jöhn Doe", street: "Towñroad", streetNr: "10", zip: "8765", city: "Littletown", countryCode: "CH"),
    ultimateCreditor: .none,
    debtor: .structured(name: "Jane Doé", street: "Broadway", streetNr: "1", zip: "1234", city: "New Townish", countryCode: "CH"),
    reference: .none,
    unstructuredMessage: "Purchase 12345678"
)

```

### Generate QR code

```swift
// Bitmap
let image = try BillCodeGenerator.createImage(from: data)

// Vectorized
let svgString = try BillCodeGenerator.createSVGString(from: data)
```
