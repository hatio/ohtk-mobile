import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/ui/vbs/record_view_model.dart';
import 'package:stacked/stacked.dart';

class RecordView extends StatelessWidget {
  const RecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RecordViewModel>.reactive(
      viewModelBuilder: () => RecordViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Record'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(model.title),
              ElevatedButton(
                  onPressed: () {
                    model.submit();
                  },
                  child: const Text('Submit..xxx')),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).push('/myprofile');
                },
                child: const Text('Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
