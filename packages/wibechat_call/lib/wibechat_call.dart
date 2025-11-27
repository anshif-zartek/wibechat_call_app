export 'src/chat/chat_view.dart';
export 'src/chat/chat_data.dart';
export 'src/chat/chat_theme.dart';
export 'src/chat/message_list.dart';
export 'src/chat/message_input.dart';
import 'package:permission_handler/permission_handler.dart';

class WibeCall {
  Future<void> _checkPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Permission disabled');
    }
    status = await Permission.bluetoothConnect.request();
    if (status.isPermanentlyDenied) {
      print('Bluetooth Connect Permission disabled');
    }
  }

  init(){
    _checkPermissions();
  }





}