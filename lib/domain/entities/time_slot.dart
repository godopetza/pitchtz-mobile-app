/// A bookable hour on the detail screen's time grid.
class TimeSlot {
  const TimeSlot({
    required this.hour,
    required this.available,
    required this.peak,
    required this.price,
  });

  final int hour; // 24h
  final bool available;
  final bool peak; // 7–10 PM premium pricing
  final int price;
}

/// A named group of slots (Morning / Afternoon / Evening).
class SlotGroup {
  const SlotGroup({required this.name, required this.slots});
  final String name;
  final List<TimeSlot> slots;
}
