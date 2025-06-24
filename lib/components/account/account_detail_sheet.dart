import 'package:flutter/material.dart';
import 'package:money_minder/components/account/account_detail_function_tile.dart';
import 'package:money_minder/components/account/account_selection_sheet.dart';
import 'package:money_minder/components/transaction/add_transfer_sheet.dart';
import 'package:money_minder/models/account.dart';
import 'package:money_minder/pages/accounts/edit_account_page.dart';
import 'package:money_minder/repositories/accounts_repositories.dart';

import '../../style/app_color.dart';
import '../../style/app_size.dart';
import '../../utils/balance_text.dart';
import '../../utils/main_icon.dart';

class AccountDetailSheet extends StatefulWidget {
  final Account account;
  final Function(int) onShowAccountTransactions;
  final void Function() onReload;

  const AccountDetailSheet({super.key, required this.account, required this.onReload, required this.onShowAccountTransactions});

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
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return AccountSelectionSheet(
                              removeAccount: widget.account,
                              onSelect: (Account fromAccount) {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return AddTransferSheet(
                                          mainCurrency: fromAccount.currency,
                                          onAddTransactionReload: widget.onReload,
                                          fromAccount: fromAccount,
                                          toAccount: widget.account
                                      );
                                    }
                                );
                              }
                          );
                        }
                    );
                  }
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Transfer',
                    icon: Icon(Icons.arrow_upward, color: Colors.redAccent,),
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return AccountSelectionSheet(
                              removeAccount: widget.account,
                                onSelect: (Account toAccount) {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return AddTransferSheet(
                                            mainCurrency: widget.account.currency,
                                            onAddTransactionReload: widget.onReload,
                                            fromAccount: widget.account,
                                            toAccount: toAccount
                                        );
                                      }
                                  );
                                }
                            );
                          }
                      );
                    }
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Transactions',
                    icon: Icon(Icons.list_alt, color: Colors.blueAccent,),
                    onPressed: () {
                        Navigator.pop(context);
                        widget.onShowAccountTransactions(widget.account.id);
                      },
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: 'Edit',
                    icon: Icon(Icons.edit_outlined, color: Colors.deepOrangeAccent,),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditAccountPage(
                                  account: widget.account,
                                  onReload: widget.onReload
                              )
                          )
                      );
                    }
                ),
                AccountDetailFunctionTile(
                    parentContext: context,
                    label: isMain ? 'Main' : 'Set Main',
                    icon: Icon(isMain ? Icons.star : Icons.star_outline, color: Colors.amber,),
                    onPressed: () {
                      if(!isMain) {
                        () async {
                          await AccountsRepository.instance.updateMainAccount(widget.account);
                          widget.onReload();
                        }();
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
