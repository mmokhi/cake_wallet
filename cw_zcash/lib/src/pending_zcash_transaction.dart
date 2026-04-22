import 'package:cw_core/pending_transaction.dart';
import 'package:cw_core/utils/print_verbose.dart';
import 'package:cw_zcash/cw_zcash.dart';
import 'package:cw_core/currency_for_wallet_type.dart';
import 'package:cw_core/wallet_type.dart';
import 'package:zkool/src/rust/api/pay.dart' as zkool_pay;
import 'package:zkool/src/rust/api/network.dart' as zkool_network;

class PendingZcashTransaction with PendingTransaction {
  PendingZcashTransaction({
    required this.zcashWallet,
    required this.credentials,
    required this.txPlan,
    required this.fee,
    required this.availableBalance,
  });

  final ZcashWallet zcashWallet;
  final ZcashTransactionCredentials credentials;
  final zkool_pay.PcztPackage txPlan;
  String? _txId;
  final int availableBalance;

  @override
  String get id => _txId ?? '';

  @override
  String get hex => '';

  @override
  String get amountFormatted {
    return walletTypeToCryptoCurrency(WalletType.zcash).formatAmount(BigInt.from(totalAmount));
  }

  int get totalAmount {
    final isAll = credentials.outputs.fold<bool>(false, (final a, final b) => a || (b.sendAll));
    if (isAll) {
      return availableBalance;
    }
    return credentials.outputs.fold<int>(
      0,
      (final a, final b) => a + (b.formattedCryptoAmount ?? 0),
    );
  }

  @override
  String get feeFormatted =>
      '$feeFormattedValue ${walletTypeToCryptoCurrency(WalletType.zcash).title}';

  @override
  late String feeFormattedValue = walletTypeToCryptoCurrency(
    WalletType.zcash,
  ).formatAmount(BigInt.from(fee));

  int fee;

  @override
  Future<void> commit() async {
    final signTx = await zkool_pay.signTransaction(pczt: txPlan, c: ZcashWalletBase.c);
    final txBytes = await zkool_pay.extractTransaction(package: signTx);
    final currentHeight = await zkool_network.getCurrentHeight(c: ZcashWalletBase.c);
    final result = await zkool_pay.broadcastTransaction(
      height: currentHeight,
      txBytes: txBytes,
      c: ZcashWalletBase.c,
    );
    printV("result: $result");
    await zcashWallet.updateTransactions();
    await zcashWallet.updateBalance();
  }

  @override
  Future<Map<String, String>> commitUR() {
    throw UnimplementedError('UR not supported for Zcash');
  }

  @override
  bool shouldCommitUR() => false;
}
