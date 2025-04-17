import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

// Events
abstract class PermissionEvent {}

class CheckStoragePermissionEvent extends PermissionEvent {}

// States
abstract class PermissionState {}

class PermissionInitial extends PermissionState {}

class PermissionLoading extends PermissionState {}

class PermissionGranted extends PermissionState {}

class PermissionDenied extends PermissionState {}

class PermissionError extends PermissionState {
  final String message;
  PermissionError(this.message);
}

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<CheckStoragePermissionEvent>(_onCheckStoragePermission);
  }

  Future<void> _onCheckStoragePermission(
    CheckStoragePermissionEvent event,
    Emitter<PermissionState> emit,
  ) async {
    emit(PermissionLoading());
    try {
      if (Platform.isAndroid) {
        // For Android 13 and above
        if (await Permission.manageExternalStorage.isGranted) {
          emit(PermissionGranted());
          return;
        }

        // For Android 10-12
        if (await Permission.storage.isGranted) {
          emit(PermissionGranted());
          return;
        }

        // Request permissions
        final storageStatus = await Permission.storage.request();
        if (storageStatus.isGranted) {
          emit(PermissionGranted());
          return;
        }

        final manageStorageStatus =
            await Permission.manageExternalStorage.request();
        if (manageStorageStatus.isGranted) {
          emit(PermissionGranted());
          return;
        }

        emit(PermissionDenied());
      } else {
        // For iOS
        final status = await Permission.storage.status;
        if (status.isGranted) {
          emit(PermissionGranted());
        } else {
          final result = await Permission.storage.request();
          if (result.isGranted) {
            emit(PermissionGranted());
          } else {
            emit(PermissionDenied());
          }
        }
      }
    } catch (e) {
      emit(PermissionError(e.toString()));
    }
  }
}
