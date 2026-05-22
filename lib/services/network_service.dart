import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkStatus {
  final String connection;
  final String? publicIp;

  NetworkStatus({
    required this.connection,
    this.publicIp,
  });
}

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Future<NetworkStatus> snapshot() async {
    // 1) Check connectivity type
    final result = await _connectivity.checkConnectivity();
    print('Connectivity result: $result');

    String connLabel = 'Mobile Data';
    
 
    String? ip;
    try {
      final resp = await http.get(Uri.parse('https://api.ipify.org'));
      print('IP status: ${resp.statusCode}');
      print('IP body: ${resp.body}');
      if (resp.statusCode == 200) {
        ip = resp.body.trim();
      }
    } catch (e) {
      print('IP error: $e');
    }

    return NetworkStatus(connection: connLabel, publicIp: ip);
  }
}