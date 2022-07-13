class ChatMessageModel {
  String? contentId;
  String? sender;
  String? receiver;
  String? contentValue;
  String? time;
  String? consumerUrl;
  String? providerUrl;

  ChatMessageModel(
      {this.contentId,
      this.sender,
      this.receiver,
      this.contentValue,
      this.time,
      this.consumerUrl,
      this.providerUrl});

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    contentId = json['contentId'];
    sender = json['sender'];
    receiver = json['receiver'];
    contentValue = json['contentValue'];
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
    data['time'] = time;
    data['consumerUrl'] = consumerUrl;
    data['providerUrl'] = providerUrl;
    return data;
  }
}
