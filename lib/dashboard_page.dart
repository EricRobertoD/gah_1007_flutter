import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gah_1007_flutter/global_variable.dart';
import 'package:gah_1007_flutter/landing_page.dart';
import 'package:gah_1007_flutter/login_page.dart';
import 'package:gah_1007_flutter/pembatalan_page.dart';
import 'package:gah_1007_flutter/profile_page.dart';
import 'package:gah_1007_flutter/register_page.dart';
import 'package:gah_1007_flutter/riwayat_page.dart';
import 'package:gah_1007_flutter/reservasi_page.dart';
import 'package:gah_1007_flutter/pembatalan_page.dart';
import 'package:gah_1007_flutter/laporan_page.dart';

class Dashboard extends StatefulWidget {  

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  List<Widget> _pages = [];

  String role = '';

  @override
  void initState() {
    super.initState();
    _setupPages();
  }

  String checkRole() {
    if(GLOBALVARIABLES.role == 'Customer'){
      return role = 'Customer';
    } else if(GLOBALVARIABLES.role == '1'){
      return role = 'Owner';
    } else if(GLOBALVARIABLES.role == '2'){
      return role = 'GM';
    }

    return role = 'NULL';
  }

void _setupPages() {
  if (checkRole() == 'Customer') {
    _pages = [
      RiwayatPage(token: GLOBALVARIABLES.token),
      ReservasiPage(token: GLOBALVARIABLES.token),
      PembatalanPage(token: GLOBALVARIABLES.token),
      ProfilePage(token: GLOBALVARIABLES.token),
    ];
  } else if (checkRole() == 'Owner') {
    _pages = [
      ProfilePage(token: GLOBALVARIABLES.token),
      LaporanPage(token: GLOBALVARIABLES.token),
    ];
  } else if (checkRole() == 'GM') {
    _pages = [
      ProfilePage(token: GLOBALVARIABLES.token),
      LaporanPage(token: GLOBALVARIABLES.token),
    ];
  } else {
    _pages = [
      ProfilePage(token: GLOBALVARIABLES.token),
      // Add other pages as needed
    ];
  }
}

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
List<BottomNavigationBarItem> _bottomNavbarItems() {
  if (checkRole() == 'Customer') {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Booking',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        label: 'Reservasi',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        label: 'Pembatalan',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  } else if (checkRole() == 'Owner') {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'OWNER',
      ),
      
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Laporan',
      ),
    ];
  } else if (checkRole() == 'GM') {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'General Manager',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Laporan',
      ),
      // Add other items as needed
    ];
  } else {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Selain Owner Dan GM',
      ),
      // Add other items as needed
    ];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: _bottomNavbarItems(),
      ),
    );
  }
}