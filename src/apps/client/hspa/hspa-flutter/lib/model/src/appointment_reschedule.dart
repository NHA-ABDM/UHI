class AppointmentReschedule {
  String name;
  String visitType;
  String originalAppointmentDate;
  String originalAppointmentTime;
  String rescheduleAppointmentDate;
  String rescheduleAppointmentTime;
  String status;

  AppointmentReschedule({
    required this.name,
    required this.visitType,
    required this.originalAppointmentDate,
    required this.originalAppointmentTime,
    required this.rescheduleAppointmentDate,
    required this.rescheduleAppointmentTime,
    required this.status,
  });
}