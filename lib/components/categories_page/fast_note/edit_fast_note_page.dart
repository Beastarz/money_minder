import 'package:flutter/material.dart';

import '../../../models/fast_note.dart';
import '../../../style/app_color.dart';
import '../../../style/app_size.dart';
import '../../../utils/AppMessage.dart';
import '../icon_selector.dart';

class EditFastNotePage extends StatefulWidget {

  final bool isEditing;
  final int id;
  final Color color;
  final int codePoint;
  final String note;
  final void Function(FastNote) onSubmit;
  final void Function(int id)? onDeleted;

  const EditFastNotePage({
    super.key,
    required this.isEditing,
    required this.id,
    required this.color,
    required this.codePoint,
    required this.note,
    required this.onSubmit,
    this.onDeleted,
  });

  @override
  State<EditFastNotePage> createState() => _EditFastNotePageState();
}

class _EditFastNotePageState extends State<EditFastNotePage> {

  late String note = widget.note;
  late int selectedCodePoint = widget.codePoint;
  bool showEmptyError = false;
  bool showLengthError = false;
  late TextEditingController fastNoteController;

  void onSubmit() {
    if (note == "") {
      setState(() {
        showEmptyError = true;
      });
      AppMessage.showMessage(context, 'The Fast Note is Empty!');
      return;
    }

    // error unhandled
    if (showLengthError) {
      AppMessage.showMessage(context, 'The Fast Note Exceed Limited Length!');
      return;
    }
    
    FastNote fastNote = FastNote(
      id: widget.id,
      icon: IconData(selectedCodePoint, fontFamily: "MaterialSymbolsOutlined"),
      note: note,
      categoryId: 0, // does not matter
    );
    widget.onSubmit(fastNote);
    Navigator.pop(context);
  }

  // Helper method to update the state variable from the controller
  void _updateFastNote() {
    setState(() {
      if (fastNoteController.text.length > 30) {
        fastNoteController.text = note;
        showLengthError = true;
        return;
      }
      note = fastNoteController.text;
      showEmptyError = false;
      showLengthError = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the controller ONCE in initState
    fastNoteController = TextEditingController(text: note);
    // Add a listener to update the state variable whenever the text changes
    fastNoteController.addListener(_updateFastNote);
  }

  @override
  void dispose() {
    fastNoteController.removeListener(_updateFastNote); // Remove listener first
    fastNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final bool isSmallScreen = MediaQuery.of(context).size.width <= 360;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 16.0, bottom: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
          color: AppColor.secondary,
        ),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * (isSmallScreen ? 0.8 : 0.6),
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.color,
                                width: 1,
                              )
                          ),
                          child: Icon(
                            IconData(selectedCodePoint, fontFamily: "MaterialSymbolsOutlined"),
                            size: 30,
                            color: widget.color,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              errorText: showEmptyError
                                  ? "Fast Note cannot be empty!"
                                  : showLengthError
                                  ? "Fast Node is too long!"
                                  : "",
                              hintText: 'Fast Note...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColor.primary,
                              contentPadding: EdgeInsets.all(5),
                            ),
                            style: const TextStyle(fontSize: 20),
                            controller: fastNoteController,
                          ),
                        )
                      ]
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.borderRadius),
                        border: Border.all(
                          color: AppColor.darkText,
                          width: 2,
                        )
                      ),
                      child: Scaffold(
                        resizeToAvoidBottomInset: false,
                        backgroundColor: Colors.transparent,
                        body: IconSelector(
                          changeIcon: (int codePoint) {
                            setState(() {
                              selectedCodePoint = codePoint;
                            });
                          },
                          codePoint: selectedCodePoint,
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                      onPressed: onSubmit,
                      color: widget.color,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(!widget.isEditing
                                ? note == "" ? "Add Fast Note" : "Add $note"
                                : note == "" ? "Edit Category" : "Change to $note"),
                            SizedBox(width: AppSize.smallPadding),
                            Icon(IconData(selectedCodePoint, fontFamily: "MaterialSymbolsOutlined")),
                          ]
                      )
                  ),
                  !widget.isEditing ? SizedBox.shrink() : MaterialButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text("Delete Fast Notes"),
                                  content: Text("This action is irreversible."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        widget.onDeleted!(widget.id);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ]
                              );
                            }
                        );
                      },
                      color: Colors.redAccent,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(note == "" ? "Delete Fast Note" : "Delete $note"),
                            SizedBox(width: AppSize.smallPadding),
                            Icon(Icons.delete),
                          ]
                      )
                  ),
                ]
            )
        ),
      ),
    );
  }
}
