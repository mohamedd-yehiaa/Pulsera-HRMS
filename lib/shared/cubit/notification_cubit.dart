import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulsera/models/notification_model.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/network/remote/notification_repository.dart';

class NotificationCubit extends Cubit<NotificationStates> {
  NotificationCubit(this._repository) : super(NotificationInitialState());

  static NotificationCubit get(context) => BlocProvider.of(context);

  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  /// Starts a real-time stream of notifications for [userId].
  void init(String userId) {
    _subscription?.cancel();

    _subscription = _repository.watchNotifications(userId).listen(
      (result) {
        notifications = result;
        unreadCount = result.where((n) => !n.isRead).length;
        emit(NotificationsLoadedState());
      },
      onError: (error) {
        print('Notification stream error: $error');
        emit(NotificationStreamErrorState(error.toString()));
      },
    );
  }

  /// Marks a notification as read and updates local state.
  void markRead(String notificationId) {
    _repository.markNotificationRead(notificationId).then((_) {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index].isRead = true;
        unreadCount = notifications.where((n) => !n.isRead).length;
      }
      emit(NotificationMarkedReadState());
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
