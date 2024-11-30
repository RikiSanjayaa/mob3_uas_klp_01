import 'package:random_avatar/random_avatar.dart';

getRandomAvatar() {
  return RandomAvatarString(
    DateTime.now().toIso8601String(),
    trBackground: false,
  );
}
