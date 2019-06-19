abstract class BookBikeState {}

class BookingReady extends BookBikeState {}

class BookingLoading extends BookBikeState {}

class BookingDone extends BookBikeState {}

class BookingError extends BookBikeState {}

class CloseBookingPage extends BookBikeState {}