import SwiftUI
import QRBill

@main
struct TestApp: App
{
    @State public var data = QRBill.Data(
        iban: "CH00 1234 5678 9012 3456 7",
        amount: 123.45,
        currency: .chf,
        creditor: .structured(name: "Jöhn Doe", street: "Towñroad", streetNr: "10", zip: "8765", city: "Littletown", countryCode: "CH"),
        ultimateCreditor: .none,
        debtor: .structured(name: "Jane Doé", street: "Broadway", streetNr: "1", zip: "1234", city: "New Townish", countryCode: "CH"),
        reference: .none,
        unstructuredMessage: "Purchase 12345678"
    )
    @State var qrCode:NSImage?

    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    class AppDelegate: NSObject, NSApplicationDelegate
    {
        func applicationDidFinishLaunching(_ notification: Notification)
        {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    #endif

    var body: some Scene {
        WindowGroup {
            Group {
                if let image = qrCode {
                    Image(nsImage: image)
                        .resizable()
                        .antialiased(false)
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .border(Color.black)
                        .padding()
                } else {
                    ProgressView("Erstelle QR-Code...")
                        .frame(alignment: .center)
                }
            }
            .frame(minWidth: 500, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            .background(Color.white)
            .toolbar {
                ToolbarItem {
                    Button("Regenerate", action: clear)
                        .disabled(qrCode == nil)
                }
                ToolbarItem {
                    Button("Save as SVG", action: exportSVG)
                        .disabled(qrCode == nil)
                }
                ToolbarItem {
                    Button("Save as PNG", action: exportPNG)
                        .disabled(qrCode == nil)
                }
            }
            .onAppear(perform: createQRCode)
        }
    }
    
    func createQRCode()
    {
        guard qrCode == nil else { return }
        qrCode = try! BillCodeGenerator.createImage(from: data)
    }
    
    func clear()
    {
        qrCode = nil
        createQRCode()
    }

    func exportPNG()
    {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "qrcode.png"
        savePanel.allowedContentTypes = [.png]
        savePanel.begin { result in
            if result == .OK,
               let url = savePanel.url,
               let image = qrCode,
               let ciImageRepresentation = image.representations.first as? NSCIImageRep,
               let pngData = NSBitmapImageRep(ciImage: ciImageRepresentation.ciImage).representation(using: .png, properties: [:])
            {
                try? pngData.write(to: url)
            }
        }
        #endif
    }

    func exportSVG()
    {
        #if os(macOS)
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "qrcode.svg"
        savePanel.allowedContentTypes = [.svg]
        savePanel.begin { result in
            if result == .OK,
               let url = savePanel.url,
               let svgString = try? BillCodeGenerator.createSVGString(from: data),
                let data = svgString.data(using: .utf8)
            {
                try? data.write(to: url)
            }
        }
        #endif
    }
}
