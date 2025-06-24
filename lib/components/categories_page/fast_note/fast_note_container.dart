import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money_minder/repositories/fast_note_repositories.dart';

import '../../../models/fast_note.dart';
import '../../../style/app_color.dart';
import 'edit_fast_note_page.dart';
import 'fast_note_card.dart';

class FastNoteContainer extends StatefulWidget {

  final Color color;
  final int categoryId;
  final void Function(String note) onTap;

  const FastNoteContainer({
    super.key,
    required this.color,
    required this.categoryId,
    required this.onTap,
  });

  @override
  State<FastNoteContainer> createState() => _FastNoteContainerState();
}

class _FastNoteContainerState extends State<FastNoteContainer> {

  late Future<List<FastNote>> _fastNotesFuture;
  int initialId = 0;
  List<FastNote>? fastNotes;
  int selectedCodePoint = 0xe145;

  Future<List<FastNote>> _fetchFastNotes() async {
    List<FastNote> fastNotes = await FastNoteRepositories.instance.getFastNotes(widget.categoryId);
    for (FastNote fastNote in fastNotes) {
      initialId = max(initialId, fastNote.id);
    }
    return fastNotes;
  }

  void loadFastNotes() {
    setState(() {
      _fastNotesFuture = _fetchFastNotes();
    });
  }

  void onDelete(id) {
    setState(() {
      fastNotes!.removeWhere((element) => element.id == id);
    });
    FastNoteRepositories.instance.deleteFastNote(id, widget.categoryId);
  }

  void onCreate(FastNote fastNote) {
    initialId++;
    setState(() {
      fastNotes!.add(fastNote);
    });
    FastNoteRepositories.instance.createFastNote(FastNote.insertAsMap(
        note: fastNote.note,
        codePoint: fastNote.icon.codePoint,
        categoryId: widget.categoryId,
    ));
  }

  void onUpdate(FastNote fastNote) {
    setState(() {
      for (int i = 0; i < fastNotes!.length; i++) {
        if (fastNotes![i].id == fastNote.id) {
          fastNotes![i] = fastNote;
          break;
        }
      }
    });
    FastNoteRepositories.instance.updateFastNote({
      "note": fastNote.note,
      "icon": fastNote.icon.codePoint,
    }, fastNote.id, widget.categoryId);
  }

  @override
  void initState() {
    super.initState();
    loadFastNotes();
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColor.darkText,
                width: 1,
              ),
            ),
            child: FutureBuilder<List<FastNote>>(
              future: _fastNotesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  fastNotes ??= snapshot.data!; // get the copy from database only during initial load

                  // If there are no fast notes, show a message
                  if (fastNotes!.isEmpty) {
                    return Center(
                      child: Text(
                          "Add Fast Notes...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                      ),
                    );
                  }
                  // Assuming FastNoteContainer takes List<FastNote>
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 5,
                      children: fastNotes!.map((note) => FastNoteCard(
                        fastNote: note,
                        color: widget.color,
                        onUpdate: onUpdate,
                        onDelete: onDelete,
                        onTap: widget.onTap,
                      )).toList(),
                    ),
                  );
                }
                return const Center(child: Text('Loading notes...'));
              },
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return EditFastNotePage(
                    isEditing: false,
                    id: initialId, // just need to make sure it is unique
                    color: widget.color,
                    codePoint: 0xe145,
                    note: "",
                    onSubmit: onCreate,
                  );
                }
            );
          },
          icon: const Icon(Icons.add),
        )
      ]
    );
  }
}
