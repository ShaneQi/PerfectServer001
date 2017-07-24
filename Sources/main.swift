import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

let server = HTTPServer()

var routes = Routes()

routes.add(method: .post, uri: "/upload", handler: {
    request, response in 
		if let uploads = request.postFileUploads,
			let file = uploads.first?.file,
			let fileName = uploads.first?.fileName {
      do {
        let _ = try file.moveTo(path: "./upload/\(fileName)", overWrite: true)
      } catch {}
		}

		response.completed()
		
  }
)

routes.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		response.completed()
	}
)

routes.add(method: .post, uri: "/dateformatter", handler: {
	request, response in

	response.status = HTTPResponseStatus.statusFrom(code: 400)
	response.setHeader(.contentType, value: "application/json")
	let bodyString = request.postBodyString ?? ""

	do {
		let bodyObject = try bodyString.jsonDecode()
		if let bodyDictionary = bodyObject as? [String: Any], 
				let format = bodyDictionary["format"] as? String,
				let dateString = bodyDictionary["date_string"] as? String
			{
				var responseDictionary = [String: Any]()

				let formatter = DateFormatter()
				formatter.dateFormat = format
				
				let dateStringResult = formatter.string(from: Date())
				responseDictionary["date_string"] = dateStringResult

				let date = formatter.date(from: dateString)
				if let unwrappedDate = date {
					let tempFormatter = DateFormatter()
					tempFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
					let dateString: String? = tempFormatter.string(from: unwrappedDate)
					// 2000-01-01 00:00:00 +0000	
					responseDictionary["date_value"] = "\(String(describing: dateString))"
				} else {
					responseDictionary["date_value"] = "nil"
				}

				let responseString = try responseDictionary.jsonEncodedString()
				response.status = HTTPResponseStatus.ok
				response.appendBody(string: responseString)
				response.completed()
			 
			} else {
					response.completed()
			}
	} catch {
		response.completed()
	}
})

server.addRoutes(routes)
server.serverPort = 8182

do {
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
