import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/diary_service.dart';
import '../diary/read_diary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _diaries = [];
  List<Map<String, dynamic>> _filteredDiaries = [];

  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_searchDiaries);

    _loadDiaries();
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchDiaries);
    _searchController.dispose();

    super.dispose();
  }

  Future<void> refreshDiaries() async {
    print("🔄 Refreshing diaries...");

    await _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    try {
      final diaries = await DiaryService.instance.getDiaries();

      diaries.sort((a, b) {
        final dateA = DateTime.tryParse(a["createdAt"]?.toString() ?? "");

        final dateB = DateTime.tryParse(b["createdAt"]?.toString() ?? "");

        if (dateA == null || dateB == null) {
          return 0;
        }

        return dateB.compareTo(dateA);
      });

      if (!mounted) return;

      setState(() {
        _diaries = diaries;
        _filteredDiaries = diaries;
        _isLoading = false;
      });

      _searchDiaries();

      print("📚 Loaded ${_diaries.length} diaries");
    } catch (e) {
      print("❌ Failed to load diaries: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchDiaries() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredDiaries = _diaries;
        });
      }

      return;
    }

    final results = _diaries.where((diary) {
      final title = diary["title"]?.toString().toLowerCase() ?? "";

      final content = diary["content"]?.toString().toLowerCase() ?? "";

      final createdAt = diary["createdAt"]?.toString().toLowerCase() ?? "";

      return title.contains(query) ||
          content.contains(query) ||
          createdAt.contains(query);
    }).toList();

    if (!mounted) return;

    setState(() {
      _filteredDiaries = results;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good morning";
    } else if (hour < 17) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }

  String _preview(String content) {
    final text = content.trim();

    if (text.isEmpty) {
      return "";
    }

    final lines = text
        .split(RegExp(r'\r?\n'))
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.length >= 2) {
      return "${lines[0].trim()}\n${lines[1].trim()}";
    }

    return text;
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      return "";
    }

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${parsedDate.day} "
        "${months[parsedDate.month - 1]} "
        "${parsedDate.year}";
  }

  String _dateSectionTitle(String date) {
    final parsedDate = DateTime.tryParse(date);

    if (parsedDate == null) {
      return "";
    }

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final yesterday = today.subtract(const Duration(days: 1));

    final diaryDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );

    if (diaryDate == today) {
      return "TODAY";
    }

    if (diaryDate == yesterday) {
      return "YESTERDAY";
    }

    const months = [
      "JANUARY",
      "FEBRUARY",
      "MARCH",
      "APRIL",
      "MAY",
      "JUNE",
      "JULY",
      "AUGUST",
      "SEPTEMBER",
      "OCTOBER",
      "NOVEMBER",
      "DECEMBER",
    ];

    return "${parsedDate.day} ${months[parsedDate.month - 1]}";
  }

  bool _isSameDay(String dateA, String dateB) {
    final a = DateTime.tryParse(dateA);
    final b = DateTime.tryParse(dateB);

    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim().split(" ").first
        : "there";

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),

                        // GREETING
                        Text(
                          "${_greeting()}, $name 👋",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF211A16),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // SEARCH
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.06),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search your diary...",
                              hintStyle: TextStyle(
                                color: Color(0xFF9A9692),
                                fontSize: 16,
                              ),

                              // Only ONE search icon
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFFAAA6A2),
                              ),

                              border: InputBorder.none,

                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // LOADING
                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6B4528),
                            ),
                          )
                        // NO DIARIES
                        else if (_filteredDiaries.isEmpty)
                          _searchController.text.isNotEmpty
                              ? _noSearchResults()
                              : _emptyDiaryView()
                        // DIARIES
                        else
                          _diaryList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _diaryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _filteredDiaries.length; i++) ...[
          if (i == 0 ||
              !_isSameDay(
                _filteredDiaries[i - 1]["createdAt"]?.toString() ?? "",
                _filteredDiaries[i]["createdAt"]?.toString() ?? "",
              ))
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                _dateSectionTitle(
                  _filteredDiaries[i]["createdAt"]?.toString() ?? "",
                ),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .8,
                  color: Color(0xFF6B4528),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _diaryTile(_filteredDiaries[i]),
          ),
        ],
      ],
    );
  }

  Widget _diaryTile(Map<String, dynamic> diary) {
    final title = diary["title"]?.toString() ?? "Untitled Diary";

    final content = diary["content"]?.toString() ?? "";

    final createdAt = diary["createdAt"]?.toString() ?? "";

    final id = diary["id"]?.toString() ?? "";

    // Check favorite status
    final isFavorite = diary["isFavorite"] == true || diary["favorite"] == true;

    return GestureDetector(
      onTap: () async {
        print("📖 Diary tapped: $id");

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReadDiaryScreen(diaryId: id)),
        );

        await refreshDiaries();
      },

      child: Container(
        width: double.infinity,
        height: 150,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),

          image: const DecorationImage(
            image: AssetImage("assets/home_images/tile_bg.png"),
            fit: BoxFit.cover,
          ),

          border: Border.all(color: const Color(0xFFECE3D9)),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.045),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Stack(
          children: [
            // ------------------------------------------------
            // CONTENT
            // ------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 18, 45, 18),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF29231F),
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    _formatDate(createdAt),

                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7E7872),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: Text(
                      _preview(content),

                      maxLines: 3,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF514A44),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // FAVORITE HEART
            // ------------------------------------------------
            if (isFavorite)
              const Positioned(
                top: 14,
                right: 16,

                child: Icon(
                  Icons.favorite_rounded,
                  size: 20,
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyDiaryView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),

      child: const Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 48, color: Color(0xFF8C7968)),

          SizedBox(height: 12),

          Text(
            "No Diaries Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF29231F),
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Start writing your first diary.",
            style: TextStyle(fontSize: 14, color: Color(0xFF81766E)),
          ),
        ],
      ),
    );
  }

  Widget _noSearchResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),

      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, size: 46, color: Color(0xFF8C7968)),

          SizedBox(height: 12),

          Text(
            "No matching diaries",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF29231F),
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Try searching with another word.",
            style: TextStyle(fontSize: 14, color: Color(0xFF81766E)),
          ),
        ],
      ),
    );
  }
}
