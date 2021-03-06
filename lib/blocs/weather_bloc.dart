import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:isolate_bloc/isolate_bloc.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/repositories/repositories.dart';

class WeatherBloc extends IsolateBloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({@required this.weatherRepository})
      : assert(weatherRepository != null),
        super(WeatherInitial());

  @override
  void onEventReceived(WeatherEvent event) {
    if (event is WeatherRequested) {
      _weatherRequested(event);
    } else if (event is WeatherRefreshRequested) {
      _weatherRefreshRequested(event);
    }
  }

  Future<void> _weatherRequested(WeatherRequested event) async {
    emit(WeatherLoadInProgress());
    try {
      final Weather weather = await weatherRepository.getWeather(event.city);
      emit(WeatherLoadSuccess(weather: weather));
    } catch (_) {
      emit(WeatherLoadFailure());
    }
  }

  Future<void> _weatherRefreshRequested(WeatherRefreshRequested event) async {
    try {
      final Weather weather = await weatherRepository.getWeather(event.city);
      emit(WeatherLoadSuccess(weather: weather));
    } catch (_) {}
  }
}

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}

class WeatherRequested extends WeatherEvent {
  final String city;

  const WeatherRequested({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

class WeatherRefreshRequested extends WeatherEvent {
  final String city;

  const WeatherRefreshRequested({@required this.city}) : assert(city != null);

  @override
  List<Object> get props => [city];
}

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoadInProgress extends WeatherState {}

class WeatherLoadSuccess extends WeatherState {
  final Weather weather;

  const WeatherLoadSuccess({@required this.weather}) : assert(weather != null);

  @override
  List<Object> get props => [weather];
}

class WeatherLoadFailure extends WeatherState {}
