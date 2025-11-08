import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/office_space_model.dart';
import '../models/product_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser(
        uid: uid,
        email: doc.data()!['email'] ?? '',
        role: doc.data()!['role'] ?? 'Customer', // Default to customer
      );
    }
    return null;
  }

  // Add a new office space to Firestore
  Future<void> addOfficeSpace(OfficeSpace officeSpace) {
    return _db.collection('office_spaces').add(officeSpace.toMap());
  }

  // Get a stream of office spaces from Firestore
  Stream<List<OfficeSpace>> getOfficeSpaces() {
    return _db.collection('office_spaces').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => OfficeSpace.fromFirestore(doc)).toList());
  }

  // Add a new product to Firestore
  Future<void> addProduct(Product product) {
    return _db.collection('products').add(product.toMap());
  }

  // Get a stream of products from Firestore
  Stream<List<Product>> getProducts() {
    return _db.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Add a new booking, ensuring no conflicts
  Future<void> addBooking(Booking booking) {
    final bookingRef = _db.collection('bookings');

    return _db.runTransaction((transaction) async {
      // Query for conflicting bookings
      final conflictingBookings = await bookingRef
          .where('officeSpaceId', isEqualTo: booking.officeSpaceId)
          .where('startTime', isLessThan: booking.endTime)
          .where('endTime', isGreaterThan: booking.startTime)
          .get();

      if (conflictingBookings.docs.isNotEmpty) {
        // If there are any conflicting bookings, throw an error
        throw Exception('This time slot is no longer available.');
      }

      // If no conflicts, add the new booking
      transaction.set(bookingRef.doc(), booking.toMap());
    });
  }

  // Get a stream of bookings for a specific user
  Stream<List<Booking>> getBookingsForUser(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }
}
