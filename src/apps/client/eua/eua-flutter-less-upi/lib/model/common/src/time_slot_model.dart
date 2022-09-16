class TimeSlotModel {
  TimeSlotStart? start;
  TimeSlotStart? end;
  TimeSlotTags? tags;

  TimeSlotModel({this.start, this.end, this.tags});

  TimeSlotModel.fromJson(Map<String, dynamic> json) {
    start = json['start'] != null
        ? new TimeSlotStart.fromJson(json['start'])
        : null;
    end = json['end'] != null ? new TimeSlotStart.fromJson(json['end']) : null;
    tags =
        json['tags'] != null ? new TimeSlotTags.fromJson(json['tags']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.start != null) {
      data['start'] = this.start!.toJson();
    }
    if (this.end != null) {
      data['end'] = this.end!.toJson();
    }
    if (this.tags != null) {
      data['tags'] = this.tags!.toJson();
    }
    return data;
  }
}

class TimeSlotStart {
  TimeSlotStartTime? time;

  TimeSlotStart({this.time});

  TimeSlotStart.fromJson(Map<String, dynamic> json) {
    time = json['time'] != null
        ? new TimeSlotStartTime.fromJson(json['time'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.time != null) {
      data['time'] = this.time!.toJson();
    }
    return data;
  }
}

class TimeSlotStartTime {
  String? timestamp;

  TimeSlotStartTime({this.timestamp});

  TimeSlotStartTime.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    return data;
  }
}

class TimeSlotTags {
  String? abdmGovInSlot;

  TimeSlotTags({this.abdmGovInSlot});

  TimeSlotTags.fromJson(Map<String, dynamic> json) {
    abdmGovInSlot = json['@abdm/gov.in/slot_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['@abdm/gov.in/slot_id'] = this.abdmGovInSlot;
    return data;
  }
}
