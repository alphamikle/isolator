import 'dart:isolate';
import 'dart:typed_data';

abstract class Transferable {
  List<Object?> get props;
  List<TypedData> toTypedData();
  TransferableTypedData toTransferableTypedData() {
    throw UnimplementedError();
  }
}
