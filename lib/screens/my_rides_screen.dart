import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0C29), Color(0xFF302B63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('My Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          bottom: TabBar(
            indicatorColor: const Color(0xFF9D8FFF),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.outbox_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('I am Leading'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.move_to_inbox_rounded, size: 18),
                    SizedBox(width: 6),
                    Text('I joined'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RideList(isLeader: true),
            RideList(isLeader: false),
          ],
        ),
      ),
    );
  }
}

class RideList extends StatelessWidget {
  final bool isLeader;
  const RideList({super.key, required this.isLeader});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    final query = isLeader
        ? FirebaseFirestore.instance.collection('rides').where('leaderId', isEqualTo: user.uid)
        : FirebaseFirestore.instance.collection('rides').where('participants', arrayContains: user.uid);

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
        }
        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLeader ? Icons.drive_eta_rounded : Icons.person_search_rounded,
                    size: 42,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isLeader ? 'No rides posted yet' : 'No joined rides yet',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F0C29)),
                ),
                const SizedBox(height: 6),
                Text(
                  isLeader ? 'Head back and post your first ride!' : 'Find an open ride and join it!',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (ctx, index) {
            final ride = docs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLeader
                          ? [const Color(0xFF6C63FF), const Color(0xFFB06AB3)]
                          : [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isLeader ? Icons.drive_eta_rounded : Icons.person_pin_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  '${ride['source']} → ${ride['destination']}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F0C29)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(ride['leaderName'], style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF6C63FF), size: 18),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ChatScreen(
                        rideId: ride.id,
                        rideDestination: ride['destination'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}