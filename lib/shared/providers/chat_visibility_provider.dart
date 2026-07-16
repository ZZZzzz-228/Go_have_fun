import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Becomes true once two users have "seen" each other and started a
/// conversation. Controls whether the "Чаты" tab appears in the bottom
/// navigation bar (it is not a permanent tab).
final chatVisibilityProvider = StateProvider<bool>((ref) => false);
