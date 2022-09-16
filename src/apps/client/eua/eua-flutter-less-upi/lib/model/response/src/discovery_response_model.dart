import 'package:uhi_flutter_app/model/common/src/context_model.dart';
import 'package:uhi_flutter_app/model/request/src/booking_init_request_model.dart';

class DiscoveryResponseModel {
  ContextModel? context;
  DiscoveryMessage? message;

  DiscoveryResponseModel({this.context, this.message});

  DiscoveryResponseModel.fromJson(Map<String, dynamic> json) {
    context =
        json['context'] != null ? ContextModel.fromJson(json['context']) : null;
    message = json['message'] != null
        ? DiscoveryMessage.fromJson(json['message'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.context != null) {
      data['context'] = this.context!.toJson();
    }
    if (this.message != null) {
      data['message'] = this.message!.toJson();
    }
    return data;
  }
}

class DiscoveryMessage {
  DiscoveryCatalog? catalog;

  DiscoveryMessage({this.catalog});

  DiscoveryMessage.fromJson(Map<String, dynamic> json) {
    catalog = json['catalog'] != null
        ? DiscoveryCatalog.fromJson(json['catalog'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.catalog != null) {
      data['catalog'] = this.catalog!.toJson();
    }
    return data;
  }
}

class DiscoveryCatalog {
  DiscoveryDescriptor? descriptor;
  List<DiscoveryProviders>? providers;
  List<Fulfillment>? fulfillments;

  DiscoveryCatalog({this.descriptor, this.providers});

  DiscoveryCatalog.fromJson(Map<String, dynamic> json) {
    descriptor = json['descriptor'] != null
        ? DiscoveryDescriptor.fromJson(json['descriptor'])
        : null;
    if (json['providers'] != null) {
      providers = <DiscoveryProviders>[];
      json['providers'].forEach((v) {
        providers!.add(DiscoveryProviders.fromJson(v));
      });
    }

    if (json['fulfillments'] != null) {
      fulfillments = <Fulfillment>[];
      json['fulfillments'].forEach((v) {
        fulfillments!.add(Fulfillment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.descriptor != null) {
      data['descriptor'] = this.descriptor!.toJson();
    }
    if (this.providers != null) {
      data['providers'] = this.providers!.map((v) => v.toJson()).toList();
    }
    if (this.fulfillments != null) {
      data['fulfillments'] = this.fulfillments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DiscoveryDescriptor {
  String? name;

  DiscoveryDescriptor({this.name});

  DiscoveryDescriptor.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    return data;
  }
}

class DiscoveryProviders {
  String? id;
  DiscoveryDescriptor? descriptor;
  List<DiscoveryLocations>? locations;
  List<DiscoveryCategories>? categories;
  List<DiscoveryItems>? items;
  List<Fulfillment>? fulfillments;

  DiscoveryProviders(
      {this.id,
      this.descriptor,
      this.locations,
      this.categories,
      this.items,
      this.fulfillments});

  DiscoveryProviders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descriptor = json['descriptor'] != null
        ? DiscoveryDescriptor.fromJson(json['descriptor'])
        : null;
    if (json['locations'] != null) {
      locations = <DiscoveryLocations>[];
      json['locations'].forEach((v) {
        locations!.add(DiscoveryLocations.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <DiscoveryCategories>[];
      json['categories'].forEach((v) {
        categories!.add(DiscoveryCategories.fromJson(v));
      });
    }
    if (json['items'] != null) {
      items = <DiscoveryItems>[];
      json['items'].forEach((v) {
        items!.add(DiscoveryItems.fromJson(v));
      });
    }
    if (json['fulfillments'] != null) {
      fulfillments = <Fulfillment>[];
      json['fulfillments'].forEach((v) {
        fulfillments!.add(Fulfillment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    if (this.descriptor != null) {
      data['descriptor'] = this.descriptor!.toJson();
    }
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.fulfillments != null) {
      data['fulfillments'] = this.fulfillments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DiscoveryLocations {
  String? id;
  String? gps;
  DiscoveryAddress? address;

  DiscoveryLocations({this.id, this.gps, this.address});

  DiscoveryLocations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    gps = json['gps'];
    address = json['address'] != null
        ? DiscoveryAddress.fromJson(json['address'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['gps'] = this.gps;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    return data;
  }
}

class DiscoveryAddress {
  String? full;

  DiscoveryAddress({this.full});

  DiscoveryAddress.fromJson(Map<String, dynamic> json) {
    full = json['full'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['full'] = this.full;
    return data;
  }
}

class DiscoveryCategories {
  String? id;
  DiscoveryDescriptor? descriptor;

  DiscoveryCategories({this.id, this.descriptor});

  DiscoveryCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descriptor = json['descriptor'] != null
        ? DiscoveryDescriptor.fromJson(json['descriptor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    if (this.descriptor != null) {
      data['descriptor'] = this.descriptor!.toJson();
    }
    return data;
  }
}

class DiscoveryItems {
  String? id;
  DiscoveryDescriptor? descriptor;
  String? categoryId;
  String? fulfillmentId;
  DiscoveryPrice? price;
  Quantity? quantity;

  DiscoveryItems(
      {this.id,
      this.descriptor,
      this.categoryId,
      this.fulfillmentId,
      this.price});

  DiscoveryItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descriptor = json['descriptor'] != null
        ? DiscoveryDescriptor.fromJson(json['descriptor'])
        : null;
    categoryId = json['category_id'];
    fulfillmentId = json['fulfillment_id'];
    price =
        json['price'] != null ? DiscoveryPrice.fromJson(json['price']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    if (this.descriptor != null) {
      data['descriptor'] = this.descriptor!.toJson();
    }
    if (this.categoryId != null) {
      data['category_id'] = this.categoryId;
    }
    data['fulfillment_id'] = this.fulfillmentId;
    if (this.price != null) {
      data['price'] = this.price!.toJson();
    }
    return data;
  }
}

class Quantity {
  Available? available;

  Quantity({this.available});

  Quantity.fromJson(Map<String, dynamic> json) {
    available = json['available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['available'] = this.available;
    return data;
  }
}

class Available {
  String? count;
  Available({this.count});

  Available.fromJson(Map<String, dynamic> json) {
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    return data;
  }
}

class DiscoveryPrice {
  String? currency;
  String? value;

  DiscoveryPrice({this.currency, this.value});

  DiscoveryPrice.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['currency'] = this.currency;
    data['value'] = this.value;
    return data;
  }
}

// class DiscoveryFulfillments {
//   String? id;
//   String? type;
//   DiscoveryAgent? agent;
//   DiscoveryStart? start;
//   DiscoveryEnd? end;
//   DiscoveryAgent? person;
//   Tags? tags;

//   DiscoveryFulfillments({
//     this.id,
//     this.type,
//     this.agent,
//     this.start,
//     this.end,
//     this.person,
//   });

//   DiscoveryFulfillments.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     type = json['type'];
//     agent =
//         json['agent'] != null ? DiscoveryAgent.fromJson(json['agent']) : null;
//     start =
//         json['start'] != null ? DiscoveryStart.fromJson(json['start']) : null;
//     end = json['end'] != null ? DiscoveryEnd.fromJson(json['end']) : null;
//     person =
//         json['person'] != null ? DiscoveryAgent.fromJson(json['person']) : null;
//     tags = json['tags'] != null ? Tags.fromJson(json['tags']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['id'] = this.id;
//     data['type'] = this.type;
//     if (this.agent != null) {
//       data['agent'] = this.agent!.toJson();
//     }
//     if (this.start != null) {
//       data['start'] = this.start!.toJson();
//     }
//     if (this.end != null) {
//       data['end'] = this.end!.toJson();
//     }
//     if (this.person != null) {
//       data['person'] = this.person!.toJson();
//     }
//     if (this.tags != null) {
//       data['tags'] = this.tags;
//     }
//     return data;
//   }
// }

class DiscoveryAgent {
  String? id;
  String? name;
  String? gender;
  String? image;
  Tags? tags;

  DiscoveryAgent({this.id, this.name, this.gender, this.image, this.tags});

  DiscoveryAgent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    gender = json['gender'];

    if (json['image'] != null) {
      image = json['image'];
    }
    tags = json['tags'] != null ? new Tags.fromJson(json['tags']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['gender'] = this.gender;
    data['image'] = this.image;
    if (this.image != null) {
      data['image'] = this.image;
    }
    if (this.tags != null) {
      data['tags'] = this.tags!.toJson();
    }
    return data;
  }
}

class Tags {
  String? experience;
  String? specialtyTag;
  String? medicinesTag;
  String? followUp;
  //List<Object?>? languageSpokenTag;
  String? languageSpokenTag;
  String? education;
  String? firstConsultation;
  String? upiId;
  String? slotId;
  String? hprId;

  Tags(
      {this.experience,
      this.specialtyTag,
      this.medicinesTag,
      this.followUp,
      this.languageSpokenTag,
      this.education,
      this.firstConsultation,
      this.upiId,
      this.slotId,
      this.hprId});

  Tags.fromJson(Map<String, dynamic> json) {
    if (json['@abdm/gov/in/education'] != null) {
      education = json['@abdm/gov/in/education'];
    }

    if (json['@abdm/gov/in/experience'] != null) {
      experience = json['@abdm/gov/in/experience'];
    }

    if (json['@abdm/gov/in/speciality'] != null) {
      specialtyTag = json['@abdm/gov/in/speciality'];
    }

    if (json['@abdm/gov/in/follow_up'] != null) {
      followUp = json['@abdm/gov/in/follow_up'];
    }

    if (json['@abdm/gov/in/first_consultation'] != null) {
      firstConsultation = json['@abdm/gov/in/first_consultation'];
    }

    if (json['@abdm/gov/in/languages'] != null) {
      languageSpokenTag = json['@abdm/gov/in/languages'];
    }

    if (json['@abdm/gov/in/system_of_med'] != null) {
      medicinesTag = json['@abdm/gov/in/system_of_med'];
    }
    if (json['@abdm/gov/in/upi_id'] != null) {
      upiId = json['@abdm/gov/in/upi_id'];
    }
    if (json['@abdm/gov.in/slot'] != null) {
      slotId = json['@abdm/gov.in/slot'];
    }

    if (json['@abdm/gov/in/hpr_id'] != null) {
      hprId = json['@abdm/gov/in/hpr_id'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.education != null) {
      data['@abdm/gov/in/education'] = this.education;
    }
    if (this.experience != null) {
      data['@abdm/gov/in/experience'] = this.experience;
    }

    if (this.followUp != null) {
      data['@abdm/gov/in/follow_up'] = this.followUp;
    }
    if (this.firstConsultation != null) {
      data['@abdm/gov/in/first_consultation'] = this.firstConsultation;
    }
    if (this.specialtyTag != null) {
      data['@abdm/gov/in/speciality'] = this.specialtyTag;
    }
    if (this.languageSpokenTag != null) {
      data['@abdm/gov/in/languages'] = this.languageSpokenTag;
    }

    if (this.medicinesTag != null) {
      data['@abdm/gov/in/system_of_med'] = this.medicinesTag;
    }

    if (this.upiId != null) {
      data['@abdm/gov/in/upi_id'] = this.upiId;
    }

    if (this.slotId != null) {
      data['@abdm/gov.in/slot'] = this.slotId;
    }

    if (this.hprId != null) {
      data['@abdm/gov/in/hpr_id'] = this.hprId;
    }

    return data;
  }
}

class DiscoveryStart {
  DiscoveryTime? time;

  DiscoveryStart({
    this.time,
  });

  DiscoveryStart.fromJson(Map<String, dynamic> json) {
    time = json['time'] != null ? DiscoveryTime.fromJson(json['time']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.time != null) {
      data['time'] = this.time!.toJson();
    }

    return data;
  }
}

class DiscoveryEnd {
  DiscoveryTime? time;

  DiscoveryEnd({this.time});

  DiscoveryEnd.fromJson(Map<String, dynamic> json) {
    time = json['time'] != null ? DiscoveryTime.fromJson(json['time']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.time != null) {
      data['time'] = this.time!.toJson();
    }
    return data;
  }
}

class DiscoveryTime {
  String? timestamp;

  DiscoveryTime({this.timestamp});

  DiscoveryTime.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    return data;
  }
}
