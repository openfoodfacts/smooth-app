#!/bin/bash
set -e

# So that users can run this script from anywhere and it will work as expected.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SMOOTHIE_PATH="${REPO_DIR}/packages/smooth_app"


echo "Updating perfect product"

PERFECT_PRODUCT_URI="https://world.openfoodfacts.org/api/v2/product/example/?fields=product_name%2Cbrands%2Ccode%2Cnutrition_grade_fr%2Cimage_small_url%2Cimage_front_small_url%2Cimage_front_url%2Cimage_ingredients_url%2Cimage_nutrition_url%2Cimage_packaging_url%2Cselected_images%2Cquantity%2Cserving_size%2Cproduct_quantity%2Cnutriments%2Cnutrient_levels%2Cnutriment_energy_unit%2Cadditives_tags%2Cingredients_analysis_tags%2Clabels_tags%2Clabels_tags_fr%2Cenvironment_impact_level_tags%2Ccategories_tags_fr%2Clang%2Cattribute_groups%2Cstates_tags%2Cecoscore_data%2Cecoscore_grade%2Cecoscore_score%2Cenvironment_impact_level_tags%2Cknowledge_panels&lc=en&cc=US"
PERFECT_PRODUCT_PATH="${SMOOTHIE_PATH}/assets/onboarding/sample_product_data.json"
curl $PERFECT_PRODUCT_URI | json_pp > $PERFECT_PRODUCT_PATH

echo "Done"