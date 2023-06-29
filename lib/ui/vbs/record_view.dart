import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:podd_app/services/vbs_audio_service.dart';
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
              if (!model.isRecording)
                ElevatedButton(
                  onPressed: () {
                    model.start();
                  },
                  child: const Text('Start recording'),
                  style: ElevatedButton.styleFrom(
                  primary: Colors.black, // Background color
                  )),

              if (model.isRecording)
                ElevatedButton(
                  onPressed: () {
                    model.stop();
                  },
                  child: const Text('Stop recording'),                
                  style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 235, 12, 12), // Background color
                  )),

              ElevatedButton(
                onPressed: () {
                  model.printPath();
                },
                child: const Text('Print path')),

              SizedBox(
                height: 200,
                child: FutureBuilder(
                  future: model.vbsAudioService.getProcessedFiles(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData){
                      return ListView.builder(itemBuilder:(context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].path),
                        );
                      },
                      itemCount: snapshot.data != null ? snapshot.data!.length : 0,
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),

              // ElevatedButton(
              //   onPressed: () {
              //     GoRouter.of(context).push('/myprofile');
              //   },
              //   child: const Text('Profile'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

