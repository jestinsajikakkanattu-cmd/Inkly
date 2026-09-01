import 'package:flutter/material.dart';

import '../../services/diary_service.dart';

class ReadDiaryScreen extends StatefulWidget {
  final String diaryId;

  const ReadDiaryScreen({super.key, required this.diaryId});

  @override
  State<ReadDiaryScreen> createState() => _ReadDiaryScreenState();
}

class _ReadDiaryScreenState extends State<ReadDiaryScreen> {
  Map<String, dynamic>? _diary;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiary();
  }

  Future<void> _loadDiary() async {
    final diary = await DiaryService.instance.getDiary(widget.diaryId);

    if (!mounted) return;

    setState(() {
      _diary = diary;
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/bg_image.png", fit: BoxFit.cover),

          SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 21,
                          color: Color(0xFF29231F),
                        ),
                      ),

                      const Spacer(),

                      IconButton(
                        onPressed: () {
                          print("❤️ Favorite tapped");
                        },
                        icon: const Icon(
                          Icons.favorite_border_rounded,
                          size: 25,
                          color: Color(0xFF4A2D18),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFE7DED5)),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6B4528),
                          ),
                        )
                      : _diary == null
                      ? const Center(child: Text("Diary not found"))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _diary!["title"]?.toString() ??
                                    "Untitled Diary",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF29231F),
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                _formatDate(
                                  _diary!["createdAt"]?.toString() ?? "",
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF81766E),
                                ),
                              ),

                              const SizedBox(height: 24),

                              const Divider(color: Color(0xFFE7DED5)),

                              const SizedBox(height: 20),

                              Text(
                                _diary!["content"]?.toString() ?? "",
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.7,
                                  color: Color(0xFF403831),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // BOTTOM BAR
                Container(
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFCF8),
                    border: Border(top: BorderSide(color: Color(0xFFE7DED5))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _bottomItem(Icons.edit_outlined, "Edit", () {
                          print("✏️ Edit tapped");
                        }),
                      ),

                      Expanded(
                        child: _bottomItem(
                          Icons.delete_outline,
                          "Delete",
                          _deleteDiary,
                        ),
                      ),

                      Expanded(
                        child: _bottomItem(Icons.share_outlined, "Share", () {
                          print("📤 Share tapped");
                        }),
                      ),

                      Expanded(
                        child: _bottomItem(
                          Icons.volume_up_outlined,
                          "Listen",
                          () {
                            print("🔊 Listen tapped");
                          },
                        ),
                      ),

                      Expanded(
                        child: _bottomItem(
                          Icons.more_horiz_rounded,
                          "More",
                          () {
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

  Widget _bottomItem(IconData icon, String title, VoidCallback onTap) {
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
              style: const TextStyle(fontSize: 11, color: Color(0xFF655B54)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDiary() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFCF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Delete Diary?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF211A16),
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this diary entry?\n\n"
            "This action cannot be undone.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF655B54),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B4528),
                      side: const BorderSide(color: Color(0xFFE7DED5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4528),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await DiaryService.instance.deleteDiary(widget.diaryId);

    if (!mounted) return;

    Navigator.pop(context);

    print("✅ Diary deleted");
  }
}
