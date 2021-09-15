//
//  Language.swift
//  Stringz
//
//  Created by Heysem Katibi on 12/22/16.
//  Copyright © 2016 Heysem Katibi. All rights reserved.
//

import Foundation

/// The languages available in iOS system, Every File must have a language. Default: `Language.base`
enum Language: String, CaseIterable {
  case base = "base"
  case english = "en"
  case englishUK = "en-gb"
  case englishAustralian = "en-au"
  case englishCanadian = "en-ca"
  case englishIndian = "en-in"
  case french = "fr"
  case frenchCanadian = "fr-ca"
  case spanish = "es"
  case spanishMexico = "es-mx"
  case portuguese = "pt"
  case portugueseBrazil = "pt-br"
  case italian = "it"
  case german = "de"
  case chineseSimplified = "zh-hans"
  case chineseTraditional = "zh-hant"
  case chineseHongKong = "zh-hk"
  case dutch = "nl"
  case japanese = "ja"
  case korean = "ko"
  case vietnamese = "vi"
  case russian = "ru"
  case swedish = "sv"
  case danish = "da"
  case finnish = "fi"
  case norwegianBokmal = "nb"
  case turkish = "tr"
  case greek = "el"
  case indonesian = "id"
  case malay = "ms"
  case thai = "th"
  case hindi = "hi"
  case hungarian = "hu"
  case polish = "pl"
  case czech = "cs"
  case slovak = "sk"
  case ukrainian = "uk"
  case catalan = "ca"
  case romanian = "ro"
  case croatian = "hr"
  case hebrew = "he"
  case arabic = "ar"

  /// Returns a firendly name for the language to be displayed in the table view.
  var fiendlyName: String {
    switch self {
    case .base: return "Base"
    case .english: return "English (US)"
    case .englishUK: return "English (UK)"
    case .englishAustralian: return "English (Australian)"
    case .englishCanadian: return "English (Canadian)"
    case .englishIndian: return "English (Indian)"
    case .french: return "French"
    case .frenchCanadian: return "French (Canadian)"
    case .spanish: return "Spanish"
    case .spanishMexico: return "Spanish (Mexico)"
    case .portuguese: return "Portuguese"
    case .portugueseBrazil: return "Portuguese (Brazil)"
    case .italian: return "Italian"
    case .german: return "German"
    case .chineseSimplified: return "Chinese (Simplified)"
    case .chineseTraditional: return "Chinese (Traditional)"
    case .chineseHongKong: return "Chinese (Hong Kong)"
    case .dutch: return "Dutch"
    case .japanese: return "Japanese"
    case .korean: return "Korean"
    case .vietnamese: return "Vietnamese"
    case .russian: return "Russian"
    case .swedish: return "Swedish"
    case .danish: return "Danish"
    case .finnish: return "Finnish"
    case .norwegianBokmal: return "Norwegian Bokmål"
    case .turkish: return "Turkish"
    case .greek: return "Greek"
    case .indonesian: return "Indonesian"
    case .malay: return "Malay"
    case .thai: return "Thai"
    case .hindi: return "Hindi"
    case .hungarian: return "Hungarian"
    case .polish: return "Polish"
    case .czech: return "Czech"
    case .slovak: return "Slovak"
    case .ukrainian: return "Ukrainian"
    case .catalan: return "Catalan"
    case .romanian: return "Romanian"
    case .croatian: return "Croatian"
    case .hebrew: return "Hebrew"
    case .arabic: return "Arabic"
    }
  }

  /// Returns the flag of the country in which the language is mostly used.
  var flag: String {
    switch self {
    case .base: return "🏁"
    case .english: return "🇺🇸"
    case .englishUK: return "🇬🇧"
    case .englishAustralian: return "🇦🇺"
    case .englishCanadian: return "🇨🇦"
    case .englishIndian: return "🇮🇳"
    case .french: return "🇫🇷"
    case .frenchCanadian: return "🇨🇦"
    case .spanish: return "🇪🇸"
    case .spanishMexico: return "🇲🇽"
    case .portuguese: return "🇵🇹"
    case .portugueseBrazil: return "🇧🇷"
    case .italian: return "🇮🇹"
    case .german: return "🇩🇪"
    case .chineseSimplified: return "🇨🇳"
    case .chineseTraditional: return "🇹🇼"
    case .chineseHongKong: return "🇭🇰"
    case .dutch: return "🇳🇱"
    case .japanese: return "🇯🇵"
    case .korean: return "🇰🇷"
    case .vietnamese: return "🇻🇳"
    case .russian: return "🇷🇺"
    case .swedish: return "🇸🇪"
    case .danish: return "🇩🇰"
    case .finnish: return "🇫🇮"
    case .norwegianBokmal: return "🇳🇴"
    case .turkish: return "🇹🇷"
    case .greek: return "🇬🇷"
    case .indonesian: return "🇮🇩"
    case .malay: return "🇲🇾"
    case .thai: return "🇹🇭"
    case .hindi: return "🇮🇳"
    case .hungarian: return "🇭🇺"
    case .polish: return "🇷🇺"
    case .czech: return "🇨🇿"
    case .slovak: return "🇸🇰"
    case .ukrainian: return "🇺🇦"
    case .catalan: return "🇪🇸"
    case .romanian: return "🇷🇴"
    case .croatian: return "🇭🇷"
    case .hebrew: return "🇮🇱"
    case .arabic: return "🇸🇦"
    }
  }
}

extension Language: Comparable {
  static func < (lhs: Language, rhs: Language) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}
