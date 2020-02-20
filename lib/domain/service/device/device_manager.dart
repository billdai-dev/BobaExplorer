abstract class IDeviceManager {
  Future<String> getAppVersion();

  Future<bool> shouldRemindRating();

  Future<void> answerRatingReminder(bool rated);
}
