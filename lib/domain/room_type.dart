enum RoomType {
  shared(4, 6000),
  semiPrivate(2, 10000),
  private(1, 20000),
  vip(1, 30000);

  final int capacity;
  final int centPerDay;

  const RoomType(this.capacity, this.centPerDay);

  String get name => toString().split('.').last;
}