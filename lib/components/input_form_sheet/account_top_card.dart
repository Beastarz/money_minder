import 'package:flutter/material.dart';
import 'package:money_minder/components/account/account_selection_sheet.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../models/account.dart';
import '../../style/app_color.dart';
import '../../style/app_size.dart';

// use this to construct the topContent of the calculator sheet
class AccountTopCard extends StatefulWidget {

  /// variable
  final double width; // width of the card
  final Account initialAccount; // initial category
  final bool topRight; // whether to curve topRight corner
  final bool topLeft; // whether to curve topLeft corner
  final bool isTappable;
  final void Function(Account) onPressed; // callback function when the button is pressed

  const AccountTopCard({
    super.key,
    required this.width,
    required this.initialAccount,
    required this.onPressed,
    this.isTappable = true,
    this.topRight = false,
    this.topLeft = false,
  });

  @override
  State<AccountTopCard> createState() => _AccountTopCardState();
}

class _AccountTopCardState extends State<AccountTopCard> {
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  void _fetchAccounts() async {
    List<Account> res = await AccountsRepository.instance.getAllAccounts();
    setState(() {
      accounts = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    Account account = widget.initialAccount;

    Widget buttonContent = SizedBox(
        width: 40,
        height: 40,
        child: account.icon
    );

    return MaterialButton(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.topLeft ? AppSize.borderRadius : 0),
          topRight: Radius.circular(widget.topRight ? AppSize.borderRadius : 0),
        ),
      ),
      color: account.color,
      disabledColor: account.color,
      disabledTextColor: AppColor.lightText,
      onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColor.secondary,
          builder: (context) {
            return AccountSelectionSheet(
                accounts: accounts,
                onSelect: widget.onPressed
            );
          }
      ),
      child: Stack(
          children: [
            Container(
              width: widget.width,
              decoration: BoxDecoration(
                color : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.topLeft ? AppSize.borderRadius : 0),
                  topRight: Radius.circular(widget.topRight ? AppSize.borderRadius : 0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSize.smallPadding),
                    child: Text(
                        '${widget.topLeft ? "From" : "To"} Account',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: AppSize.heading3,
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSize.smallPadding,
                      right: AppSize.smallPadding,
                      bottom: AppSize.smallPadding,
                    ),
                    child: Text(
                        account.name,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: AppSize.heading1 * 1.15,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        )
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: buttonContent,
            ),
          ]
      ),
    );
  }
}
