import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/fast_note.dart';
import '../category_helper.dart';
import 'edit_fast_note_page.dart';

class FastNoteCard extends StatelessWidget {

  final FastNote fastNote;
  final Color color;
  final void Function(FastNote) onUpdate;
  final void Function(int id) onDelete;
  final void Function(String note) onTap;

  const FastNoteCard({
    super.key,
    required this.fastNote,
    required this.color,
    required this.onUpdate,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.sp),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 1.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap(fastNote.note);
          },
          onLongPress: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return EditFastNotePage(
                      isEditing: true,
                      id: fastNote.id,
                      color: color,
                      codePoint: fastNote.icon.codePoint,
                      note: fastNote.note,
                      onSubmit: onUpdate,
                      onDeleted: onDelete
                  );
                }
            );
          },
          borderRadius: BorderRadius.circular(5),
          splashColor: CategoryHelper.lightenColor(color, 0.3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            // spacing: 5,
            children: [
              Icon(
                fastNote.icon,
                color: color,
                size: 20
              ),
              SizedBox(width: 5.w),
              Text(
                fastNote.note,
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
