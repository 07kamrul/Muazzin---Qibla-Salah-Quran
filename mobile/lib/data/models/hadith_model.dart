class HadithModel {
  const HadithModel({
    required this.id,
    required this.banglaTranslation,
    required this.englishTranslation,
    required this.source,
    required this.bookName,
    required this.hadithNumber,
    required this.dayOfYear,
    this.arabicText,
    this.narrator,
  });

  final int     id;
  final String? arabicText;
  final String  banglaTranslation;
  final String  englishTranslation;
  final String  source;
  final String  bookName;
  final String  hadithNumber;
  final String? narrator;
  final int     dayOfYear; // 1-365 for daily rotation

  Map<String, dynamic> toJson() => {
    'id':                  id,
    'arabic_text':         arabicText,
    'bangla_translation':  banglaTranslation,
    'english_translation': englishTranslation,
    'source':              source,
    'book_name':           bookName,
    'hadith_number':       hadithNumber,
    'narrator':            narrator,
    'day_of_year':         dayOfYear,
  };

  factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
    id:                  json['id'] as int,
    arabicText:          json['arabic_text']         as String?,
    banglaTranslation:   json['bangla_translation']  as String? ??
                         json['banglaTranslation']   as String? ?? '',
    englishTranslation:  json['english_translation'] as String? ??
                         json['englishTranslation']  as String? ?? '',
    source:              json['source']              as String? ?? '',
    bookName:            json['book_name']           as String? ??
                         json['bookName']            as String? ?? '',
    hadithNumber:        json['hadith_number']       as String? ??
                         json['hadithNumber']        as String? ?? '',
    narrator:            json['narrator']            as String?,
    dayOfYear:           json['day_of_year']         as int? ??
                         json['dayOfYear']           as int? ?? 1,
  );
}
