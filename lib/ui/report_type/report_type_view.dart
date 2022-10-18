import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/ui/report/report_form_view.dart';
import 'package:podd_app/ui/report_type/report_type_view_model.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportTypeView extends StatelessWidget {
  const ReportTypeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReportTypeViewModel>.nonReactive(
      viewModelBuilder: () => ReportTypeViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.reportTypeTitle),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await viewModel.syncReportTypes();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              _ZeroReport(),
              Expanded(child: _Listing()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZeroReport extends HookViewModelWidget<ReportTypeViewModel> {
  final formatter = DateFormat('dd/MM/yyyy HH:mm');

  _ZeroReport({Key? key}) : super(key: key);

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportTypeViewModel viewModel) {
    return InkWell(
      onTap: () async {
        await viewModel.submitZeroReport();
        var showSuccessMessage = SnackBar(
          content: Text(AppLocalizations.of(context)?.zeroReportSubmitSuccess ??
              'Zero report submit success'),
          backgroundColor: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(showSuccessMessage);
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.shade400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)?.zeroReportLabel ?? "Zero report",
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            FutureBuilder<DateTime?>(
              future: viewModel.getLatestZeroReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    var dateTimeString =
                        formatter.format(snapshot.data!.toLocal());
                    return Text(
                      AppLocalizations.of(context)!
                          .zeroReportLastReportedMessage(dateTimeString),
                      textScaleFactor: 0.8,
                      style: const TextStyle(color: Colors.white),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Listing extends HookViewModelWidget<ReportTypeViewModel> {
  final Logger logger = locator<Logger>();

  @override
  Widget buildViewModelWidget(
      BuildContext context, ReportTypeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (context, categoryIndex) =>
            viewModel.categories[categoryIndex].reportTypes.isNotEmpty
                ? _category(context, viewModel, categoryIndex)
                : Container(),
        itemCount: viewModel.categories.length,
      ),
    );
  }

  _category(
      BuildContext context, ReportTypeViewModel viewModel, int categoryIndex) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              viewModel.categories[categoryIndex].category.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, reportTypeIndex) {
            var reportType = viewModel
                .categories[categoryIndex].reportTypes[reportTypeIndex];
            return ListTile(
              title: Text(reportType.name),
              onTap: () async {
                var allow = await viewModel.createReport(reportType.id);
                if (allow) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportFormView(reportType),
                    ),
                  ).then((value) => {logger.d("back from from $value")});
                }
              },
              trailing: const Icon(Icons.arrow_forward_ios),
            );
          },
          itemCount: viewModel.categories[categoryIndex].reportTypes.length,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
        )
      ],
    );
  }
}
