import Foundation

struct LanguagePack {
    let language: AppLanguage

    var provider: LanguageDataProvider {
        switch language {
        case .french:  return FrenchDataProvider()
        case .spanish: return SpanishDataProvider()
        }
    }
}
