enum RoomType {
  Shared(4, 6000),
  SemiPrivate(2, 10000),
  Private(1, 20000),
  VIP(1, 30000);

  final int capacity;
  final int centPerDay;

  const RoomType(this.capacity, this.centPerDay);

  String get name => toString().split('.').last;
}