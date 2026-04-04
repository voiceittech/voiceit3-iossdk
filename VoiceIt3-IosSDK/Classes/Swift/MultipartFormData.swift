import Foundation
import UniformTypeIdentifiers

/// Builder for multipart/form-data HTTP request bodies
struct MultipartFormData {
    let boundary: String
    private var body = Data()

    init(boundary: String? = nil) {
        self.boundary = boundary ?? "Boundary-\(UUID().uuidString)"
    }

    var contentType: String {
        "multipart/form-data; charset=utf-8; boundary=\(boundary)"
    }

    // MARK: - Add Parameters

    mutating func addField(name: String, value: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        body.append("\(value)\r\n")
    }

    mutating func addFields(_ params: [String: String]) {
        for (key, value) in params {
            addField(name: key, value: value)
        }
    }

    // MARK: - Add Files

    mutating func addFile(name: String, filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: url) else { return }
        let filename = url.lastPathComponent
        let mimeType = Self.mimeType(for: url.pathExtension)

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    mutating func addFileData(name: String, data: Data, filename: String, mimeType: String) {
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
    }

    mutating func addImageData(name: String, data: Data) {
        addFileData(name: name, data: data, filename: "frame.jpg", mimeType: "image/jpeg")
    }

    // MARK: - Finalize

    func finalize() -> Data {
        var result = body
        result.append("--\(boundary)--\r\n")
        return result
    }

    // MARK: - MIME Type

    static func mimeType(for pathExtension: String) -> String {
        if let utType = UTType(filenameExtension: pathExtension),
           let mimeType = utType.preferredMIMEType {
            return mimeType
        }
        return "application/octet-stream"
    }
}

// MARK: - Data + String Append

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
