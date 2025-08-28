sealed class ApiState<T> {}

class ApiStateInitial<T> extends ApiState<T> {}

class ApiStateLoading<T> extends ApiState<T> {}

class ApiStateSuccess<T> extends ApiState<T> {
  final T data;
  ApiStateSuccess(this.data);
}

class ApiStateError<T> extends ApiState<T> {
  final String message;
  ApiStateError(this.message);
}
