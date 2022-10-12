class AbhaAddressSuggestionsResponseModel {
  List<String>? suggestedPhrAddress;

  AbhaAddressSuggestionsResponseModel({this.suggestedPhrAddress});

  AbhaAddressSuggestionsResponseModel.fromJson(Map<String, dynamic> json) {
    suggestedPhrAddress = json['suggestedPhrAddress'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['suggestedPhrAddress'] = this.suggestedPhrAddress;
    return data;
  }
}
