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
// package to play audio
import 'package:audioplayers/audioplayers.dart';




class RecordViewModel extends BaseViewModel {
  final IReportService reportService = locator<IReportService>();
  final IFileService fileService = locator<IFileService>();
  final IVbsAudioService vbsAudioService = locator<IVbsAudioService>();

  final stopwatch = Stopwatch();

  String title = "Record wingbeat";
  String currentReportId = "";
  bool isRecording = false;
  final _audioRecorder = AudioRecorder();
  final player = AudioPlayer();

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
        print(customPath);

        await File(customPath).create(recursive: true);
        
        await _audioRecorder.start(const RecordConfig(), path: customPath);
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
    print(listFloat);
    print(listFloat.length);


    // // run STFT .......
    // int chunkSize = 4096;
    // final stft = STFT(chunkSize, Window.hanning(chunkSize));
    // var spectrogram = [];
    // stft.run(listFloat, (freq) {
    //   // spectrogram.add(freq.discardConjugates().magnitudes());
    //   spectrogram.add(freq.discardConjugates());
    // });
    
    // // index of FFT corresponding to 300Hz
    // int iFilter = stft.indexOfFrequency(300, 44100).floor().toInt();
    
    // // set values at freq <= 300Hz to zero
    // final fft = FFT(spectrogram[0].length);
    // for (var i = 0; i < spectrogram.length; i++ ){
    //   spectrogram[i].setRange(0, iFilter, Float64x2List(iFilter + 1));
    //   // fft.inPlaceInverseFft(spectrogram[i].createConjugates());
    //   Float64x2List.fromList(spectrogram[i]).createConjugates(spectrogram[i] * 2)
    // }
    // .....................
    



    // final fft = FFT(listFloat.length);
    // final freq = fft.realFft(listFloat);

    // List<int> listFiltered = fft.realInverseFft(freq).map((i) => i.toInt()).toList();
    // // List<int> listFiltered = listFloat.map((i) => i.toInt()).toList();    
    // await originalFile.writeAsBytes(
    //   Uint8List.view(Uint16List.fromList(listFiltered).buffer)  
    // );
    // bytes = await originalFile.readAsBytes();
    
    // print(Uint16List.sublistView(fft.realInverseFft(freq)));

    // print(Uint16List.sublistView(fft.realInverseFft(freq.discardConjugates().createConjugates(freq.length))));

    // // test converting back and forth
    // final fft = FFT(spectrogram[0].length);
    // for (var i = 0; i < spectrogram.length; i++ ){
    //   fft.inPlaceInverseFft(spectrogram[i].createConjugates(spectrogram[i].length * 2));
    // }
    // print(spectrogram);
    // print(spectrogram.length);
    // print(spectrogram[0].length);
    
    
    
    
    
    
    // // .... keep below
    
    // // convert back to bytes for playback
    // List<int> listFiltered = listFloat.map((i) => i.toInt()).toList();       
    
    // // play recording
    await player.play(BytesSource(bytes));
    // await player.play(BytesSource(Uint8List.view(Uint16List.fromList(listFiltered).buffer)));
    // await player.play(DeviceFileSource(customPath));
    
    

    
    // var saveFile = await fileService.newFile(
    //   uuid, 
    //   uuid,
    //   uuid,
    //   extStr,
    //   bytes,
    //   'audio/m4a'
    // );
    
    // var saveFile = await fileService.createLocalFileInAppDirectory(
    //   currentReportId, uuid, extStr
    // );
    
    // var reportFile = ReportFile(uuid, currentReportId, uuid, customPath, extStr, 'audio/m4a');
    // // save to local DB
    // await fileService.saveReportFile(reportFile);
    
    // // submit to online server
    // await reportService.submit(Report(
    //   id: uuid,
    //   data: {
    //     "houseId": "2",
    //     "file": {uuid: "$uuid$extStr"}
    //   },
    //   incidentDate: DateTime.now(),
    //   reportTypeId: "343eaa06-8589-42b2-a621-5b969ae3be70",
    //   incidentInAuthority: true,
    //   testFlag: false,
    // ));
    
    setBusy(false);
  }


}
