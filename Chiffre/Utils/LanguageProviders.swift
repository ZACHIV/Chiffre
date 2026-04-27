import Foundation

// MARK: - 语言数据提供者协议
protocol LanguageDataProvider {
    var months: [(name: String, days: Int)] { get }
    var trainTypes: [String] { get }
    var airlines: [(code: String, fullName: String)] { get }
    func formatPhonePrefix() -> String
    func formatPrice(euro: Int, cent: Int) -> (display: String, speakable: String)
    func formatTime(hour: Int, minute: Int) -> (display: String, speakable: String)
    func formatMonth(day: Int, month: String) -> (display: String, speakable: String)
    func sentenceTemplate(for mode: GameMode) -> String
    func scenarioPrompt(for mode: GameMode) -> ListeningScenario?
    func structureHint(for mode: GameMode) -> String

    var successText: String { get }
    var listenText: String { get }
    var nextText: String { get }
    var revealText: String { get }
    var inputPlaceholder: String { get }
    var wrongAnswerPrefix: String { get }
    var appName: String { get }
    // 口语练习界面
    var speakTapHint: String { get }
    var speakIdlePrompt: String { get }
    var speakListeningPrompt: String { get }
    var speakCorrectPrompt: String { get }
    var speakWrongPrompt: String { get }
    var showTextLabel: String { get }
    var hideTextLabel: String { get }
    var skipLabel: String { get }
    var emptyInputPrompt: String { get }
    var hintStartText: String { get }
    var hintFocusReplayText: String { get }
    var hintStructureText: String { get }
    var hintScaffoldText: String { get }
    var hintPartialRevealText: String { get }
    var hintShowAnswerText: String { get }
    var hintDoneText: String { get }
    var hintReplayFullMessage: String { get }
    var hintReplayFocusedMessage: String { get }
    var hintScaffoldMessage: String { get }
    var hintPartialRevealMessage: String { get }
    var hintShowAnswerMessage: String { get }
    var gentleWrongText: String { get }
}

// MARK: - 法语数据提供者
struct FrenchDataProvider: LanguageDataProvider {
    let months: [(name: String, days: Int)] = [
        ("janvier", 31), ("février", 28), ("mars", 31), ("avril", 30),
        ("mai", 31), ("juin", 30), ("juillet", 31), ("août", 31),
        ("septembre", 30), ("octobre", 31), ("novembre", 30), ("décembre", 31)
    ]
    
    let trainTypes = ["TGV", "Intercités", "TER"]
    
    let airlines: [(code: String, fullName: String)] = [
        ("AF", "Air France"),
        ("EK", "Emirates"),
        ("BA", "British Airways"),
        ("LH", "Lufthansa"),
        ("KL", "KLM")
    ]
    
    func formatPhonePrefix() -> String {
        Bool.random() ? "06" : "07"
    }
    
    func formatPrice(euro: Int, cent: Int) -> (display: String, speakable: String) {
        let display = String(format: "%d,%02d €", euro, cent)
        let speakable = cent == 0 ? "\(euro) euros" : "\(euro) euros \(cent)"
        return (display, speakable)
    }
    
    func formatTime(hour: Int, minute: Int) -> (display: String, speakable: String) {
        let display = String(format: "%02dh%02d", hour, minute)
        let speakable: String
        if minute == 0 {
            speakable = "\(hour) heures pile"
        } else if minute == 30 {
            speakable = "\(hour) heures et demie"
        } else {
            speakable = "\(hour) heures \(minute)"
        }
        return (display, speakable)
    }
    
    func formatMonth(day: Int, month: String) -> (display: String, speakable: String) {
        let display = "le \(day) \(month)"
        let speakable = day == 1 ? "le premier \(month)" : "le \(day) \(month)"
        return (display, speakable)
    }
    
    func sentenceTemplate(for mode: GameMode) -> String {
        let templates: [GameMode: [String]] = [
            .number:       ["Il y a {X} personnes.", "Chambre numéro {X}.", "Le code est le {X}.", "Composez le {X}."],
            .phoneNumber:  ["Appelez le {X}.", "Son numéro est le {X}.", "Enregistrez le {X}."],
            .price:        ["Ça fait {X}, s'il vous plaît.", "Le ticket coûte {X}.", "Votre total est de {X}."],
            .time:         ["Le prochain train part à {X}.", "Le rendez-vous est à {X}.", "Le film commence à {X}."],
            .year:         ["Il est né en {X}.", "Ça s'est passé en {X}.", "Cette œuvre date de {X}."],
            .month:        ["La réunion est prévue {X}.", "Nous partons {X}.", "Le colis arrive {X}."],
            .trainNumber:  ["Votre train est le {X}.", "Prenez le {X}, quai cinq.", "Le {X} est retardé."],
            .flightNumber: ["Votre vol est le {X}.", "L'embarquement du vol {X} commence.", "Le vol {X} est annoncé."],
            .address:      ["L'adresse est {X}.", "Le rendez-vous est à {X}.", "On se retrouve au {X}."],
            .reservation:  ["La réservation est {X}.", "C'est noté : {X}.", "Votre créneau, c'est {X}."],
            .cafeOrder:    ["Je prends {X}.", "Pour moi, ce sera {X}.", "On a commandé {X}."],
            .directions:   ["Pour y aller, {X}.", "L'itinéraire est simple : {X}.", "On vous indique que {X}."],
            .smallTalk:    ["Il me dit que {X}.", "Dans la conversation, on entend : {X}.", "La phrase du jour, c'est {X}."],
            .service:      ["Le message dit : {X}.", "L'information utile, c'est {X}.", "On vous annonce que {X}."],
            .shopping:     ["Au magasin, on entend : {X}.", "Pendant les courses, quelqu'un dit : {X}.", "À la caisse, on vous demande : {X}."],
            .transport:    ["Dans les transports, on annonce : {X}.", "Le chauffeur précise : {X}.", "En route, on entend : {X}."],
            .health:       ["À la pharmacie, on vous dit : {X}.", "Le médecin demande : {X}.", "Pendant la consultation, on entend : {X}."],
            .workday:      ["Au bureau, on entend : {X}.", "Pendant la réunion, quelqu'un dit : {X}.", "Au travail, on vous rappelle : {X}."],
        ]
        return templates[mode]?.randomElement() ?? "{X}"
    }

    func scenarioPrompt(for mode: GameMode) -> ListeningScenario? {
        switch mode {
        case .address:
            return [
                ListeningScenario(
                    display: "douze rue du Bac",
                    speakable: "douze rue du Bac",
                    sentence: "Le rendez-vous est au douze rue du Bac, au troisième étage.",
                    annotation: "地址与楼层"
                ),
                ListeningScenario(
                    display: "quarante-huit avenue Victor Hugo",
                    speakable: "quarante-huit avenue Victor Hugo",
                    sentence: "Le taxi vous dépose au quarante-huit avenue Victor Hugo, juste devant l'entrée.",
                    annotation: "门牌与街道"
                ),
                ListeningScenario(
                    display: "bâtiment B, porte six",
                    speakable: "bâtiment B, porte six",
                    sentence: "La livraison est pour le bâtiment B, porte six.",
                    annotation: "楼栋与门牌"
                )
            ].randomElement()

        case .reservation:
            return [
                ListeningScenario(
                    display: "une table pour deux à dix-neuf heures trente",
                    speakable: "une table pour deux à dix-neuf heures trente",
                    sentence: "J'ai une réservation pour une table pour deux à dix-neuf heures trente.",
                    annotation: "订位与时间"
                ),
                ListeningScenario(
                    display: "un rendez-vous mardi matin à neuf heures",
                    speakable: "un rendez-vous mardi matin à neuf heures",
                    sentence: "On vous confirme un rendez-vous mardi matin à neuf heures.",
                    annotation: "预约确认"
                ),
                ListeningScenario(
                    display: "quatre places au nom de Martin",
                    speakable: "quatre places au nom de Martin",
                    sentence: "La réservation est pour quatre places au nom de Martin.",
                    annotation: "人数与姓名"
                )
            ].randomElement()

        case .cafeOrder:
            return [
                ListeningScenario(
                    display: "deux cafés allongés et un croissant",
                    speakable: "deux cafés allongés et un croissant",
                    sentence: "Au comptoir, elle commande deux cafés allongés et un croissant.",
                    annotation: "咖啡馆点单"
                ),
                ListeningScenario(
                    display: "un sandwich jambon-beurre sans tomate",
                    speakable: "un sandwich jambon-beurre sans tomate",
                    sentence: "Pour le déjeuner, il prend un sandwich jambon-beurre sans tomate.",
                    annotation: "午餐点单"
                ),
                ListeningScenario(
                    display: "une bouteille d'eau gazeuse",
                    speakable: "une bouteille d'eau gazeuse",
                    sentence: "À la fin, elle ajoute une bouteille d'eau gazeuse.",
                    annotation: "追加购买"
                )
            ].randomElement()

        case .directions:
            return [
                ListeningScenario(
                    display: "tournez à gauche après la boulangerie",
                    speakable: "tournez à gauche après la boulangerie",
                    sentence: "Pour aller à la gare, tournez à gauche après la boulangerie.",
                    annotation: "方位与转弯"
                ),
                ListeningScenario(
                    display: "c'est à deux rues d'ici",
                    speakable: "c'est à deux rues d'ici",
                    sentence: "Ne vous inquiétez pas, c'est à deux rues d'ici.",
                    annotation: "距离表达"
                ),
                ListeningScenario(
                    display: "prenez la sortie côté rivière",
                    speakable: "prenez la sortie côté rivière",
                    sentence: "À la station, prenez la sortie côté rivière.",
                    annotation: "交通引导"
                )
            ].randomElement()

        case .smallTalk:
            return [
                ListeningScenario(
                    display: "ça fait longtemps, comment tu vas",
                    speakable: "ça fait longtemps, comment tu vas",
                    sentence: "Dans la rue, on entend : ça fait longtemps, comment tu vas ?",
                    annotation: "日常寒暄"
                ),
                ListeningScenario(
                    display: "tu travailles encore dans le même quartier",
                    speakable: "tu travailles encore dans le même quartier",
                    sentence: "Pendant la conversation, elle demande : tu travailles encore dans le même quartier ?",
                    annotation: "近况聊天"
                ),
                ListeningScenario(
                    display: "on se voit ce week-end si tu es libre",
                    speakable: "on se voit ce week-end si tu es libre",
                    sentence: "Avant de partir, il dit : on se voit ce week-end si tu es libre.",
                    annotation: "邀约口语"
                )
            ].randomElement()

        case .service:
            return [
                ListeningScenario(
                    display: "la pharmacie ferme à dix-neuf heures ce soir",
                    speakable: "la pharmacie ferme à dix-neuf heures ce soir",
                    sentence: "Sur la porte, on lit : la pharmacie ferme à dix-neuf heures ce soir.",
                    annotation: "营业时间"
                ),
                ListeningScenario(
                    display: "votre colis sera livré demain avant midi",
                    speakable: "votre colis sera livré demain avant midi",
                    sentence: "Le message du service indique : votre colis sera livré demain avant midi.",
                    annotation: "配送通知"
                ),
                ListeningScenario(
                    display: "le paiement sans contact est accepté",
                    speakable: "le paiement sans contact est accepté",
                    sentence: "À la caisse, on vous précise que le paiement sans contact est accepté.",
                    annotation: "店内服务"
                )
            ].randomElement()

        case .shopping:
            return [
                ListeningScenario(
                    display: "je cherche la taille trente-huit en beige",
                    speakable: "je cherche la taille trente-huit en beige",
                    sentence: "Dans la boutique, elle dit : je cherche la taille trente-huit en beige.",
                    annotation: "尺码与颜色"
                ),
                ListeningScenario(
                    display: "vous pouvez mettre les tomates à part",
                    speakable: "vous pouvez mettre les tomates à part",
                    sentence: "Au marché, il demande : vous pouvez mettre les tomates à part ?",
                    annotation: "买菜沟通"
                ),
                ListeningScenario(
                    display: "je paie par carte mais je garde le ticket",
                    speakable: "je paie par carte mais je garde le ticket",
                    sentence: "À la caisse, elle précise : je paie par carte mais je garde le ticket.",
                    annotation: "结账表达"
                )
            ].randomElement()

        case .transport:
            return [
                ListeningScenario(
                    display: "le bus passe toutes les dix minutes",
                    speakable: "le bus passe toutes les dix minutes",
                    sentence: "À l'arrêt, on annonce que le bus passe toutes les dix minutes.",
                    annotation: "公交频次"
                ),
                ListeningScenario(
                    display: "changez à la prochaine station pour la ligne trois",
                    speakable: "changez à la prochaine station pour la ligne trois",
                    sentence: "Dans le métro, on vous dit : changez à la prochaine station pour la ligne trois.",
                    annotation: "换乘提示"
                ),
                ListeningScenario(
                    display: "le taxi vous attend à la sortie principale",
                    speakable: "le taxi vous attend à la sortie principale",
                    sentence: "À l'arrivée, le message précise : le taxi vous attend à la sortie principale.",
                    annotation: "接送信息"
                )
            ].randomElement()

        case .health:
            return [
                ListeningScenario(
                    display: "prenez ce sirop deux fois par jour après le repas",
                    speakable: "prenez ce sirop deux fois par jour après le repas",
                    sentence: "À la pharmacie, on vous conseille : prenez ce sirop deux fois par jour après le repas.",
                    annotation: "用药说明"
                ),
                ListeningScenario(
                    display: "j'ai mal à la gorge depuis hier soir",
                    speakable: "j'ai mal à la gorge depuis hier soir",
                    sentence: "Pendant la consultation, elle explique : j'ai mal à la gorge depuis hier soir.",
                    annotation: "症状表达"
                ),
                ListeningScenario(
                    display: "revenez si la fièvre continue demain",
                    speakable: "revenez si la fièvre continue demain",
                    sentence: "Le médecin ajoute : revenez si la fièvre continue demain.",
                    annotation: "复诊建议"
                )
            ].randomElement()

        case .workday:
            return [
                ListeningScenario(
                    display: "la réunion commence à neuf heures dans la salle B",
                    speakable: "la réunion commence à neuf heures dans la salle B",
                    sentence: "Au bureau, on rappelle que la réunion commence à neuf heures dans la salle B.",
                    annotation: "会议安排"
                ),
                ListeningScenario(
                    display: "je t'envoie le dossier avant la pause déjeuner",
                    speakable: "je t'envoie le dossier avant la pause déjeuner",
                    sentence: "Son collègue dit : je t'envoie le dossier avant la pause déjeuner.",
                    annotation: "协作沟通"
                ),
                ListeningScenario(
                    display: "on décale l'appel client à demain matin",
                    speakable: "on décale l'appel client à demain matin",
                    sentence: "Dans l'open space, quelqu'un dit : on décale l'appel client à demain matin.",
                    annotation: "临时变更"
                )
            ].randomElement()

        default:
            return nil
        }
    }

    func structureHint(for mode: GameMode) -> String {
        switch mode {
        case .number:       return "先只抓数字本体，不要被整句干扰。"
        case .phoneNumber:  return "这是一个电话号码，先确认开头和分组。"
        case .price:        return "这是一个价格，先听整数位再听小数位。"
        case .time:         return "这是一个 24 小时制时间，先抓小时。"
        case .year:         return "这是一个年份，先抓前两位。"
        case .month:        return "这是一个日期结构，先抓日再抓月份。"
        case .trainNumber:  return "这是一个车次编号，先抓字母/类型再抓数字。"
        case .flightNumber: return "这是一个航班号，先抓字母代码再抓数字。"
        case .address:      return "这是地址信息，先抓门牌，再抓街道。"
        case .reservation:  return "这是预约信息，先抓人数，再抓时间。"
        case .cafeOrder:    return "这是点单表达，先抓核心名词。"
        case .directions:   return "这是路线说明，先抓动作词和地标。"
        case .smallTalk:    return "这是寒暄口语，先抓动词和主语。"
        case .service:      return "这是生活服务信息，先抓时间或结果。"
        case .shopping:     return "这是购物对话，先抓数量、颜色或付款动作。"
        case .transport:    return "这是出行信息，先抓线路、站点或出口。"
        case .health:       return "这是健康场景，先抓症状、频次或时间。"
        case .workday:      return "这是工作沟通，先抓人物动作和时间安排。"
        }
    }

    var successText: String { "Correct !" }
    var listenText: String { "Écoutez..." }
    var nextText: String { "Suivant" }
    var revealText: String { "Vérifier" }
    var inputPlaceholder: String { "Tapez ce que vous avez entendu..." }
    var wrongAnswerPrefix: String { "Vous avez tapé :" }
    var appName: String { "Chiffre" }
    var speakTapHint: String { "Toucher pour écouter" }
    var speakIdlePrompt: String { "Appuyez pour parler" }
    var speakListeningPrompt: String { "Je vous écoute..." }
    var speakCorrectPrompt: String { "Parfait !" }
    var speakWrongPrompt: String { "Essayez encore" }
    var showTextLabel: String { "Afficher le texte" }
    var hideTextLabel: String { "Masquer le texte" }
    var skipLabel: String { "Passer" }
    var emptyInputPrompt: String { "先听一遍，再尝试输入；不急。" }
    var hintStartText: String { "给我一点提示" }
    var hintFocusReplayText: String { "只听数字" }
    var hintStructureText: String { "看结构" }
    var hintScaffoldText: String { "给我支架" }
    var hintPartialRevealText: String { "再给一点" }
    var hintShowAnswerText: String { "显示答案" }
    var hintDoneText: String { "已显示答案" }
    var hintReplayFullMessage: String { "先完整再听一遍，抓整体节奏。" }
    var hintReplayFocusedMessage: String { "这次只听关键数字片段。" }
    var hintScaffoldMessage: String { "先看结构，不看完整答案。" }
    var hintPartialRevealMessage: String { "再给你一半线索，离答案很近了。" }
    var hintShowAnswerMessage: String { "已展示完整答案，下一题继续。" }
    var gentleWrongText: String { "差一点。先抓结构，再听一次会更稳。" }
}

// MARK: - 西班牙语数据提供者
struct SpanishDataProvider: LanguageDataProvider {
    let months: [(name: String, days: Int)] = [
        ("enero", 31), ("febrero", 28), ("marzo", 31), ("abril", 30),
        ("mayo", 31), ("junio", 30), ("julio", 31), ("agosto", 31),
        ("septiembre", 30), ("octubre", 31), ("noviembre", 30), ("diciembre", 31)
    ]
    
    let trainTypes = ["AVE", "Renfe", "Cercanías", "Media Distancia"]
    
    let airlines: [(code: String, fullName: String)] = [
        ("IB", "Iberia"),
        ("UX", "Air Europa"),
        ("VY", "Vueling"),
        ("AF", "Air France"),
        ("LH", "Lufthansa")
    ]
    
    func formatPhonePrefix() -> String {
        ["6", "7"].randomElement()!
    }
    
    func formatPrice(euro: Int, cent: Int) -> (display: String, speakable: String) {
        let display = String(format: "%d,%02d €", euro, cent)
        let speakable: String
        if cent == 0 {
            speakable = "\(euro) euros"
        } else {
            speakable = "\(euro) euros con \(cent) céntimos"
        }
        return (display, speakable)
    }
    
    func formatTime(hour: Int, minute: Int) -> (display: String, speakable: String) {
        // 24小时制
        let display = String(format: "%02d:%02d", hour, minute)
        let speakable: String
        if minute == 0 {
            speakable = "las \(hour) en punto"
        } else if minute == 30 {
            speakable = "las \(hour) y media"
        } else {
            speakable = "las \(hour) \(minute)"
        }
        return (display, speakable)
    }
    
    func formatMonth(day: Int, month: String) -> (display: String, speakable: String) {
        let display = "el \(day) de \(month)"
        let speakable = day == 1 ? "el primero de \(month)" : "el \(day) de \(month)"
        return (display, speakable)
    }
    
    func sentenceTemplate(for mode: GameMode) -> String {
        let templates: [GameMode: [String]] = [
            .number:       ["Hay {X} personas.", "Habitación número {X}.", "El código es el {X}."],
            .phoneNumber:  ["Llame al {X}.", "Su número es el {X}.", "Anote el {X}."],
            .price:        ["Son {X}, por favor.", "El billete cuesta {X}.", "El total es {X}."],
            .time:         ["El tren sale a las {X}.", "La cita es a las {X}.", "La película empieza a las {X}."],
            .year:         ["Nació en {X}.", "Ocurrió en {X}.", "Esta obra es de {X}."],
            .month:        ["La reunión es {X}.", "Salimos {X}.", "El paquete llega {X}."],
            .trainNumber:  ["Su tren es el {X}.", "Tome el {X} en el andén cinco.", "El {X} lleva retraso."],
            .flightNumber: ["Su vuelo es el {X}.", "El embarque del vuelo {X} ha comenzado.", "Anuncian el vuelo {X}."],
            .address:      ["La dirección es {X}.", "Nos vemos en {X}.", "La entrega es en {X}."],
            .reservation:  ["La reserva es {X}.", "Queda apuntado: {X}.", "Su cita es {X}."],
            .cafeOrder:    ["Voy a pedir {X}.", "Para mí será {X}.", "Han pedido {X}."],
            .directions:   ["Para llegar, {X}.", "La indicación es: {X}.", "Le dicen que {X}."],
            .smallTalk:    ["En la conversación dicen: {X}.", "La frase que escuchas es {X}.", "Al final comenta: {X}."],
            .service:      ["El aviso dice: {X}.", "La información es {X}.", "Le comunican que {X}."],
            .shopping:     ["En la tienda se oye: {X}.", "Mientras compra, alguien dice: {X}.", "En caja le preguntan: {X}."],
            .transport:    ["En el transporte anuncian: {X}.", "El conductor dice: {X}.", "De camino se oye: {X}."],
            .health:       ["En la farmacia le dicen: {X}.", "El médico pregunta: {X}.", "Durante la consulta se oye: {X}."],
            .workday:      ["En la oficina se oye: {X}.", "Durante la reunión alguien dice: {X}.", "En el trabajo le recuerdan: {X}."],
        ]
        return templates[mode]?.randomElement() ?? "{X}"
    }

    func scenarioPrompt(for mode: GameMode) -> ListeningScenario? {
        switch mode {
        case .address:
            return [
                ListeningScenario(
                    display: "calle Atocha número veintidós",
                    speakable: "calle Atocha número veintidós",
                    sentence: "La cita es en la calle Atocha número veintidós, segundo piso.",
                    annotation: "地址与楼层"
                ),
                ListeningScenario(
                    display: "avenida de América cuarenta y cinco",
                    speakable: "avenida de América cuarenta y cinco",
                    sentence: "El taxi le deja en la avenida de América cuarenta y cinco.",
                    annotation: "门牌与街道"
                ),
                ListeningScenario(
                    display: "portal C, puerta ocho",
                    speakable: "portal C, puerta ocho",
                    sentence: "La entrega es para el portal C, puerta ocho.",
                    annotation: "楼栋与门牌"
                )
            ].randomElement()

        case .reservation:
            return [
                ListeningScenario(
                    display: "una mesa para dos a las ocho",
                    speakable: "una mesa para dos a las ocho",
                    sentence: "Tengo una reserva para una mesa para dos a las ocho.",
                    annotation: "订位与时间"
                ),
                ListeningScenario(
                    display: "una cita el jueves por la mañana",
                    speakable: "una cita el jueves por la mañana",
                    sentence: "Le confirmamos una cita el jueves por la mañana.",
                    annotation: "预约确认"
                ),
                ListeningScenario(
                    display: "cuatro plazas a nombre de Lucía",
                    speakable: "cuatro plazas a nombre de Lucía",
                    sentence: "La reserva es para cuatro plazas a nombre de Lucía.",
                    annotation: "人数与姓名"
                )
            ].randomElement()

        case .cafeOrder:
            return [
                ListeningScenario(
                    display: "dos cafés con leche y una tostada",
                    speakable: "dos cafés con leche y una tostada",
                    sentence: "En la barra pide dos cafés con leche y una tostada.",
                    annotation: "咖啡馆点单"
                ),
                ListeningScenario(
                    display: "un bocadillo sin cebolla",
                    speakable: "un bocadillo sin cebolla",
                    sentence: "Para comer, él quiere un bocadillo sin cebolla.",
                    annotation: "午餐点单"
                ),
                ListeningScenario(
                    display: "una botella de agua fría",
                    speakable: "una botella de agua fría",
                    sentence: "Al final añade una botella de agua fría.",
                    annotation: "追加购买"
                )
            ].randomElement()

        case .directions:
            return [
                ListeningScenario(
                    display: "gire a la derecha después del banco",
                    speakable: "gire a la derecha después del banco",
                    sentence: "Para llegar al museo, gire a la derecha después del banco.",
                    annotation: "方位与转弯"
                ),
                ListeningScenario(
                    display: "está a tres calles de aquí",
                    speakable: "está a tres calles de aquí",
                    sentence: "No está lejos, está a tres calles de aquí.",
                    annotation: "距离表达"
                ),
                ListeningScenario(
                    display: "salga por la puerta del norte",
                    speakable: "salga por la puerta del norte",
                    sentence: "En la estación, salga por la puerta del norte.",
                    annotation: "交通引导"
                )
            ].randomElement()

        case .smallTalk:
            return [
                ListeningScenario(
                    display: "cuánto tiempo sin verte, qué tal todo",
                    speakable: "cuánto tiempo sin verte, qué tal todo",
                    sentence: "En la calle se oye: cuánto tiempo sin verte, qué tal todo.",
                    annotation: "日常寒暄"
                ),
                ListeningScenario(
                    display: "sigues viviendo cerca del centro",
                    speakable: "sigues viviendo cerca del centro",
                    sentence: "Durante la charla pregunta: sigues viviendo cerca del centro.",
                    annotation: "近况聊天"
                ),
                ListeningScenario(
                    display: "nos vemos este fin de semana si puedes",
                    speakable: "nos vemos este fin de semana si puedes",
                    sentence: "Antes de irse, dice: nos vemos este fin de semana si puedes.",
                    annotation: "邀约口语"
                )
            ].randomElement()

        case .service:
            return [
                ListeningScenario(
                    display: "la farmacia abre a las nueve mañana",
                    speakable: "la farmacia abre a las nueve mañana",
                    sentence: "En el cartel pone: la farmacia abre a las nueve mañana.",
                    annotation: "营业时间"
                ),
                ListeningScenario(
                    display: "su paquete llegará antes del mediodía",
                    speakable: "su paquete llegará antes del mediodía",
                    sentence: "El aviso indica que su paquete llegará antes del mediodía.",
                    annotation: "配送通知"
                ),
                ListeningScenario(
                    display: "se acepta pago con tarjeta",
                    speakable: "se acepta pago con tarjeta",
                    sentence: "En la caja le informan de que se acepta pago con tarjeta.",
                    annotation: "店内服务"
                )
            ].randomElement()

        case .shopping:
            return [
                ListeningScenario(
                    display: "busco la talla treinta y ocho en color crema",
                    speakable: "busco la talla treinta y ocho en color crema",
                    sentence: "En la tienda dice: busco la talla treinta y ocho en color crema.",
                    annotation: "尺码与颜色"
                ),
                ListeningScenario(
                    display: "me pone medio kilo de uvas para llevar",
                    speakable: "me pone medio kilo de uvas para llevar",
                    sentence: "En el mercado pregunta: me pone medio kilo de uvas para llevar.",
                    annotation: "买菜沟通"
                ),
                ListeningScenario(
                    display: "pago con tarjeta pero sin bolsa",
                    speakable: "pago con tarjeta pero sin bolsa",
                    sentence: "Al pagar aclara: pago con tarjeta pero sin bolsa.",
                    annotation: "结账表达"
                )
            ].randomElement()

        case .transport:
            return [
                ListeningScenario(
                    display: "el autobús pasa cada doce minutos",
                    speakable: "el autobús pasa cada doce minutos",
                    sentence: "En la parada anuncian que el autobús pasa cada doce minutos.",
                    annotation: "公交频次"
                ),
                ListeningScenario(
                    display: "haga transbordo en la próxima estación",
                    speakable: "haga transbordo en la próxima estación",
                    sentence: "En el metro se oye: haga transbordo en la próxima estación.",
                    annotation: "换乘提示"
                ),
                ListeningScenario(
                    display: "su taxi está esperando en la salida principal",
                    speakable: "su taxi está esperando en la salida principal",
                    sentence: "Al llegar le avisan: su taxi está esperando en la salida principal.",
                    annotation: "接送信息"
                )
            ].randomElement()

        case .health:
            return [
                ListeningScenario(
                    display: "tome este jarabe dos veces al día",
                    speakable: "tome este jarabe dos veces al día",
                    sentence: "En la farmacia le explican: tome este jarabe dos veces al día.",
                    annotation: "用药说明"
                ),
                ListeningScenario(
                    display: "me duele la garganta desde anoche",
                    speakable: "me duele la garganta desde anoche",
                    sentence: "Durante la consulta comenta: me duele la garganta desde anoche.",
                    annotation: "症状表达"
                ),
                ListeningScenario(
                    display: "vuelva mañana si sigue con fiebre",
                    speakable: "vuelva mañana si sigue con fiebre",
                    sentence: "El médico añade: vuelva mañana si sigue con fiebre.",
                    annotation: "复诊建议"
                )
            ].randomElement()

        case .workday:
            return [
                ListeningScenario(
                    display: "la reunión empieza a las nueve en la sala B",
                    speakable: "la reunión empieza a las nueve en la sala B",
                    sentence: "En la oficina recuerdan que la reunión empieza a las nueve en la sala B.",
                    annotation: "会议安排"
                ),
                ListeningScenario(
                    display: "te mando el archivo antes de comer",
                    speakable: "te mando el archivo antes de comer",
                    sentence: "Su compañero dice: te mando el archivo antes de comer.",
                    annotation: "协作沟通"
                ),
                ListeningScenario(
                    display: "pasamos la llamada con el cliente a mañana",
                    speakable: "pasamos la llamada con el cliente a mañana",
                    sentence: "En el trabajo comentan: pasamos la llamada con el cliente a mañana.",
                    annotation: "临时变更"
                )
            ].randomElement()

        default:
            return nil
        }
    }

    func structureHint(for mode: GameMode) -> String {
        switch mode {
        case .number:       return "先只抓数字本体，不要被整句干扰。"
        case .phoneNumber:  return "这是一个电话号码，先确认开头和分组。"
        case .price:        return "这是一个价格，先听整数位再听小数位。"
        case .time:         return "这是一个 24 小时制时间，先抓小时。"
        case .year:         return "这是一个年份，先抓前两位。"
        case .month:        return "这是一个日期结构，先抓日再抓月份。"
        case .trainNumber:  return "这是一个车次编号，先抓字母/类型再抓数字。"
        case .flightNumber: return "这是一个航班号，先抓字母代码再抓数字。"
        case .address:      return "这是地址信息，先抓门牌，再抓街道。"
        case .reservation:  return "这是预约信息，先抓人数，再抓时间。"
        case .cafeOrder:    return "这是点单表达，先抓核心名词。"
        case .directions:   return "这是路线说明，先抓动作词和地标。"
        case .smallTalk:    return "这是寒暄口语，先抓动词和主语。"
        case .service:      return "这是生活服务信息，先抓时间或结果。"
        case .shopping:     return "这是购物对话，先抓数量、颜色或付款动作。"
        case .transport:    return "这是出行信息，先抓线路、站点或出口。"
        case .health:       return "这是健康场景，先抓症状、频次或时间。"
        case .workday:      return "这是工作沟通，先抓人物动作和时间安排。"
        }
    }

    var successText: String { "¡Correcto!" }
    var listenText: String { "Escucha..." }
    var nextText: String { "Siguiente" }
    var revealText: String { "Verificar" }
    var inputPlaceholder: String { "Escriba lo que ha escuchado..." }
    var wrongAnswerPrefix: String { "Usted escribió:" }
    var appName: String { "Cifra" }
    var speakTapHint: String { "Toca para escuchar" }
    var speakIdlePrompt: String { "Pulsa para hablar" }
    var speakListeningPrompt: String { "Te escucho..." }
    var speakCorrectPrompt: String { "¡Perfecto!" }
    var speakWrongPrompt: String { "Inténtalo de nuevo" }
    var showTextLabel: String { "Mostrar texto" }
    var hideTextLabel: String { "Ocultar texto" }
    var skipLabel: String { "Saltar" }
    var emptyInputPrompt: String { "先听一遍，再尝试输入；不急。" }
    var hintStartText: String { "给我一点提示" }
    var hintFocusReplayText: String { "只听数字" }
    var hintStructureText: String { "看结构" }
    var hintScaffoldText: String { "给我支架" }
    var hintPartialRevealText: String { "再给一点" }
    var hintShowAnswerText: String { "显示答案" }
    var hintDoneText: String { "已显示答案" }
    var hintReplayFullMessage: String { "先完整再听一遍，抓整体节奏。" }
    var hintReplayFocusedMessage: String { "这次只听关键数字片段。" }
    var hintScaffoldMessage: String { "先看结构，不看完整答案。" }
    var hintPartialRevealMessage: String { "再给你一半线索，离答案很近了。" }
    var hintShowAnswerMessage: String { "已展示完整答案，下一题继续。" }
    var gentleWrongText: String { "差一点。先抓结构，再听一次会更稳。" }
}
