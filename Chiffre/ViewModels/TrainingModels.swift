import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case number      = "Chiffres (数字)"
    case phoneNumber = "Tél (电话)"
    case price       = "Prix (价格)"
    case time        = "Heure (时间)"
    case year        = "Année (年份)"
    case month       = "Mois (月份)"
    case trainNumber = "Train (火车号)"
    case flightNumber = "Vol (航班号)"
    case address     = "Adresse (地址)"
    case reservation = "Réservation (预约)"
    case cafeOrder   = "Commande (点单)"
    case directions  = "Trajet (问路)"
    case smallTalk   = "Conversation (寒暄)"
    case service     = "Service (生活)"
    case shopping    = "Courses (购物)"
    case transport   = "Transports (出行)"
    case health      = "Santé (健康)"
    case workday     = "Travail (工作)"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .number:       return "number"
        case .phoneNumber:  return "phone.fill"
        case .price:        return "eurosign.circle.fill"
        case .time:         return "clock.fill"
        case .year:         return "calendar"
        case .month:        return "calendar.circle.fill"
        case .trainNumber:  return "tram.fill"
        case .flightNumber: return "airplane"
        case .address:      return "map.fill"
        case .reservation:  return "bookmark.circle.fill"
        case .cafeOrder:    return "cup.and.saucer.fill"
        case .directions:   return "location.north.line.fill"
        case .smallTalk:    return "message.fill"
        case .service:      return "bell.badge.fill"
        case .shopping:     return "bag.fill"
        case .transport:    return "bus.fill"
        case .health:       return "cross.case.fill"
        case .workday:      return "briefcase.fill"
        }
    }

    var summary: String {
        switch self {
        case .number:       return "基础数字与口头报数"
        case .phoneNumber:  return "联系电话与号码分组"
        case .price:        return "价格、金额与付款表达"
        case .time:         return "时间、约会与开门时段"
        case .year:         return "年份、年代与历史时间点"
        case .month:        return "日期、月份与日程安排"
        case .trainNumber:  return "列车编号与站台广播"
        case .flightNumber: return "航班号与登机广播"
        case .address:      return "门牌、楼层与地址信息"
        case .reservation:  return "订位、人数与预约时间"
        case .cafeOrder:    return "咖啡馆点单与日常购买"
        case .directions:   return "问路、转弯与距离表达"
        case .smallTalk:    return "寒暄、近况与轻社交"
        case .service:      return "药店、商店与生活服务"
        case .shopping:     return "超市、尺码与结账对话"
        case .transport:    return "地铁、公交与出租出行"
        case .health:       return "症状、药品与就诊沟通"
        case .workday:      return "会议、同事与工作安排"
        }
    }

    var isRangeConfigurable: Bool {
        self == .number
    }

    var isScenarioBased: Bool {
        switch self {
        case .address, .reservation, .cafeOrder, .directions, .smallTalk, .service, .shopping, .transport, .health, .workday:
            return true
        default:
            return false
        }
    }
}

struct ListeningScenario {
    let display: String
    let speakable: String
    let sentence: String
    let annotation: String
}

enum AnswerState: Equatable {
    case waiting
    case revealed
    case correct
    case wrong
}

enum HintStage: Int {
    case none
    case replayFull
    case replayFocused
    case structure
    case scaffold
    case partialReveal
    case fullReveal
}

struct TrainingSettings {
    var mode: GameMode
    var maxRange: Int
    var playbackRate: Double

    var currentRate: Float {
        Float(playbackRate)
    }

    var speedLevel: Int {
        switch playbackRate {
        case ..<0.45: return 1
        case ..<0.53: return 2
        case ..<0.61: return 3
        default: return 4
        }
    }

    var speedLabel: String {
        switch playbackRate {
        case ..<0.45: return "慢速"
        case ..<0.53: return "适中"
        case ..<0.61: return "较快"
        default: return "自然"
        }
    }
}

struct Exercise {
    let display: String
    let speakable: String
    let sentence: String
    let annotation: String
}
