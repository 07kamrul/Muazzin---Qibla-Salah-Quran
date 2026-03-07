enum RevelationType { meccan, medinan }

class SurahModel {
  const SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameBangla,
    required this.nameEnglish,
    required this.nameMeaning,
    required this.ayahCount,
    required this.juzStart,
    required this.revelationType,
  });

  final int            number;
  final String         nameArabic;
  final String         nameBangla;
  final String         nameEnglish;
  final String         nameMeaning;
  final int            ayahCount;
  final int            juzStart;
  final RevelationType revelationType;

  Map<String, dynamic> toJson() => {
    'number':          number,
    'name_arabic':     nameArabic,
    'name_bangla':     nameBangla,
    'name_english':    nameEnglish,
    'name_meaning':    nameMeaning,
    'ayah_count':      ayahCount,
    'juz_start':       juzStart,
    'revelation_type': revelationType.name,
  };

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
    number:       json['number']       as int,
    nameArabic:   json['name_arabic']  as String,
    nameBangla:   json['name_bangla']  as String? ?? '',
    nameEnglish:  json['name_english'] as String? ?? '',
    nameMeaning:  json['name_meaning'] as String? ?? '',
    ayahCount:    json['ayah_count']   as int,
    juzStart:     json['juz_start']    as int? ?? 1,
    revelationType: RevelationType.values.firstWhere(
      (r) => r.name == (json['revelation_type'] as String?)?.toLowerCase(),
      orElse: () => RevelationType.meccan,
    ),
  );
}

class AyahModel {
  const AyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.banglaTranslation,
    required this.englishTranslation,
    required this.juzNumber,
    this.pageNumber,
  });

  final int    surahNumber;
  final int    ayahNumber;
  final String arabicText;
  final String banglaTranslation;
  final String englishTranslation;
  final int    juzNumber;
  final int?   pageNumber;

  Map<String, dynamic> toJson() => {
    'surah_number':        surahNumber,
    'ayah_number':         ayahNumber,
    'arabic_text':         arabicText,
    'bangla_translation':  banglaTranslation,
    'english_translation': englishTranslation,
    'juz_number':          juzNumber,
    'page_number':         pageNumber,
  };

  factory AyahModel.fromJson(Map<String, dynamic> json) => AyahModel(
    surahNumber:        json['surah_number']        as int,
    ayahNumber:         json['ayah_number']         as int,
    arabicText:         json['arabic_text']         as String,
    banglaTranslation:  json['bangla_translation']  as String? ?? '',
    englishTranslation: json['english_translation'] as String? ?? '',
    juzNumber:          json['juz_number']          as int? ?? 1,
    pageNumber:         json['page_number']         as int?,
  );
}
