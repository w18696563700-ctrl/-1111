part of '../exhibition_consumer_layer.dart';

String _p0PayIdempotencyKey(String prefix) {
  return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

class P0PayTradeTaskCreateCommand {
  P0PayTradeTaskCreateCommand({
    required this.taskType,
    required this.projectName,
    required this.cityCode,
    required this.projectType,
    required this.exhibitionName,
    required this.area,
    required this.buildStartAt,
    required this.dismantleAt,
    required this.requirementDescription,
    required this.budgetAmount,
    required this.budgetRange,
    required this.quoteDeadlineAt,
    required this.contactId,
    required this.authenticityMaterialFileAssetIds,
    required this.authenticityDeclarations,
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? _p0PayIdempotencyKey('p0-pay-task');

  final String taskType;
  final String projectName;
  final String cityCode;
  final String projectType;
  final String exhibitionName;
  final double area;
  final String buildStartAt;
  final String dismantleAt;
  final String requirementDescription;
  final double budgetAmount;
  final String budgetRange;
  final String quoteDeadlineAt;
  final String contactId;
  final List<String> authenticityMaterialFileAssetIds;
  final Map<String, bool> authenticityDeclarations;
  final String idempotencyKey;

  Map<String, Object?> toJson() => <String, Object?>{
    'taskType': taskType,
    'projectName': projectName,
    'cityCode': cityCode,
    'projectType': projectType,
    'exhibitionName': exhibitionName,
    'area': area,
    'buildStartAt': buildStartAt,
    'dismantleAt': dismantleAt,
    'requirementDescription': requirementDescription,
    'budgetAmount': budgetAmount,
    'budgetRange': budgetRange,
    'quoteDeadlineAt': quoteDeadlineAt,
    'contactId': contactId,
    'authenticityMaterialFileAssetIds': authenticityMaterialFileAssetIds,
    'authenticityDeclarations': authenticityDeclarations,
    'idempotencyKey': idempotencyKey,
  };
}

class P0PayInquiryDepositOrderCommand {
  P0PayInquiryDepositOrderCommand({
    this.expectedAmount = 200,
    this.expectedCurrency = 'CNY',
    required this.ruleVersion,
    required this.ruleSnapshotHash,
    String? idempotencyKey,
  }) : idempotencyKey =
           idempotencyKey ?? _p0PayIdempotencyKey('p0-pay-inquiry-deposit');

  final int expectedAmount;
  final String expectedCurrency;
  final String ruleVersion;
  final String ruleSnapshotHash;
  final String idempotencyKey;

  Map<String, Object?> toJson() => <String, Object?>{
    'expectedAmount': expectedAmount,
    'expectedCurrency': expectedCurrency,
    'ruleVersion': ruleVersion,
    'ruleSnapshotHash': ruleSnapshotHash,
    'idempotencyKey': idempotencyKey,
  };
}

class P0PayPayInitCommand {
  P0PayPayInitCommand({
    required this.payChannel,
    this.clientPlatform = 'flutter',
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? _p0PayIdempotencyKey('p0-pay-init');

  final String payChannel;
  final String clientPlatform;
  final String idempotencyKey;

  Map<String, Object?> toJson() => <String, Object?>{
    'payChannel': payChannel,
    'clientPlatform': clientPlatform,
    'idempotencyKey': idempotencyKey,
  };
}

class P0PayFixedPriceBidCommand {
  P0PayFixedPriceBidCommand({
    required this.quoteAmount,
    required this.quoteValidUntil,
    required this.taxIncluded,
    required this.transportIncluded,
    required this.installationIncluded,
    required this.constructionPlan,
    required this.materialDescription,
    required this.craftDescription,
    required this.buildProcess,
    required this.deliveryMilestones,
    required this.riskNotes,
    required this.attachmentFileAssetIds,
    required this.platformServiceFeeRuleAgreement,
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? _p0PayIdempotencyKey('p0-pay-bid');

  final double quoteAmount;
  final String quoteValidUntil;
  final bool taxIncluded;
  final bool transportIncluded;
  final bool installationIncluded;
  final String constructionPlan;
  final String materialDescription;
  final String craftDescription;
  final String buildProcess;
  final List<String> deliveryMilestones;
  final String riskNotes;
  final List<String> attachmentFileAssetIds;
  final Map<String, Object?> platformServiceFeeRuleAgreement;
  final String idempotencyKey;

  Map<String, Object?> toJson() => <String, Object?>{
    'quoteAmount': quoteAmount,
    'quoteValidUntil': quoteValidUntil,
    'taxIncluded': taxIncluded,
    'transportIncluded': transportIncluded,
    'installationIncluded': installationIncluded,
    'constructionPlan': constructionPlan,
    'materialDescription': materialDescription,
    'craftDescription': craftDescription,
    'buildProcess': buildProcess,
    'deliveryMilestones': deliveryMilestones,
    'riskNotes': riskNotes,
    'attachmentFileAssetIds': attachmentFileAssetIds,
    'platformServiceFeeRuleAgreement': platformServiceFeeRuleAgreement,
    'idempotencyKey': idempotencyKey,
  };
}

class P0PayServiceFeeAuthorizationCommand {
  P0PayServiceFeeAuthorizationCommand({
    required this.expectedQuotedAmount,
    required this.expectedFeeRate,
    required this.expectedAuthorizationAmount,
    this.currency = 'CNY',
    String? idempotencyKey,
  }) : idempotencyKey = idempotencyKey ?? _p0PayIdempotencyKey('p0-pay-auth');

  final double expectedQuotedAmount;
  final String expectedFeeRate;
  final String expectedAuthorizationAmount;
  final String currency;
  final String idempotencyKey;

  Map<String, Object?> toJson() => <String, Object?>{
    'expectedQuotedAmount': expectedQuotedAmount,
    'expectedFeeRate': expectedFeeRate,
    'expectedAuthorizationAmount': expectedAuthorizationAmount,
    'currency': currency,
    'idempotencyKey': idempotencyKey,
  };
}
