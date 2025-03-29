import Fluent
import Vapor

func routes(_ app: Application) throws {
    let originPubs = Map(name: .KC, availableAt: 1743240600, availableTo: 1743246000)
    let mapSchedulePubs = MapSchedule(origin: originPubs, rotation: [.ED,.KC,.SP])
    let originRanked = Map(name: .KC, availableAt: 1743094800, availableTo: 1743181200)
    let mapScheduleRanked = MapSchedule(origin: originRanked, rotation: [.ED,.KC,.SP])
    //add season start/end date protections
    
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    app.get("routes") { req async -> String in
        return (app.routes.all).description
    }
    
    app.get("pubs", "schedule") { req -> MapSchedule in
        return mapSchedulePubs
    }
    app.get("pubs","current") { req -> [Map] in
        return mapSchedulePubs.upcomingMaps(at: .now, range: 0...3)
    }
    /*
    app.get("pubs", "at", ":date") { req -> Map in
        guard let dateTime = req.parameters.get("date", as: Double.self) else {
                throw Abort(.badRequest)
            }
        let date = Date.init(timeIntervalSince1970: dateTime)
        return mapSchedulePubs.determineCurrentMap(at: date)
    }
    */
        
    
    app.get("ranked","schedule") { req -> MapSchedule in
        return mapScheduleRanked
    }
    app.get("ranked","current") { req -> [Map] in
        return mapScheduleRanked.upcomingMaps(at: .now, range: 0...3)
    }
    

    try app.register(collection: TodoController())
}
