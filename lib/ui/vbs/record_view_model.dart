import 'dart:io';

import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/vbs_audio_service.dart';
import 'package:stacked/stacked.dart';
import 'package:uuid/uuid.dart';
// package to record audio
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:fftea/fftea.dart';
import 'dart:typed_data';
// import "dart:io";


class RecordViewModel extends BaseViewModel {
  final IReportService reportService = locator<IReportService>();
  final IFileService fileService = locator<IFileService>();
  final IVbsAudioService vbsAudioService = locator<IVbsAudioService>();

  final stopwatch = Stopwatch();

  String title = "Record wingbeat";
  String currentReportId = "";
  bool isRecording = false;
  final _audioRecorder = Record();

  late Directory directory;
  String recordingDir = "/recording/";
  String customPath = '';
  String extStr = '.m4a';

  RecordViewModel() {
    init();
  }

  init() async {
    directory = await getApplicationDocumentsDirectory(); 
  }


  Future printPath() async {
    var uuid = const Uuid().v4();
    const id = "test";
    const extStr = ".w4a";
    final directory = await getApplicationDocumentsDirectory(); 
    final f = await File('$directory/recordings/$uuid/$id$extStr').create(recursive: true);
    print(f.toString());
  }


  Future start() async {
    setBusy(true);
    
    try {
      // Check and request permission
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        print('${AudioEncoder.aacLc.name} supported: $isSupported');

        final devs = await _audioRecorder.listInputDevices();
        print(devs);

        customPath = directory.path +
          recordingDir +
          DateTime.now().millisecondsSinceEpoch.toString() +
          extStr ;

        await File(customPath).create(recursive: true);

        await _audioRecorder.start(
          path: customPath,
        );
        stopwatch.start();

        isRecording = await _audioRecorder.isRecording();
      }
    } catch (e) {
      print(e);
    }
    setBusy(false);
  }


  // Function to stop recorder
  Future<void> stop() async {
    setBusy(true);

    stopwatch.stop();    
    await _audioRecorder.stop();
    isRecording = false;

    
    print('Miliseconds recorded...');
    print(stopwatch.elapsedMilliseconds); // Likely > 0.

    var uuid = const Uuid().v4();
    var originalFile = await File(customPath);
    var bytes = await originalFile.readAsBytes();
    // convert to 16-bit per sample
    var listInt = bytes.buffer.asUint16List();
    List<double> listFloat = listInt.map((i) => i.toDouble()).toList();

    // run STFT
    int chunkSize = 4096;
    final stft = STFT(chunkSize, Window.hanning(chunkSize));
    var spectrogram = [];
    stft.run(listFloat, (freq) {
      spectrogram.add(freq.discardConjugates().magnitudes());
    });
    
    // index of FFT corresponding to 300Hz
    int iFilter = (300 * spectrogram[0].length / 44100).floor().toInt();
    
    // filter out freq <= 300Hz
    for (var i = 0; i < spectrogram.length; i++ ){
      spectrogram[i].setRange(0, iFilter, List.filled(iFilter + 1, 0.0));
    }
    print(spectrogram);
    print(spectrogram.length);
    print(spectrogram[0].length);


    
    var saveFile = await fileService.newFile(
      uuid, 
      uuid,
      uuid,
      extStr,
      bytes,
      'audio/m4a'
    );
    
    var reportFile = ReportFile(uuid, currentReportId, uuid, customPath, extStr, 'audio/m4a');
    // save to local DB
    await fileService.saveFile(reportFile);
    
    // submit to online server
    await reportService.submit(Report(
      id: uuid,
      data: {
        "houseId": "2",
        "file": {uuid: "$uuid$extStr"}
      },
      incidentDate: DateTime.now(),
      reportTypeId: "343eaa06-8589-42b2-a621-5b969ae3be70",
      incidentInAuthority: true,
      testFlag: false,
    ));
    
    setBusy(false);
  }


}
