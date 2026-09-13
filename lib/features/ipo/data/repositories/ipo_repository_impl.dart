import 'package:uuid/uuid.dart';
import '../../../expenses/domain/entities/transaction_entity.dart';
import '../../../expenses/domain/repositories/transaction_repository.dart';
import '../../domain/entities/capital_allocation_entity.dart';
import '../../domain/entities/ipo_application_entity.dart';
import '../../domain/entities/ipo_profile_entity.dart';
import '../../domain/entities/ipo_trade_entity.dart';
import '../../domain/repositories/ipo_repository.dart';
import '../datasources/ipo_remote_data_source.dart';
import '../models/capital_allocation_model.dart';
import '../models/ipo_application_model.dart';
import '../models/ipo_profile_model.dart';
import '../models/ipo_trade_model.dart';

class IpoRepositoryImpl implements IpoRepository {
  final IpoRemoteDataSource remoteDataSource;
  final TransactionRepository transactionRepository;

  IpoRepositoryImpl({
    required this.remoteDataSource,
    required this.transactionRepository,
  });

  @override
  Stream<List<IpoProfileEntity>> watchProfiles(String userId) {
    return remoteDataSource.watchProfiles(userId);
  }

  @override
  Future<List<IpoProfileEntity>> getProfiles(String userId) async {
    final profiles = await remoteDataSource.getProfiles(userId);
    if (profiles.isEmpty) {
      await seedDefaultProfilesIfEmpty(userId);
      return remoteDataSource.getProfiles(userId);
    }
    return profiles;
  }

  @override
  Future<void> seedDefaultProfilesIfEmpty(String userId) async {
    final existing = await remoteDataSource.getProfiles(userId);
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final defaults = [
      IpoProfileModel(
        id: 'self',
        name: 'Self',
        type: ProfileType.self,
        createdAt: now,
      ),
      IpoProfileModel(
        id: 'father',
        name: 'Father',
        type: ProfileType.proxyParent,
        createdAt: now.add(const Duration(milliseconds: 1)),
      ),
      IpoProfileModel(
        id: 'mother',
        name: 'Mother',
        type: ProfileType.proxyParent,
        createdAt: now.add(const Duration(milliseconds: 2)),
      ),
    ];

    for (final profile in defaults) {
      await remoteDataSource.saveProfile(userId, profile);
    }
  }

  @override
  Future<void> addProfile(String userId, IpoProfileEntity profile) async {
    await remoteDataSource.saveProfile(userId, IpoProfileModel.fromEntity(profile));
  }

  @override
  Stream<List<CapitalAllocationEntity>> watchCapitalAllocations(String userId, {String? profileId}) {
    return remoteDataSource.watchCapitalAllocations(userId, profileId: profileId);
  }

  @override
  Future<void> addCapitalAllocation(String userId, CapitalAllocationEntity allocation) async {
    final model = CapitalAllocationModel.fromEntity(allocation);
    await remoteDataSource.addCapitalAllocation(userId, model);
  }

  @override
  Future<void> deleteCapitalAllocation(String userId, String allocationId) async {
    await remoteDataSource.deleteCapitalAllocation(userId, allocationId);
  }

  @override
  Stream<List<IpoApplicationEntity>> watchApplications(String userId, {String? profileId}) {
    return remoteDataSource.watchApplications(userId, profileId: profileId);
  }

  @override
  Future<void> addApplication(String userId, IpoApplicationEntity application) async {
    final model = IpoApplicationModel.fromEntity(application);
    await remoteDataSource.saveApplication(userId, model);
  }

  @override
  Future<void> unblockApplication(String userId, String applicationId) async {
    // ASBA Unblock / Refund: zero expense ledger touches
    final now = DateTime.now();
    await remoteDataSource.updateApplicationStatus(
      userId,
      applicationId,
      status: IpoApplicationStatus.unblocked.nameString,
      unblockedAt: now,
    );
  }

  @override
  Future<void> allotApplication(
    String userId, {
    required String applicationId,
    required int allottedShares,
    required double debitAmount,
  }) async {
    final now = DateTime.now();
    final application = await remoteDataSource.getApplicationById(userId, applicationId);
    if (application == null) {
      throw Exception('IPO application $applicationId not found');
    }

    // 1. Create official DEBIT transaction in the core expense ledger
    final debitTxId = const Uuid().v4();
    final debitTx = TransactionEntity(
      id: debitTxId,
      userId: userId,
      title: 'IPO Allotment: ${application.ipoName}',
      amount: debitAmount,
      type: TransactionType.expense,
      expenseCategory: ExpenseCategory.investmentsAndSavings,
      date: now,
      notes: 'ASBA Debit: Allotted $allottedShares shares for ${application.ipoName}',
      paymentMethod: PaymentMethod.bankTransfer,
      createdAt: now,
      updatedAt: now,
    );
    await transactionRepository.addTransaction(debitTx, userId);

    // 2. Save trade record
    final tradeId = const Uuid().v4();
    final trade = IpoTradeModel(
      id: tradeId,
      applicationId: applicationId,
      profileId: application.profileId,
      allottedShares: allottedShares,
      debitAmount: debitAmount,
      linkedExpenseTransactionId: debitTxId,
    );
    await remoteDataSource.saveTrade(userId, trade);

    // 3. Update application status to ALLOTTED
    await remoteDataSource.updateApplicationStatus(
      userId,
      applicationId,
      status: IpoApplicationStatus.allotted.nameString,
      allotmentDate: now,
    );
  }

  @override
  Future<void> sellTrade(
    String userId, {
    required String tradeId,
    required double sellPricePerShare,
    required double grossProceeds,
    required double netProfit,
  }) async {
    final now = DateTime.now();

    // 1. Create official CREDIT transaction in the core expense ledger
    final creditTxId = const Uuid().v4();
    final creditTx = TransactionEntity(
      id: creditTxId,
      userId: userId,
      title: 'IPO Exit / Sale Proceeds',
      amount: grossProceeds,
      type: TransactionType.income,
      incomeCategory: IncomeCategory.investments,
      date: now,
      notes: 'IPO Exit: Gross Proceeds ₹$grossProceeds | Net Profit: ₹$netProfit',
      paymentMethod: PaymentMethod.bankTransfer,
      createdAt: now,
      updatedAt: now,
    );
    await transactionRepository.addTransaction(creditTx, userId);

    // 2. Update trade details
    await remoteDataSource.updateTradeSale(
      userId,
      tradeId,
      sellPricePerShare: sellPricePerShare,
      grossProceeds: grossProceeds,
      netProfit: netProfit,
      soldAt: now,
      linkedIncomeTransactionId: creditTxId,
    );
  }

  @override
  Stream<List<IpoTradeEntity>> watchTrades(String userId, {String? profileId}) {
    return remoteDataSource.watchTrades(userId, profileId: profileId);
  }
}
