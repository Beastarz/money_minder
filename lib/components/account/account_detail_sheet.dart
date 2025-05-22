import 'package:flutter/material.dart';
import 'package:money_minder/components/account/account_detail_function_tile.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/providers/account_provider.dart';
import 'package:provider/provider.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/balance_text.dart';
import '../../utils/main_icon.dart';

class AccountDetailSheet extends StatefulWidget {
  final Account account;

  const AccountDetailSheet({super.key, required this.account});

  @override
  State<AccountDetailSheet> createState() => _AccountDetailSheetState();
}

class _AccountDetailSheetState extends State<AccountDetailSheet> {
  bool isMain = false;

  @override
  void initState() {
    super.initState();
    isMain = widget.account.isMain;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColor.secondary
        ),
        height: 500,
        width: MediaQuery.of(context).size.width,
        child: Column(
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Container(
                height: 150,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: widget.account.color,
                ),
                child: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Center(
                          child: MainIcon(icon: widget.account.icon, color: widget.account.color, isRound: false, size: 50,)),
                    ),
                    Flexible(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.account.name,
                            style: TextStyle(
                              fontSize: AppSize.heading1,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.account.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppSize.paragraph,
                              color: Colors.white,
                            )
                          ),
                          const SizedBox(height: 2,),
                          BalanceText(
                            balance: widget.account.balance,
                            currencyName: widget.account.currency.toString(),
                            size: 26,
                            isLight: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                AccountDetailFunctionTile(
                  parentContext: context,
                  label: 'Receive',
                  icon: Icon(Icons.arrow_downward, color: Colors.green[400],),
                  onPressed: () {}
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Transfer',
                    icon: Icon(Icons.arrow_upward, color: Colors.redAccent,),
                    onPressed: () {}
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Transactions',
                    icon: Icon(Icons.list_alt, color: Colors.blueAccent,),
                    onPressed: () {}
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Edit',
                    icon: Icon(Icons.edit_outlined, color: Colors.deepOrangeAccent,),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_account', arguments: {'account': widget.account});
                    }
                ),
                isMain ? Container()
                    : AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Delete',
                    icon: Icon(Icons.delete_outline, color: Colors.red,),
                    onPressed: () {
                      showDialog(context: context, builder: (BuildContext context) {
                        return SimpleDialog(
                          title: Text('Delete Account?'),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.read<AccountProvider>().deleteAccount(widget.account.id);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Delete', style: TextStyle(color: Colors.red),)
                                )
                              ],
                            )
                          ],
                        );
                      });
                    }
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: isMain ? 'Main' : 'Set Main',
                    icon: Icon(isMain ? Icons.star : Icons.star_outline, color: Colors.amber,),
                    onPressed: () {
                      if(!isMain) {
                        context.read<AccountProvider>().updateMainAccount(widget.account);
                        setState(() {
                          isMain = true;
                        });
                      }
                    }
                ),
              ],
            )
          ],
        )
    );
  }
}
