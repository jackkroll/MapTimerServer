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
    
    app.get("hash") { req async -> String in
        //add ltm to hash later :)
        let hashableContent : String = originPubs.availableAt.description + originRanked.availableAt.description
        return SHA256.hash(data: Data(hashableContent.utf8)).hex
    }
    
    app.get("ranked","schedule") { req -> MapSchedule in
        return mapScheduleRanked
    }
    app.get("ranked","current") { req -> [Map] in
        return mapScheduleRanked.upcomingMaps(at: .now, range: 0...3)
    }
    

    try app.register(collection: TodoController())
}
