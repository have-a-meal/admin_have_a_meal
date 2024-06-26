import 'dart:convert';

import 'package:admin_have_a_meal/constants/http_ip.dart';
import 'package:admin_have_a_meal/features/account/sign_in_screen.dart';
import 'package:admin_have_a_meal/features/qr/widgets/menu_time.dart';
import 'package:admin_have_a_meal/models/menu_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MenuSelectScreen extends StatefulWidget {
  static const routeName = "menuSelect";
  static const routeURL = "/menuSelect";
  const MenuSelectScreen({super.key});

  @override
  State<MenuSelectScreen> createState() => _MenuSelectScreenState();
}

class _MenuSelectScreenState extends State<MenuSelectScreen> {
  Map<String, Map<String, List<MenuModel>>> _menuMap = {
    "조식": {
      "A": [],
      "B": [],
      "C": [],
    },
    "중식": {
      "A": [],
      "B": [],
      "C": [],
    },
    "석식": {
      "A": [],
      "B": [],
      "C": [],
    },
  };

  bool _isFirstLoading = false;
  // 현재 날짜를 저장할 변수
  DateTime _selectedDate = DateTime.now();
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _initMenu();
  }

  Future<void> _initMenu() async {
    setState(() {
      _isFirstLoading = true;
    });

    _menuMap = {
      "조식": {
        "A": [],
        "B": [],
        "C": [],
      },
      "중식": {
        "A": [],
        "B": [],
        "C": [],
      },
      "석식": {
        "A": [],
        "B": [],
        "C": [],
      },
    };

    final url = Uri.parse(
        "${HttpIp.apiUrl}/menu/${DateFormat('yyyy-MM-dd', 'ko_KR').format(_selectedDate)}");
    final response = await http.get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonResponse = jsonDecode(response.body) as List<dynamic>;

        if (jsonResponse.isNotEmpty) {
          _addMenuData(jsonResponse);
        } else {
          if (kDebugMode) {
            print("응답 데이터가 비어 있습니다.");
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("JSON 파싱 오류: $e");
        }
      }
    } else {
      if (!mounted) return;
      HttpIp.errorPrint(
        context: context,
        title: "통신 오류",
        message: response.body,
      );
    }

    setState(() {
      _isFirstLoading = false;
    });
  }

  // 데이터를 _menuMap에 추가하는 함수
  void _addMenuData(List<dynamic> data) {
    setState(() {
      for (var item in data) {
        MenuModel menu = MenuModel.fromJson(item);
        String timing = menu.timing;
        String courseKey = menu.courseType;

        if (_menuMap.containsKey(timing) &&
            _menuMap[timing]!.containsKey(courseKey)) {
          _menuMap[timing]![courseKey]!.add(menu);
        }
      }
    });
  }

  // 날짜 선택기를 띄우고 사용자가 날짜를 선택하면 해당 날짜로 변수를 업데이트하는 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year, now.month, now.day); // 오늘 날짜
    int daysUntilNextSunday = 7 - now.weekday + 7; // 다음주 일요일까지의 일수
    final DateTime lastDate = DateTime(
        now.year, now.month, now.day + daysUntilNextSunday); // 선택 가능한 늦은 날짜

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // 초기 선택 날짜
      firstDate: firstDate, // 선택 가능한 가장 이른 날짜
      lastDate: lastDate, // 선택 가능한 가장 늦은 날짜
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _initMenu();
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isFirstLoading = true;
    });

    _selectedDate = DateTime.now();
    _now = DateTime.now();
    _menuMap = {
      "조식": {
        "A": [],
        "B": [],
        "C": [],
      },
      "중식": {
        "A": [],
        "B": [],
        "C": [],
      },
      "석식": {
        "A": [],
        "B": [],
        "C": [],
      },
    };

    await _initMenu();

    setState(() {
      _isFirstLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 30,
        title: const Text(
          "Have-A-Meal",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(SignInScreen.routeName),
            icon: const Icon(Icons.logout),
            iconSize: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: DateTime(_selectedDate.year, _selectedDate.month,
                            _selectedDate.day) ==
                        DateTime(_now.year, _now.month, _now.day)
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year,
                              _selectedDate.month, _selectedDate.day - 1);
                          _initMenu();
                        });
                      },
                icon: const Icon(Icons.chevron_left_rounded),
                color: Colors.black,
                iconSize: 32,
              ),
              TextButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 32,
                  color: Colors.black,
                ),
                label: Text(
                  DateFormat('yyyy-MM-dd(E)', 'ko_KR').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: DateTime(_selectedDate.year, _selectedDate.month,
                            _selectedDate.day) ==
                        DateTime(_now.year, _now.month,
                            _now.day + (7 - _now.weekday + 7))
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year,
                              _selectedDate.month, _selectedDate.day + 1);
                          _initMenu();
                        });
                      },
                icon: const Icon(Icons.chevron_right_rounded),
                color: Colors.black,
                iconSize: 32,
              ),
            ],
          ),
        ),
      ),
      body: _isFirstLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _menuMap.entries.every((mealEntry) => mealEntry.value.entries
                  .every((courseEntry) => courseEntry.value.isEmpty))
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: MediaQuery.of(context).size.width / 3,
                        color: Colors.grey.shade400,
                        icon: const Icon(Icons.refresh_outlined),
                        onPressed: _onRefresh,
                      ),
                      const Text("메뉴가 존재하지 않습니다!"),
                    ],
                  ),
                )
              : RefreshIndicator.adaptive(
                  onRefresh: _onRefresh,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    // itemCount: 10,
                    // itemBuilder: (context, index) => MenuCard(
                    //   menuData: MenuModel(
                    //     menuId: "${index + 1}",
                    //     title: "주메뉴${index + 1}",
                    //     content: "보조메뉴들${index + 1}",
                    //   ),
                    // ),
                    children: [
                      const Gap(10),
                      if (!_menuMap["조식"]!
                          .entries
                          .every((courseEntry) => courseEntry.value.isEmpty))
                        MenuTime(
                          timeName: "조식",
                          time: "08:00 ~ 09:00",
                          timeColor: const Color(0xFFCAF0F8).withOpacity(0.5),
                          menuCourse: _menuMap["조식"]!,
                        ),
                      const Gap(10),
                      if (!_menuMap["중식"]!
                          .entries
                          .every((courseEntry) => courseEntry.value.isEmpty))
                        MenuTime(
                          timeName: "중식",
                          time: "12:00~13:30",
                          timeColor: const Color(0xFFFFD166).withOpacity(0.5),
                          menuCourse: _menuMap["중식"]!,
                        ),
                      const Gap(10),
                      if (!_menuMap["석식"]!
                          .entries
                          .every((courseEntry) => courseEntry.value.isEmpty))
                        MenuTime(
                          timeName: "석식",
                          time: "17:30~18:30",
                          timeColor: const Color(0xFF9B5DE5).withOpacity(0.4),
                          menuCourse: _menuMap["석식"]!,
                        ),
                      const Gap(10),
                    ],
                  ),
                ),
    );
  }
}
