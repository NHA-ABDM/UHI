import 'package:uhi_flutter_app/model/response/src/get_upcoming_appointments_response.dart';

class GroupConsultUpcomingAppointmentResponseModel {
  UpcomingAppointmentResponseModal? docOneResponse;
  UpcomingAppointmentResponseModal? docTwoResponse;

  GroupConsultUpcomingAppointmentResponseModel(
      {this.docOneResponse, this.docTwoResponse});

  GroupConsultUpcomingAppointmentResponseModel.fromJson(
      Map<String, dynamic> json) {
    docOneResponse = json['docOneResponse'] != null
        ? new UpcomingAppointmentResponseModal.fromJson(json['docOneResponse'])
        : null;
    docTwoResponse = json['docTwoResponse'] != null
        ? new UpcomingAppointmentResponseModal.fromJson(json['docTwoResponse'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.docOneResponse != null) {
      data['docOneResponse'] = this.docOneResponse!.toJson();
    }
    if (this.docTwoResponse != null) {
      data['docTwoResponse'] = this.docTwoResponse!.toJson();
    }
    return data;
  }
}
