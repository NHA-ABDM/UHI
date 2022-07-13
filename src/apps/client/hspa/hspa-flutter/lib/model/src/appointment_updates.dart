class AppointmentUpdates {
  late DateTime updateDateTime;
  late String updateDetails;
  late String? status;

  AppointmentUpdates({required this.updateDateTime, required this.updateDetails, this.status});
}