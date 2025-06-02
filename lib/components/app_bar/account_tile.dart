import 'package:flutter/material.dart';

import '../../models/account.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';

class AccountTile extends StatefulWidget {
  final Account account;
  final Function onSelect;
  final bool showColor;

  const AccountTile({super.key, required this.account, required this.onSelect, this.showColor = true});

  @override
  State<AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends State<AccountTile> {

  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.showColor ? widget.account.isIncludesInTotal : false;
  }

  void _handleTap() {
    widget.showColor
    ? setState(() {
      _isSelected = !_isSelected;
      widget.onSelect(_isSelected);
    })
    : widget.onSelect();
  }

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: InkWell(
        onTap: _handleTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.borderRadius),
        ),
        splashColor: Colors.transparent,
        child: Container(
          height: 65,
          width: MediaQuery.of(context).size.width * 0.42 ,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isSelected ? widget.account.color : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSize.borderRadius),
            border: Border.all(
              color: _isSelected ? Colors.transparent : widget.account.color,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                widget.account.icon.icon,
                color: _isSelected ? AppColor.lightText : widget.account.color,
                size: AppSize.bigIcon,
              ),
              SizedBox(width: 8,),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.account.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: _isSelected ? AppColor.lightText : widget.account.color,
                          fontSize: AppSize.heading3
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.account.currency.toString() + widget.account.balance.toStringAsFixed(2),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color: _isSelected ? AppColor.lightText : widget.account.color,
                          fontSize: AppSize.heading3 * 1.05
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
