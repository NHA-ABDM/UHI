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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contentId'] = this.contentId;
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    data['contentValue'] = this.contentValue;
    data['time'] = this.time;
    data['consumerUrl'] = this.consumerUrl;
    data['providerUrl'] = this.providerUrl;
    return data;
  }
}
