import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../services/diary_service.dart';

class NewDiaryScreen extends StatefulWidget {
  const NewDiaryScreen({super.key});

  @override
  State<NewDiaryScreen> createState() => _NewDiaryScreenState();
}

class _NewDiaryScreenState extends State<NewDiaryScreen> {
  // ---------------------------------------------------------
  // CONTROLLERS
  // ---------------------------------------------------------

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _contentController = TextEditingController();

  // ---------------------------------------------------------
  // DIARY
  // ---------------------------------------------------------

  final Uuid _uuid = const Uuid();

  Timer? _autoSaveTimer;

  late final String _diaryId;

  DateTime? _diaryDate;

  bool _isFavorite = false;

  bool _isDateSelected = false;

  // ---------------------------------------------------------
  // INIT
  // ---------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _diaryId = _uuid.v4();

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // Show date popup after screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDateDialog();
    });
  }

  // ---------------------------------------------------------
  // DATE DIALOG
  // ---------------------------------------------------------

  Future<void> _showDateDialog() async {
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: const Color(0xFFFFFCF7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),

                // -------------------------------------------------
                // TITLE
                // -------------------------------------------------
                title: const Text(
                  "Enter date",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF211A16),
                  ),
                ),

                // -------------------------------------------------
                // DATE FIELD
                // -------------------------------------------------
                content: GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      helpText: "Select diary date",
                      cancelText: "Back",
                      confirmText: "Select",

                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF6B4528),
                              onPrimary: Colors.white,
                              surface: Color(0xFFFFFCF7),
                              onSurface: Color(0xFF211A16),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },

                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F3EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD9C8B8),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),

                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B4528),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _formatSelectedDate(selectedDate),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF29231F),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE7DED5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF5B5048),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // -------------------------------------------------
                // NEXT
                // -------------------------------------------------
                actions: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, selectedDate);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4528),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // ---------------------------------------------------------
    // DATE SELECTED
    // ---------------------------------------------------------

    if (result == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _diaryDate = result;
      _isDateSelected = true;
    });

    print("📅 Diary date selected: $_diaryDate");
  }

  // ---------------------------------------------------------
  // FORMAT DATE
  // ---------------------------------------------------------

  String _formatSelectedDate(DateTime date) {
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

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ---------------------------------------------------------
  // TEXT CHANGED
  // ---------------------------------------------------------

  void _onTextChanged() {
    _autoSaveTimer?.cancel();

    _autoSaveTimer = Timer(const Duration(seconds: 1), () async {
      await _autoSave();
    });
  }

  // ---------------------------------------------------------
  // AUTO SAVE
  // ---------------------------------------------------------

  Future<void> _autoSave() async {
    if (!_isDateSelected || _diaryDate == null) {
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Don't create empty diary
    if (title.isEmpty && content.isEmpty) {
      return;
    }

    try {
      await DiaryService.instance.saveDiary(
        id: _diaryId,
        title: title.isEmpty ? "Untitled Diary" : title,
        content: content,
        createdAt: _diaryDate!,
        updatedAt: DateTime.now(),

        // ⭐ IMPORTANT
        isFavorite: _isFavorite,
      );

      print("💾 Diary auto saved");
      print("📝 ID: $_diaryId");
      print("📝 Title: $title");
      print("📅 Diary date: $_diaryDate");
      print("❤️ Favorite: $_isFavorite");
    } catch (e) {
      print("❌ Auto save failed: $e");
    }
  }

  // ---------------------------------------------------------
  // MANUAL SAVE
  // ---------------------------------------------------------

  Future<void> _saveDiary() async {
    _autoSaveTimer?.cancel();

    await _autoSave();

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ---------------------------------------------------------
  // FAVORITE
  // ---------------------------------------------------------

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Save favorite status directly into the diary
    await _autoSave();

    print(
      _isFavorite
          ? "❤️ Diary marked as favorite"
          : "🤍 Diary removed from favorites",
    );
  }

  

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---------------------------------------------------
          // BACKGROUND
          // ---------------------------------------------------
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          // ---------------------------------------------------
          // CONTENT
          // ---------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                // ------------------------------------------------
                // TOP BAR
                // ------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),

                  child: Row(
                    children: [
                      // BACK
                      IconButton(
                        onPressed: () async {
                          _autoSaveTimer?.cancel();

                          await _autoSave();

                          if (!mounted) return;

                          Navigator.pop(context);
                        },

                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 21,
                          color: Color(0xFF29231F),
                        ),
                      ),

                      // INKLY
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Inkly",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A2D18),
                            ),
                          ),
                        ),
                      ),

                      // FAVORITE
                      IconButton(
                        onPressed: _toggleFavorite,

                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,

                          size: 27,

                          color: _isFavorite
                              ? const Color(0xFFB24A45)
                              : const Color(0xFF4A2D18),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // SELECTED DATE
                // ------------------------------------------------
                if (_isDateSelected && _diaryDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      _formatLongDate(_diaryDate!),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF81766E),
                      ),
                    ),
                  ),

                // ------------------------------------------------
                // DIARY CONTENT
                // ------------------------------------------------
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // TITLE
                            TextField(
                              controller: _titleController,

                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF29231F),
                              ),

                              decoration: const InputDecoration(
                                hintText: "Title",

                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF9A9692),
                                ),

                                border: InputBorder.none,

                                contentPadding: EdgeInsets.zero,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // CONTENT
                            Expanded(
                              child: TextField(
                                controller: _contentController,

                                maxLines: null,

                                expands: true,

                                textAlignVertical: TextAlignVertical.top,

                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.7,
                                  color: Color(0xFF403831),
                                ),

                                decoration: const InputDecoration(
                                  hintText: "Start writing your thoughts...",

                                  hintStyle: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFFAAA5A0),
                                  ),

                                  border: InputBorder.none,

                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------------
                      // PEN
                      // ------------------------------------------------
                      Positioned(
                        right: -8,
                        bottom: 20,

                        child: IgnorePointer(
                          child: Image.asset(
                            "assets/images/pen.png",
                            width: 150,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // BOTTOM TOOLBAR
                // ------------------------------------------------
                Container(
                  height: 76,

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFCF8),

                    border: Border(top: BorderSide(color: Color(0xFFE7DED5))),
                  ),

                  child: Row(
                    children: [
                      Expanded(
                        child: _toolItem(
                          icon: Icons.text_fields_rounded,
                          title: "Font",
                          onTap: () {
                            print("🔤 Font tapped");
                          },
                        ),
                      ),

                      Expanded(
                        child: _toolItem(
                          icon: Icons.palette_outlined,
                          title: "Theme",
                          onTap: () {
                            print("🎨 Theme tapped");
                          },
                        ),
                      ),

                      Expanded(
                        child: _toolItem(
                          icon: Icons.draw_outlined,
                          title: "Draw",
                          onTap: () {
                            print("✏️ Draw tapped");
                          },
                        ),
                      ),

                      Expanded(
                        child: _toolItem(
                          icon: Icons.mic_none_rounded,
                          title: "Audio",
                          onTap: () {
                            print("🎙️ Audio tapped");
                          },
                        ),
                      ),

                      Expanded(
                        child: _toolItem(
                          icon: Icons.more_horiz_rounded,
                          title: "More",
                          onTap: () {
                            print("••• More tapped");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // TOOL ITEM
  // ---------------------------------------------------------

  Widget _toolItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: SizedBox(
        height: 76,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(icon, size: 23, color: const Color(0xFF4A4039)),

            const SizedBox(height: 5),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF655B54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // LONG DATE
  // ---------------------------------------------------------

  String _formatLongDate(DateTime date) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${date.day} "
        "${months[date.month - 1]} "
        "${date.year}";
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------

  @override
  void dispose() {
    _autoSaveTimer?.cancel();

    _titleController.removeListener(_onTextChanged);

    _contentController.removeListener(_onTextChanged);

    _titleController.dispose();
    _contentController.dispose();

    super.dispose();
  }
}
