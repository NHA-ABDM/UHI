import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../constants/src/strings.dart';
import '../../../controller/src/account_statement_controller.dart';
import '../../../model/request/src/provider_service_type.dart';
import '../../../model/response/src/payment_status_response.dart';
import '../../../model/src/doctor_profile.dart';
import '../../../theme/src/app_colors.dart';
import '../../../theme/src/app_text_style.dart';
import 'package:get/get.dart';

import '../../../utils/src/utility.dart';
import '../../../widgets/src/spacing.dart';
import '../../../widgets/src/vertical_spacing.dart';

class AccountStatementPage extends StatefulWidget {
  const AccountStatementPage({Key? key}) : super(key: key);

  @override
  State<AccountStatementPage> createState() => _AccountStatementPageState();
}

class _AccountStatementPageState extends State<AccountStatementPage> {
  /// Arguments
  late final bool isTeleconsultation;
  late final ProviderServiceTypes providerServiceTypes;
  late AccountStatementController _accountStatementController;
  bool isLoading = false;

  @override
  void initState() {
    /// Get Arguments
    isTeleconsultation = Get.arguments['isTeleconsultation'];
    providerServiceTypes = Get.arguments['providerServiceTypes'];

    _accountStatementController = AccountStatementController();
    getAccountStatements();
    super.initState();
  }

  Future<void> getAccountStatements() async {
    try {
      setState(() {
        isLoading = true;
      });
      DoctorProfile? doctorProfile = await DoctorProfile.getSavedProfile();
      await _accountStatementController.getAccountStatements(
          hprAddress: doctorProfile!.hprAddress!, fromDate: null, toDate: null);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(
          'GET Provider Account Statements exception is ${e.toString()}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.appBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.appBackgroundColor,
          shadowColor: Colors.black.withOpacity(0.1),
          titleSpacing: 0,
          title: Text(
            AppStrings().accountStatement,
            style: AppTextStyle.textBoldStyle(
                color: AppColors.black, fontSize: 18),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody() {
    return RefreshIndicator(
      onRefresh: () {
        return getAccountStatements();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _accountStatementController.listPaymentStatus.isNotEmpty
                ? showProviderAccountStatements()
                : SizedBox(
                    height: MediaQuery.of(context).size.height - 96,
                    child: Center(
                      child: Text(
                        AppStrings().errorNoAccountStatements,
                        style: AppTextStyle.textBoldStyle(
                            fontSize: 16, color: AppColors.tileColors),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  showProviderAccountStatements() {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        itemCount: _accountStatementController.listPaymentStatus.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return buildListItem(
              paymentStatus:
                  _accountStatementController.listPaymentStatus[index]);
        });
  }

  Widget buildListItem({required PaymentStatus paymentStatus}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(top: 2, left: 8, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        paymentStatus.patientName ?? '-',
                        style: AppTextStyle.textSemiBoldStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                      const Spacing(),
                      Text(
                        Utility.getAppointmentDisplayDate(
                            date: DateTime.parse(
                                paymentStatus.serviceFulfillmentStartTime!)),
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.testColor, fontSize: 16),
                      ),
                    ],
                  ),
                  VerticalSpacing(
                    size: 6,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        paymentStatus.serviceFulfillmentType ?? '',
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.testColor, fontSize: 12),
                      ),
                      const Spacing(),
                      Text(
                        Utility.getAppointmentDisplayTimeRange(
                            startDateTime: DateTime.parse(paymentStatus
                                .serviceFulfillmentStartTime!
                                .split('.')
                                .first),
                            endDateTime: DateTime.parse(paymentStatus
                                .serviceFulfillmentEndTime!
                                .split('.')
                                .first)),
                        style: AppTextStyle.textNormalStyle(
                            color: AppColors.testColor, fontSize: 12),
                      ),
                    ],
                  ),
                  VerticalSpacing(size: 16,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.rupeeSymbol} ' + (paymentStatus.payment?.consultationCharge ?? ' - '),
                            style: AppTextStyle.textSemiBoldStyle(
                                color: AppColors.testColor, fontSize: 18),
                          ),
                          VerticalSpacing(size: 4,),
                          Text(
                            (paymentStatus.payment?.transactionState != null &&
                                    paymentStatus.payment!.transactionState!
                                            .toLowerCase() ==
                                        'paid')
                                ? AppStrings().paymentReceived
                                : AppStrings().paymentPending,
                            style: AppTextStyle.textSemiBoldStyle(
                                color: (paymentStatus.payment?.transactionState != null &&
                                    paymentStatus.payment?.transactionState!
                                        .toLowerCase() ==
                                        'paid')
                                    ? AppColors.paymentReceivedTextColor
                                    : AppColors.paymentPendingTextColor, fontSize: 12),
                          ),
                        ],
                      ),
                      const Spacing(),
                    ],
                  ),
                  VerticalSpacing()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
