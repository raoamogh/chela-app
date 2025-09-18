import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Make sure this is imported
import '../widgets/animated_background.dart';
import '../screens/profile_screen.dart';
import '../screens/timetable_screen.dart'; // Import the new timetable screen
import '../screens/assignment_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0; // State for the selected tab

  // List of screens for the BottomNavigationBar
  // Make sure these match the order of your BottomNavigationBarItems
  final List<Widget> _screens = [
    const Center(child: Text("Home Content (Coming Soon!)", style: TextStyle(color: Colors.white))),
    const TimetableScreen(),
    const AssignmentScreen(), // Our new timetable screen
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows content to go behind the app bar if needed
      body: Stack(
        children: [
          const AnimatedBackground(), // Your animated background widget
          // The IndexedStack keeps all screens alive (maintains state)
          // but only shows the one at _selectedIndex.
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1A1A1A), // Dark background for the bar
        selectedItemColor: Theme.of(context).colorScheme.primary, // Primary color for selected item
        unselectedItemColor: Colors.white54, // Lighter color for unselected items
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded), // Calendar icon for timetable
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: 'Assignments'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}