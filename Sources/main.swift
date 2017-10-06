import HTTP
import Foundation

struct DateFormatterRequest: Codable {

	let format: String
	let dateString: String

	enum CodingKeys: CodingKey, String {
		case format
		case dateString = "date_string"
	}

}

func dateFormatterHandle(request: HTTPRequest, response: HTTPResponseWriter ) -> HTTPBodyProcessing {
	switch request.method {
	case .options:
		response.writeHeader(
			status: .ok,
			headers: [HTTPHeaders.Name.contentType: "application/json",
			          HTTPHeaders.Name.accessControlAllowOrigin: "*",
			          HTTPHeaders.Name.accessControlAllowHeaders: "Origin, X-Requested-With, Content-Type, Accept"])
		response.done()
		return .discardBody
	case .get:
		response.writeHeader(status: .ok)
		response.writeBody("Hello, World!")
		response.done()
		return .discardBody
	case .post:
		var requestData = Data()
		return .processBody { chunk, stop in
			switch chunk {
			case .chunk(let data, let finishedProcessing):
				for byte in data { requestData.append(byte) }
				finishedProcessing()
			case .end:
				do {
					let dateFormatterRequest = try JSONDecoder().decode(DateFormatterRequest.self, from: requestData)
					var responseDictionary = [String: String]()

					let formatter = DateFormatter()
					formatter.dateFormat = dateFormatterRequest.format

					let dateStringResult = formatter.string(from: Date())
					responseDictionary["date_string"] = dateStringResult

					let date = formatter.date(from: dateFormatterRequest.dateString)
					if let unwrappedDate = date {
						let tempFormatter = DateFormatter()
						tempFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
						let dateString: String? = tempFormatter.string(from: unwrappedDate)
						// 2000-01-01 00:00:00 +0000
						responseDictionary["date_value"] = "\(String(describing: dateString))"
					} else {
						responseDictionary["date_value"] = "nil"
					}
					dump(try JSONEncoder().encode(responseDictionary))
					response.writeHeader(
						status: .ok,
						headers: [HTTPHeaders.Name.contentType: "application/json",
						          HTTPHeaders.Name.accessControlAllowOrigin: "*"])
					response.writeBody(try JSONEncoder().encode(responseDictionary))
				} catch(let error) {
					response.writeHeader(status: .badRequest)
					response.writeBody("\(error)".data(using: .utf8) ?? Data())
				}
				response.done()
			default:
				stop = true
				response.abort()
			}
		}
	default: return .discardBody
	}
}

let server = HTTPServer()
try! server.start(port: 8182, handler: dateFormatterHandle)

RunLoop.current.run()
