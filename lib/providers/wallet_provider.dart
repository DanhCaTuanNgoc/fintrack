import 'package:Fintrack/data/models/wallet.dart';
import 'package:Fintrack/data/repositories/wallet_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import './database_provider.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return WalletRepository(dbHelper);
});

final walletsProvider =
    StateNotifierProvider<WalletsNotifier, AsyncValue<List<Wallet>>>((ref) {
  return WalletsNotifier(ref);
});

class WalletsNotifier extends StateNotifier<AsyncValue<List<Wallet>>> {
  WalletsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadWallets();
  }

  final Ref ref;

  Future<void> loadWallets() async {
    try {
      final repository = ref.read(walletRepositoryProvider);
      final wallets = await repository.getWallets();
      state = AsyncValue.data(wallets);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createWallet(String name) async {
    try {
      final repository = ref.read(walletRepositoryProvider);
      final wallet = Wallet(
          nameBalance: name,
          walletBalance: 0.0,
          type: 'defaultType',
          userId: 1);
      await repository.createWallet(wallet);
      await loadWallets();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAllWallets() async {
    try {
      final repository = ref.read(walletRepositoryProvider);
      await repository.deleteAllWallets();
      await loadWallets();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final currentWalletProvider =
    StateNotifierProvider<CurrentWalletNotifier, AsyncValue<Wallet?>>((ref) {
  return CurrentWalletNotifier(ref);
});

class CurrentWalletNotifier extends StateNotifier<AsyncValue<Wallet?>> {
  CurrentWalletNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;

  Future<void> loadFirstWallet() async {
    try {
      final walletsState = ref.read(walletsProvider);
      walletsState.whenData((wallets) {
        state = AsyncValue.data(wallets.isNotEmpty ? wallets.first : null);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void setCurrentWallet(Wallet wallet) {
    state = AsyncValue.data(wallet);
  }
}
