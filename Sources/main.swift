import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

let server = HTTPServer()

var routes = Routes()

routes.add(method: .get, uri: "/", handler: {
		request, response in
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		response.completed()
	}
)

routes.add(method: .post, uri: "/stringfromdate", handler: {
	request, response in

	response.status = HTTPResponseStatus.statusFrom(code: 400)
	response.setHeader(.contentType, value: "application/json")
	let bodyString = request.postBodyString ?? ""

	do {
		let bodyObject = try bodyString.jsonDecode()
		if let bodyDictionary = bodyObject as? [String: Any], 
				let format = bodyDictionary["format"] as? String
			{
				var responseDictionary = [String: Any]()

				let formatter = DateFormatter()
				formatter.dateFormat = format
				
				let dateString = formatter.string(from: Date())
				responseDictionary["date_string"] = dateString

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

routes.add(method: .post, uri: "/datefromstring", handler: {
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
				
				let date = formatter.date(from: dateString)
				if let unwrappedDate = date {
					let tempDateFormatter = DateFormatter()
					tempDateFormatter.dateFormat = "MMM d, yyyy, hh:mm aa"
					let dateString = tempDateFormatter.string(from: unwrappedDate)
					responseDictionary["date_string"] = dateString
				} else {
					responseDictionary["date_string"] = date
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
server.serverPort = 8181

configureServer(server)

do {
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
