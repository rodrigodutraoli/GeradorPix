public struct GeradorPix {
    let version: String
    let key: String
    let city: String
    let name: String
    let value: String?
    let transactionId: String?
    let message: String?
    let cep: String?
    let currency: Int
    let countryCode: String
    
    init(
        version: String = "01",
        key: String,
        city: String,
        name: String,
        value: String?,
        transactionId: String? = "***",
        message: String?,
        cep: String? = nil,
        currency: Int = 986,
        countryCode: String = "BR"
    ){
        self.version = version
        self.key = key
        self.city = city
        self.name = name
        self.value = value
        self.transactionId = transactionId
        self.message = message
        self.cep = cep
        self.currency  = currency
        self.countryCode = countryCode
    }
}

public struct OperacaoPix {
    let version: String
    let key: String
    let city: String
    let name: String
    let value: String?
    let transactionId: String?
    let message: String?
    let cep: String?
    let currency: Int
    let countryCode: String
    
    public init(
        version: String = "01",
        key: String,
        city: String,
        name: String,
        value: String?,
        transactionId: String? = "***",
        message: String?,
        cep: String? = nil,
        currency: Int = 986,
        countryCode: String = "BR"
    ){
        self.version = version
        self.key = key
        self.city = city
        self.name = name
        self.value = value
        self.transactionId = transactionId
        self.message = message
        self.cep = cep
        self.currency  = currency
        self.countryCode = countryCode
    }
    
    public func generatePayloadPix() -> String? {
        let payloadKeyString = generateKey(key: key, message: message)
        
        var payload = [
            genEMV("00", version),
            genEMV("26", payloadKeyString),
            genEMV("52", "0000"),
            genEMV("53", "\(currency)"),
        ]
        
        if let value = value {
            payload.append(genEMV("54", String(format: "%.2f", Float(value)!)));
        }
        
        let name = { () -> String in
            let start = self.name.index(self.name.startIndex, offsetBy: 0)
            let end = self.name.index(self.name.startIndex, offsetBy: self.name.count >= 25 ? 25 : self.name.count)
            let range = start..<end
            return String(self.name[range])
        }().uppercased().decomposedStringWithCanonicalMapping
            .removingRegexMatches(pattern: "[\\u0300-\\u036f]", replaceWith: "")
        
        let city = { () -> String in
            let start = self.city.index(self.city.startIndex, offsetBy: 0)
            let end = self.city.index(self.city.startIndex, offsetBy: self.city.count >= 25 ? 25 : self.city.count)
            let range = start..<end
            return String(self.city[range])
        }().uppercased().decomposedStringWithCanonicalMapping
            .removingRegexMatches(pattern: "[\\u0300-\\u036f]", replaceWith: "")
        
        payload.append(genEMV("58", countryCode.uppercased()))
        payload.append(genEMV("59", name))
        payload.append(genEMV("60", city))
        
        if let cep = cep {
            payload.append(genEMV("61", cep))
        }
        
        if let transactionId = transactionId {
            payload.append(genEMV("62", genEMV("05", transactionId)))
        }
        
        payload.append("6304")
        
        let stringPayload = payload.joined()
        
        if let tData = stringPayload.data(using: .utf8) {
            
            let payloadPIX = "\(stringPayload)\(String(format: "%04X", tData.crc16ccitt()))"
            return payloadPIX
        }
        
        return nil
    }
    
    private func generateKey(key: String, message: String?) -> String {
        var payload = [genEMV("00", "BR.GOV.BCB.PIX"), genEMV("01", key)]
        
        if let message = message {
            payload.append(genEMV("02", message))
        }
        
        return payload.joined()
    }
    
    private func genEMV(_ id: String, _ parameter: String) -> String {
        let len = String(format: "%02d", parameter.count)
        
        return "\(id)\(len)\(parameter)"
    }
    
    
}
