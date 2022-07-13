class ResponseModel {
  String? id;
  String? messageId;
  String? consumerId;
  String? response;
  String? dhpQueryType;
  String? createdAt;

  ResponseModel(
      {this.id,
      this.messageId,
      this.consumerId,
      this.response,
      this.dhpQueryType,
      this.createdAt});

  ResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    messageId = json['message_id'];
    consumerId = json['consumer_id'];
    response = json['response'];
    dhpQueryType = json['dhp_query_type'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message_id'] = this.messageId;
    data['consumer_id'] = this.consumerId;
    if (this.response != null) {
      data['response'] = this.response;
    }
    data['dhp_query_type'] = this.dhpQueryType;
    data['created_at'] = this.createdAt;
    return data;
  }
}
