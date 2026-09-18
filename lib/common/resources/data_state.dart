abstract class DataState<T> {
  final T? data;
  final String? error;
  final String? errorCode;

  const DataState(this.data, this.error, [this.errorCode]);
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess([T? data]) : super(data, null);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(String error, {String? errorCode})
      : super(null, error, errorCode);
}
