import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({super.key});

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController =
  TextEditingController();

  String pickupSearch = '';
  String destinationSearch = '';

  bool isBooking = false;

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  // Only active rides are fetched.
  // No orderBy means no composite index is required.
  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveRides() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  void searchRides() {
    FocusScope.of(context).unfocus();

    setState(() {
      pickupSearch = pickupController.text.trim().toLowerCase();
      destinationSearch =
          destinationController.text.trim().toLowerCase();
    });
  }

  void clearSearch() {
    FocusScope.of(context).unfocus();

    pickupController.clear();
    destinationController.clear();

    setState(() {
      pickupSearch = '';
      destinationSearch = '';
    });
  }

  bool matchesSearch(Map<String, dynamic> ride) {
    final String pickup = (
        ride['pickup'] ??
            ride['fromLocation'] ??
            ride['from'] ??
            ''
    ).toString().toLowerCase();

    final String destination = (
        ride['destination'] ??
            ride['toLocation'] ??
            ride['to'] ??
            ''
    ).toString().toLowerCase();

    final bool pickupMatches =
        pickupSearch.isEmpty || pickup.contains(pickupSearch);

    final bool destinationMatches =
        destinationSearch.isEmpty ||
            destination.contains(destinationSearch);

    return pickupMatches && destinationMatches;
  }

  DateTime getCreatedDate(Map<String, dynamic> ride) {
    final dynamic createdAt = ride['createdAt'];

    if (createdAt is Timestamp) {
      return createdAt.toDate();
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  int getAvailableSeats(Map<String, dynamic> ride) {
    final dynamic seatsValue =
        ride['availableSeats'] ?? ride['seats'] ?? 0;

    if (seatsValue is int) {
      return seatsValue;
    }

    return int.tryParse(seatsValue.toString()) ?? 0;
  }

  Future<void> bookRide({
    required String rideId,
    required Map<String, dynamic> ride,
  }) async {
    if (isBooking) return;

    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      showMessage(
        'Please login before booking a ride.',
        isError: true,
      );
      return;
    }

    final String driverId =
    (ride['userId'] ?? ride['driverId'] ?? '').toString();

    if (driverId.isEmpty) {
      showMessage(
        'Driver information is unavailable.',
        isError: true,
      );
      return;
    }

    if (driverId == currentUser.uid) {
      showMessage(
        'You cannot book your own offered ride.',
        isError: true,
      );
      return;
    }

    setState(() {
      isBooking = true;
    });

    final DocumentReference<Map<String, dynamic>> rideReference =
    _firestore.collection('rides').doc(rideId);

    final DocumentReference<Map<String, dynamic>> bookingReference =
    _firestore.collection('bookings').doc();

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> rideSnapshot =
        await transaction.get(rideReference);

        if (!rideSnapshot.exists) {
          throw Exception('This ride no longer exists.');
        }

        final Map<String, dynamic> latestRide =
        rideSnapshot.data()!;

        final String latestStatus =
        (latestRide['status'] ?? '').toString();

        if (latestStatus != 'active') {
          throw Exception('This ride is no longer active.');
        }

        final int latestSeats = getAvailableSeats(latestRide);

        if (latestSeats <= 0) {
          throw Exception('No seats are available.');
        }

        // Prevent same passenger from booking the same ride again.
        final QuerySnapshot<Map<String, dynamic>> existingBookings =
        await _firestore
            .collection('bookings')
            .where('rideId', isEqualTo: rideId)
            .where('passengerId', isEqualTo: currentUser.uid)
            .limit(1)
            .get();

        if (existingBookings.docs.isNotEmpty) {
          throw Exception(
            'You have already requested this ride.',
          );
        }

        transaction.set(bookingReference, {
          'bookingId': bookingReference.id,
          'rideId': rideId,
          'passengerId': currentUser.uid,
          'passengerEmail': currentUser.email ?? '',
          'passengerName': currentUser.displayName ?? 'Passenger',
          'driverId': driverId,
          'pickup':
          latestRide['pickup'] ??
              latestRide['fromLocation'] ??
              '',
          'destination':
          latestRide['destination'] ??
              latestRide['toLocation'] ??
              '',
          'date': latestRide['date'] ?? '',
          'time': latestRide['time'] ?? '',
          'price': latestRide['price'] ?? 0,
          'seatsBooked': 1,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(rideReference, {
          'seats': latestSeats - 1,
          'availableSeats': latestSeats - 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (!mounted) return;

      showMessage('Ride booking request sent successfully.');
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isBooking = false;
        });
      }
    }
  }

  void showMessage(
      String message, {
        bool isError = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String getStringValue(
      Map<String, dynamic> ride,
      List<String> keys, {
        String fallback = 'Not specified',
      }) {
    for (final String key in keys) {
      final dynamic value = ride[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String formatPrice(dynamic value) {
    if (value == null) return '₹0';

    final num? price = num.tryParse(value.toString());

    if (price == null) return '₹0';

    if (price == price.roundToDouble()) {
      return '₹${price.toInt()}';
    }

    return '₹${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Find Ride',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              22,
            ),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: pickupController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Leaving from',
                    prefixIcon: Icon(
                      Icons.radio_button_checked,
                      color: primaryColor,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF2F1FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: destinationController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => searchRides(),
                  decoration: InputDecoration(
                    hintText: 'Going to',
                    prefixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF2F1FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: primaryColor,
                        width: 1.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: searchRides,
                          icon: const Icon(Icons.search),
                          label: const Text(
                            'SEARCH RIDES',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F1FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: clearSearch,
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child:
            StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>
            >(
              stream: getActiveRides(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load rides',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                final List<
                    QueryDocumentSnapshot<Map<String, dynamic>>
                >
                rides =
                    snapshot.data?.docs.where((document) {
                      return matchesSearch(document.data());
                    }).toList() ??
                        [];

                // Sort newest rides first inside Flutter.
                // This avoids the Firestore composite index.
                rides.sort((first, second) {
                  final DateTime firstDate =
                  getCreatedDate(first.data());

                  final DateTime secondDate =
                  getCreatedDate(second.data());

                  return secondDate.compareTo(firstDate);
                });

                if (rides.isEmpty) {
                  return const _EmptyRideWidget();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.separated(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: rides.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final document = rides[index];

                      final Map<String, dynamic> ride =
                      document.data();

                      final String pickup = getStringValue(
                        ride,
                        const [
                          'pickup',
                          'fromLocation',
                          'from',
                        ],
                      );

                      final String destination =
                      getStringValue(
                        ride,
                        const [
                          'destination',
                          'toLocation',
                          'to',
                        ],
                      );

                      final String driverName =
                      getStringValue(
                        ride,
                        const [
                          'driverName',
                          'userName',
                          'name',
                        ],
                        fallback: 'RideMate Driver',
                      );

                      final String vehicle = getStringValue(
                        ride,
                        const [
                          'vehicle',
                          'vehicleName',
                        ],
                        fallback: 'Vehicle not specified',
                      );

                      final String date = getStringValue(
                        ride,
                        const [
                          'date',
                          'rideDate',
                        ],
                        fallback: 'Date not specified',
                      );

                      final String time = getStringValue(
                        ride,
                        const [
                          'time',
                          'rideTime',
                        ],
                        fallback: 'Time not specified',
                      );

                      final String description =
                      getStringValue(
                        ride,
                        const ['description'],
                        fallback: '',
                      );

                      final int seats =
                      getAvailableSeats(ride);

                      final String currentUserId =
                          _auth.currentUser?.uid ?? '';

                      final String driverId =
                      (ride['userId'] ??
                          ride['driverId'] ??
                          '')
                          .toString();

                      final bool isOwnRide =
                          currentUserId.isNotEmpty &&
                              driverId == currentUserId;

                      return _RideCard(
                        rideId: document.id,
                        pickup: pickup,
                        destination: destination,
                        driverName: driverName,
                        vehicle: vehicle,
                        date: date,
                        time: time,
                        description: description,
                        seats: seats,
                        price: formatPrice(ride['price']),
                        isOwnRide: isOwnRide,
                        isBooking: isBooking,
                        primaryColor: primaryColor,
                        onBook: () {
                          bookRide(
                            rideId: document.id,
                            ride: ride,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final String rideId;
  final String pickup;
  final String destination;
  final String driverName;
  final String vehicle;
  final String date;
  final String time;
  final String description;
  final String price;
  final int seats;
  final bool isOwnRide;
  final bool isBooking;
  final Color primaryColor;
  final VoidCallback onBook;

  const _RideCard({
    required this.rideId,
    required this.pickup,
    required this.destination,
    required this.driverName,
    required this.vehicle,
    required this.date,
    required this.time,
    required this.description,
    required this.price,
    required this.seats,
    required this.isOwnRide,
    required this.isBooking,
    required this.primaryColor,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: primaryColor.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(
                    Icons.person,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              vehicle,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Text(
                  price,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      size: 19,
                      color: primaryColor,
                    ),
                    Container(
                      height: 38,
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pickup,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 23),

                      const Text(
                        'Destination',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        destination,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 9,
              runSpacing: 9,
              children: [
                _RideInfoChip(
                  icon: Icons.calendar_today_outlined,
                  text: date,
                  primaryColor: primaryColor,
                ),
                _RideInfoChip(
                  icon: Icons.access_time,
                  text: time,
                  primaryColor: primaryColor,
                ),
                _RideInfoChip(
                  icon: Icons.event_seat_outlined,
                  text: '$seats seats',
                  primaryColor: primaryColor,
                ),
              ],
            ),

            if (description.trim().isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                isOwnRide || seats <= 0 || isBooking
                    ? null
                    : onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isOwnRide
                      ? 'YOUR OFFERED RIDE'
                      : seats <= 0
                      ? 'NO SEATS AVAILABLE'
                      : isBooking
                      ? 'BOOKING...'
                      : 'BOOK RIDE',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color primaryColor;

  const _RideInfoChip({
    required this.icon,
    required this.text,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: primaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRideWidget extends StatelessWidget {
  const _EmptyRideWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 75,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No active rides found',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try another pickup or destination.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}