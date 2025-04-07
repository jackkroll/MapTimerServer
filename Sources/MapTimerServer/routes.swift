import Fluent
import Vapor

func routes(_ app: Application) throws {
    let originPubs = Map(name: .KC, availableAt: 1743240600, availableTo: 1743246000)
    let mapSchedulePubs = MapSchedule(origin: originPubs, rotation: [.KC,.SP,.ED])
    let originRanked = Map(name: .SP, availableAt: 1743094800, availableTo: 1743181200)
    let mapScheduleRanked = MapSchedule(origin: originRanked, rotation: [.ED,.KC,.SP])
    
    let aprilFoolsSchedule = MapSchedule(origin: originPubs, rotation: [.KC,.SP,.ED], takeoverName: "April Fools", takeoverSystemImage: "party.popper.fill")
    let powerSwordSchedule = MapSchedule(origin: originPubs, rotation: [.ED,.KC,.SP], takeoverName: "Power Sword")
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
        let hashableContent : String = originPubs.availableAt.description + originRanked.availableAt.description + aprilFoolsSchedule.takeoverName! + powerSwordSchedule.takeoverName!
        return SHA256.hash(data: Data(hashableContent.utf8)).hex
    }
    
    app.get("ranked","schedule") { req -> MapSchedule in
        return mapScheduleRanked
    }
    app.get("ranked","current") { req -> [Map] in
        return mapScheduleRanked.upcomingMaps(at: .now, range: 0...3)
    }
    app.get("ltm", "schedule") { req -> [MapSchedule] in
        return [aprilFoolsSchedule, powerSwordSchedule]
    }
    app.get( "ltm", "current") { req -> [Map] in
        return [aprilFoolsSchedule.determineCurrentMap(at: .now), powerSwordSchedule.determineCurrentMap(at: .now)]
    }
    

    try app.register(collection: TodoController())
}
