import '../views/dashboard_stats_widgets/booking_stats_chart.dart';
import 'dashboard_controller.dart';

extension DashboardChartsExtension on DashboardController {

  void initBookingStatusData() {
    // Data is now computed from API in _computeBookingStatusData()
    // This is kept for backward compatibility - no-op if data already exists
  }

  void toggleBookingStatus(String label) {
    if (selectedStatus.value == label) {
      selectedStatus.value = null;
    } else {
      selectedStatus.value = label;
    }
  }

  List<BookingStatusData> get filteredBookingStatusData {
    if (selectedStatus.value == null) {
      return bookingStatusData;
    }
    return bookingStatusData
        .where((e) => e.label == selectedStatus.value)
        .toList();
  }
}
