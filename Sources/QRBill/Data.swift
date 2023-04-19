import Foundation

public struct Data
{
    let allowedLatinCharacters = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¥§©ª«¬­®¯°±²³µ¶·¹º»¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿŒœŠšŸŽž€"

    public enum Entity {
        case structured(name:String, street:String, streetNr:String, zip:String, city:String, countryCode:String)
        case combined(name:String, streetAndNr:String, zipAndCity:String, countryCode:String)
        case none
        
        var fields:[String] {
            var data = [String]()
            switch self {
            case .structured(let name, let street, let streetNr, let zip, let city, let countryCode):
                data.append("S") // AdrTp
                data.append(name) // Name
                data.append(street) // StrtNmOrAdrLine1
                data.append(streetNr) // BldgNbOrAdrLine2
                data.append(zip) // PstCd
                data.append(city) // TwnNm
                data.append(countryCode) // Ctry
            case .combined(let name, let streetAndNr, let zipAndCity, let countryCode):
                data.append("K") // Cdtr - AdrTp
                data.append(name) // Name
                data.append(streetAndNr) // StrtNmOrAdrLine1
                data.append(zipAndCity) // BldgNbOrAdrLine2
                data.append("") // PstCd
                data.append("") // TwnNm
                data.append(countryCode) // Ctry
            case .none:
                data = ["", "","","","","",""]
            }
            return data
        }
    }

    public enum Reference {
        case qrReference(String)
        case creditorReference(String)
        case none
        
        var fields:[String] {
            var data = [String]()
            switch self {
            case .qrReference(let reference):
                data.append("QRR") // Tp
                data.append(reference) // Ref
            case .creditorReference(let reference):
                data.append("SCOR") // Tp
                data.append(reference) // Ref
            case .none:
                data.append("NON") // Tp
                data.append("") // Ref
            }
            return data
        }
    }
    
    public enum Currency:String {
        var field:String { self.rawValue }
        
        case chf = "CHF"
        case eur = "EUR"
    }

    let iban:String
    let amount:Decimal
    let currency:Currency
    let creditor:Entity
    let ultimateCreditor:Entity
    let debtor:Entity
    let reference:Reference
    let unstructuredMessage:String?

    let amountFormat = Decimal.FormatStyle
        .number
        .decimalSeparator(strategy: .always)
        .grouping(.never)
        .precision(.fractionLength(2))

    
    var qrData:[String] {
        var data = [String]()
        
        // Header
        data.append("SPC") // QRType
        data.append("0200") // Version
        data.append("1") // Coding
        
        // Creditor information
        data.append(iban) // IBAN

        // Creditor
        data.append(contentsOf: creditor.fields) // Cdtr
        
        // Ultimate Creditor
        data.append(contentsOf: ultimateCreditor.fields) // UltmtCdtr

        // Payment amount information
        data.append(amount.formatted(amountFormat)) // Amt
        data.append(currency.field) // Ccy

        // Ultimate Debtor
        data.append(contentsOf: debtor.fields) // UltmtDbtr

        // Payment reference
        data.append(contentsOf: reference.fields) // RmtInf
        
        // Additional information
        data.append(unstructuredMessage ?? "") // Ustrd
        data.append("EPD") // Trailer
        // data.append("") // StrdBkgInf; don't include when empty

        // Alternative schemes
        // data.append("") // AltPmt (1); don't include when empty
        // data.append("") // AltPmt (2); don't include when empty

        return data.map {
            $0.replacingOccurrences(of: "\r\n", with: ", ")
                .replacingOccurrences(of: "\r", with: ", ")
                .replacingOccurrences(of: "\n", with: ", ")
                .filter(allowedLatinCharacters.contains)
        }
    }
    
    public init(iban: String, amount: Decimal, currency: Data.Currency, creditor: Data.Entity, ultimateCreditor: Data.Entity, debtor: Data.Entity, reference: Data.Reference, unstructuredMessage: String?)
    {
        self.iban = iban.replacingOccurrences(of: " ", with: "")
        self.amount = amount
        self.currency = currency
        self.creditor = creditor
        self.ultimateCreditor = ultimateCreditor
        self.debtor = debtor
        self.reference = reference
        self.unstructuredMessage = unstructuredMessage
    }

    func validate() throws
    {
        var error = ValidationError()
        
        if iban.count != 21 {
            error.messages.append("Die IBAN muss ohne Leerschläge genau 21 Zeichen lang sein.")
        }
        
        // TODO: Implement more validation
        
        guard error.messages.count == 0 else {
            throw error
        }
    }
    
    public struct ValidationError : Swift.Error
    {
        var messages = [String]()
    }
}
