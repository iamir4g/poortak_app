import 'package:equatable/equatable.dart';
import 'package:poortak/featueres/fetures_sayareh/data/models/dictionary_model.dart';

abstract class DictionaryState extends Equatable {
  const DictionaryState();
  
  @override
  List<Object> get props => [];
}

class DictionaryInitial extends DictionaryState {}

class DictionaryLoading extends DictionaryState {}

class DictionaryLoaded extends DictionaryState {
  final DictionaryEntry entry;

  const DictionaryLoaded(this.entry);

  @override
  List<Object> get props => [entry];
}

class DictionaryError extends DictionaryState {
  final String message;

  const DictionaryError(this.message);

  @override
  List<Object> get props => [message];
}

class DictionaryEmpty extends DictionaryState {}
