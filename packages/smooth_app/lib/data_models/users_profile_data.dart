// TODO(chetanr25): To be implemented in OpenFoodFacts flutter package in [https://github.com/openfoodfacts/smooth-app/tree/develop/packages/smooth_app/lib/data_models] as [UserProfile] JsonSerializable
class UserProfile {
  UserProfile({
    required this.userId,
    required this.priceCount,
    required this.priceTypeProductCount,
    required this.priceTypeCategoryCount,
    required this.priceKindCommunityCount,
    required this.priceKindConsumptionCount,
    required this.priceCurrencyCount,
    required this.priceInProofOwnedCount,
    required this.priceInProofNotOwnedCount,
    required this.priceNotOwnedInProofOwnedCount,
    required this.proofCount,
    required this.proofKindCommunityCount,
    required this.proofKindConsumptionCount,
    required this.locationCount,
    required this.locationTypeOsmCountryCount,
    required this.productCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      priceCount: json['price_count'] as int,
      priceTypeProductCount: json['price_type_product_count'] as int,
      priceTypeCategoryCount: json['price_type_category_count'] as int,
      priceKindCommunityCount: json['price_kind_community_count'] as int,
      priceKindConsumptionCount: json['price_kind_consumption_count'] as int,
      priceCurrencyCount: json['price_currency_count'] as int,
      priceInProofOwnedCount: json['price_in_proof_owned_count'] as int,
      priceInProofNotOwnedCount: json['price_in_proof_not_owned_count'] as int,
      priceNotOwnedInProofOwnedCount:
          json['price_not_owned_in_proof_owned_count'] as int,
      proofCount: json['proof_count'] as int,
      proofKindCommunityCount: json['proof_kind_community_count'] as int,
      proofKindConsumptionCount: json['proof_kind_consumption_count'] as int,
      locationCount: json['location_count'] as int,
      locationTypeOsmCountryCount:
          json['location_type_osm_country_count'] as int,
      productCount: json['product_count'] as int,
    );
  }
  final String userId;
  final int priceCount;
  final int priceTypeProductCount;
  final int priceTypeCategoryCount;
  final int priceKindCommunityCount;
  final int priceKindConsumptionCount;
  final int priceCurrencyCount;
  final int priceInProofOwnedCount;
  final int priceInProofNotOwnedCount;
  final int priceNotOwnedInProofOwnedCount;
  final int proofCount;
  final int proofKindCommunityCount;
  final int proofKindConsumptionCount;
  final int locationCount;
  final int locationTypeOsmCountryCount;
  final int productCount;

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'price_count': priceCount,
      'price_type_product_count': priceTypeProductCount,
      'price_type_category_count': priceTypeCategoryCount,
      'price_kind_community_count': priceKindCommunityCount,
      'price_kind_consumption_count': priceKindConsumptionCount,
      'price_currency_count': priceCurrencyCount,
      'price_in_proof_owned_count': priceInProofOwnedCount,
      'price_in_proof_not_owned_count': priceInProofNotOwnedCount,
      'price_not_owned_in_proof_owned_count': priceNotOwnedInProofOwnedCount,
      'proof_count': proofCount,
      'proof_kind_community_count': proofKindCommunityCount,
      'proof_kind_consumption_count': proofKindConsumptionCount,
      'location_count': locationCount,
      'location_type_osm_country_count': locationTypeOsmCountryCount,
      'product_count': productCount,
    };
  }
}
