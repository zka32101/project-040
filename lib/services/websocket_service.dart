/// Phase 31: リアルタイム・WebSocket
import 'dart:async';

enum ConnectionState { connecting, connected, disconnected, error }

abstract class WebSocketService {
  Future<void> connect(String url);
  Future<void> disconnect();
  void send(String message);
  Stream<String> get messageStream;
  ConnectionState get state;
  Future<bool> isConnected();
}

abstract class RealtimeEventBroadcaster {
  void subscribe(String channel, Function(Map<String, dynamic>) callback);
  void unsubscribe(String channel);
  void broadcast(String channel, Map<String, dynamic> data);
  Stream<Map<String, dynamic>> getChannelStream(String channel);
}

class MemoryWebSocketService implements WebSocketService {
  final _controller = StreamController<String>.broadcast();
  ConnectionState _state = ConnectionState.disconnected;

  @override
  Future<void> connect(String url) async {
    _state = ConnectionState.connecting;
    await Future.delayed(Duration(milliseconds: 100));
    _state = ConnectionState.connected;
  }

  @override
  Future<void> disconnect() async {
    _state = ConnectionState.disconnected;
    await _controller.close();
  }

  @override
  void send(String message) {
    if (_state == ConnectionState.connected) {
      _controller.add(message);
    }
  }

  @override
  Stream<String> get messageStream => _controller.stream;

  @override
  ConnectionState get state => _state;

  @override
  Future<bool> isConnected() async => _state == ConnectionState.connected;
}

class MemoryEventBroadcaster implements RealtimeEventBroadcaster {
  final Map<String, StreamController<Map<String, dynamic>>> _channels = {};

  @override
  void subscribe(String channel, Function(Map<String, dynamic>) callback) {
    _getController(channel).stream.listen(callback);
  }

  @override
  void unsubscribe(String channel) {
    _channels[channel]?.close();
    _channels.remove(channel);
  }

  @override
  void broadcast(String channel, Map<String, dynamic> data) {
    _getController(channel).add(data);
  }

  @override
  Stream<Map<String, dynamic>> getChannelStream(String channel) {
    return _getController(channel).stream;
  }

  StreamController<Map<String, dynamic>> _getController(String channel) {
    return _channels.putIfAbsent(
      channel,
      () => StreamController<Map<String, dynamic>>.broadcast(),
    );
  }
}
