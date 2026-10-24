import 'package:equatable/equatable.dart';

import '../error/failures.dart';

enum ApiStatus { initial, loading, success, error }

class Resource<E> extends Equatable {
  final E? data;
  final Failure? failure; // ✅ Holds the Failure/Enum directly
  final ApiStatus status;

  const Resource(this.status, this.data, this.failure);

  const Resource.loading({this.data})
    : status = ApiStatus.loading,
      failure = null;

  const Resource.success(this.data)
    : status = ApiStatus.success,
      failure = null;

  const Resource.error(this.failure, {this.data}) : status = ApiStatus.error;

  const Resource.initial()
    : status = ApiStatus.initial,
      data = null,
      failure = null;

  bool get isSuccess => status == ApiStatus.success;
  bool get isLoading => status == ApiStatus.loading;
  bool get isError => status == ApiStatus.error;
  bool get isInitial => status == ApiStatus.initial;

  @override
  List<Object?> get props => [status, data, failure];
}
