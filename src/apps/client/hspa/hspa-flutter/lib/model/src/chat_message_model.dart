class ChatMessageModel {
  String? contentId;
  String? sender;
  String? receiver;
  String? contentValue;
  String? contentType;
  String? contentUrl;
  String? fileName;
  String? time;
  String? consumerUrl;
  String? providerUrl;

  ChatMessageModel(
      {this.contentId,
      this.sender,
      this.receiver,
      this.contentValue,
      this.contentType,
      this.contentUrl,
      this.fileName,
      this.time,
      this.consumerUrl,
      this.providerUrl});

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId'];
    sender = json['sender'];
    receiver = json['receiver'];
    contentValue = json['contentValue'];
    contentType = json['contentType'];
    contentUrl = json['contentUrl'];
    if(json.containsKey('fileName')) {
      fileName = json['fileName'];
    }
    time = json['time'];
    consumerUrl = json['consumerUrl'];
    providerUrl = json['providerUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['contentId'] = contentId;
    data['sender'] = sender;
    data['receiver'] = receiver;
    data['contentValue'] = contentValue;
    data['contentType'] = contentType;
    data['contentUrl'] = contentUrl;
    data['fileName'] = fileName;
    data['time'] = time;
    data['consumerUrl'] = consumerUrl;
    data['providerUrl'] = providerUrl;
    return data;
  }
}
