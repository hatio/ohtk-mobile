import 'dart:io';
import 'package:path_provider/path_provider.dart';

abstract class IVbsAudioService {
  submit();
  
  
  Future<List<FileSystemEntity>> getProcessedFiles();
}

class VbsAudioService implements IVbsAudioService {
  
  late Directory directory;
  String recordingDir = "/recording/";
  String customPath = '';
  String extStr = '.m4a';

  VbsAudioService() {
    init();
  }

  init() async {
    directory = await getApplicationDocumentsDirectory(); 
  }
  
  @override
  submit() {}
  
  @override
  Future<List<FileSystemEntity>> getProcessedFiles() async {
    return directory.listSync();
    // return ["1", "2"];
  }
}