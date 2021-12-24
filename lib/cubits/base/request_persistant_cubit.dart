import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:the_movie_db_flutter/cubits/index.dart';
import 'package:the_movie_db_flutter/repositories/index.dart';

abstract class RequestPersistantCubit<R extends BaseRepository, T> extends RequestCubit<R, T> with HydratedMixin {
  RequestPersistantCubit(R repository) : super(repository) {
    hydrate();
  }

  @override
  RequestState<T> fromJson(Map<String, dynamic> json) {
    return RequestState<T>.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(RequestState<T> state) {
    return state.toJson();
  }
}
