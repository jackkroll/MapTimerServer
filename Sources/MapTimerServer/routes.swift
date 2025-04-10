import Fluent
import Vapor

func routes(_ app: Application) throws {
    let originPubs = Map(name: .KC, availableAt: 1743240600, availableTo: 1743246000)
    let mapSchedulePubs = MapSchedule(origin: originPubs, rotation: [.KC,.SP,.ED])
    let originRanked = Map(name: .SP, availableAt: 1743094800, availableTo: 1743181200)
    let mapScheduleRanked = MapSchedule(origin: originRanked, rotation: [.ED,.KC,.SP])
    
    let solosSchedule = MapSchedule(origin: originPubs, rotation: [.KC,.SP,.ED], takeoverName: "Solos", takeoverSystemImage: "person.fill")
    let powerSwordSchedule = MapSchedule(origin: originPubs, rotation: [.ED,.KC,.SP], takeoverName: "Power Sword")
    
    let beastModeEvent = ModeSchedule(schedules:[PublishableSchedule(schedule: powerSwordSchedule, usable: DateInterval(start: Date(timeIntervalSince1970: 1744131600), end: Date(timeIntervalSince1970: 1744736400)))])
    let creatorEvent = ModeSchedule(schedules: [PublishableSchedule( schedule: solosSchedule, usable: DateInterval(start: Date(timeIntervalSince1970: 1742922000), end: Date(timeIntervalSince1970: 1744736400)))])
    
    let epgExtreme = MapSchedule(origin: originPubs, rotation: [.KC,.SP,.ED], takeoverName: "EPG Extreme", takeoverSystemImage: "exclamationmark.shield.fill")
    let straightShotQuads = MapSchedule(origin: originPubs, rotation: [.KC,.SP,.ED], takeoverName: "Straight Shot Quads", takeoverSystemImage: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
    
    let fightForeceEvent = ModeSchedule(schedules: [PublishableSchedule( schedule: epgExtreme, usable: DateInterval(start: Date(timeIntervalSince1970: 1744736400), end: Date(timeIntervalSince1970: 1745946000))),
                                                   PublishableSchedule(schedule: straightShotQuads, usable: DateInterval(start: Date(timeIntervalSince1970: 1745946000), end: Date(timeIntervalSince1970: 1746464400)))])
    
    
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
        let hashableContent : String = originPubs.availableAt.description + originRanked.availableAt.description + beastModeEvent.hashString() + creatorEvent.hashString()
        return SHA256.hash(data: Data(hashableContent.utf8)).hex
    }
    
    app.get("ranked","schedule") { req -> MapSchedule in
        return mapScheduleRanked
    }
    app.get("ranked","current") { req -> [Map] in
        return mapScheduleRanked.upcomingMaps(at: .now, range: 0...3)
    }
    app.get("ltm", "schedule") { req -> [MapSchedule] in
        var schedules : [MapSchedule] = []
        let beastMode = beastModeEvent.currentSchedule(at: .now)
        let creatorEvent = creatorEvent.currentSchedule(at: .now)
        let fightForceEvent = fightForeceEvent.currentSchedule(at: .now)
        if beastMode != nil {
            schedules.append(beastMode!)
        }
        if creatorEvent != nil {
            schedules.append(creatorEvent!)
        }
        if fightForceEvent != nil {
            schedules.append(fightForceEvent!)
        }
        return schedules
    }
    app.get( "ltm", "current") { req -> [Map] in
        var schedules : [Map] = []
        let beastMode = beastModeEvent.currentSchedule(at: .now)
        let creatorEvent = creatorEvent.currentSchedule(at: .now)
        let fightForceEvent = fightForeceEvent.currentSchedule(at: .now)
        if beastMode != nil {
            schedules.append(beastMode!.determineCurrentMap(at: .now))
        }
        if creatorEvent != nil {
            schedules.append(creatorEvent!.determineCurrentMap(at: .now))
        }
        if fightForceEvent != nil {
            schedules.append(fightForceEvent!.determineCurrentMap(at: .now))
        }
        return schedules
    }
    

    try app.register(collection: TodoController())
}
