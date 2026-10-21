sealed class Countdown {
  const Countdown();

  factory Countdown.at(DateTime start, DateTime now) {
    final difference = start.difference(now);
    if (!difference.isNegative) return Upcoming(difference);
    final elapsed = now.difference(start);
    if (elapsed < const Duration(hours: 1)) return Started(elapsed);
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.remaining);
  final Duration remaining;
}

final class Started extends Countdown {
  const Started(this.elapsed);
  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

String countdownLabel(Countdown countdown) => switch (countdown) {
  Upcoming(:final remaining) when remaining.inDays > 0 =>
    'In ${remaining.inDays} days',
  Upcoming(:final remaining) when remaining.inHours > 0 =>
    'In ${remaining.inHours} hours',
  Upcoming(:final remaining) => 'In ${remaining.inMinutes} min',
  Started(:final elapsed) => 'Started ${elapsed.inMinutes} min ago',
  Ended() => 'Ended',
};
