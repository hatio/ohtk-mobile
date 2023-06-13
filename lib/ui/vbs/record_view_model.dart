import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';

class RecordViewModel extends BaseViewModel {
  IReportService reportService = locator<IReportService>();
  IFileService fileService = locator<IFileService>();

  String title = "Record wingbeat XXX";
  String currentReportId = "";

  void submit() async {
    setBusy(true);
    var reportId = const Uuid().v4();
    await reportService.submit(Report(
      id: reportId,
      data: {"name": "xxx", "age": "123"},
      incidentDate: DateTime.now(),
      reportTypeId: "343eaa06-8589-42b2-a621-5b969ae3be70",
      incidentInAuthority: true,
      testFlag: false,
    ));
    setBusy(false);
  }
}
