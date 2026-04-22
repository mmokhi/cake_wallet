import 'package:cw_core/balance.dart';
import 'package:cw_core/crypto_currency.dart';

class ZcashBalance extends Balance {
  ZcashBalance({required this.confirmed, required this.unconfirmed, required final int frozen})
    : _frozen = frozen,
      super.fromInt(confirmed, unconfirmed);

  factory ZcashBalance.zero() => ZcashBalance(confirmed: 0, unconfirmed: 0, frozen: 0);

  final int confirmed;
  final int unconfirmed;
  final int _frozen;
  BigInt get frozen => BigInt.from(_frozen);

  @override
  String get formattedUnAvailableBalance {
    if (frozen == 0) return '';
    return CryptoCurrency.zec.formatAmount(BigInt.from(_frozen));
  }
}
