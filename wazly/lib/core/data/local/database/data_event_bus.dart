import 'dart:async';

enum DataChangeType {
  personUpdated,
  transactionUpdated,
  treasuryUpdated,
  installmentUpdated,
  globalReload,
}

class DataChangeEvent {
  final DataChangeType type;
  final String? personId;

  const DataChangeEvent(this.type, {this.personId});
}

class DataEventBus {
  final _controller = StreamController<DataChangeEvent>.broadcast();

  Stream<DataChangeEvent> get stream => _controller.stream;

  void emit(DataChangeEvent event) {
    if (!_controller.isClosed) {
      _controller.sink.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}
