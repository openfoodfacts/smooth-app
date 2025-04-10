import 'package:openfoodfacts/openfoodfacts.dart';

extension OpenFoodFactsCountryNameExtension on OpenFoodFactsCountry {
  String getEnglishName() {
    switch (this) {
      case OpenFoodFactsCountry.ANDORRA:
        return 'Andorra';
      case OpenFoodFactsCountry.UNITED_ARAB_EMIRATES:
        return 'United Arab Emirates';
      case OpenFoodFactsCountry.AFGHANISTAN:
        return 'Afghanistan';
      case OpenFoodFactsCountry.ANTIGUA_AND_BARBUDA:
        return 'Antigua and Barbuda';
      case OpenFoodFactsCountry.ANGUILLA:
        return 'Anguilla';
      case OpenFoodFactsCountry.ALBANIA:
        return 'Albania';
      case OpenFoodFactsCountry.ARMENIA:
        return 'Armenia';
      case OpenFoodFactsCountry.ANGOLA:
        return 'Angola';
      case OpenFoodFactsCountry.ANTARCTICA:
        return 'Antarctica';
      case OpenFoodFactsCountry.ARGENTINA:
        return 'Argentina';
      case OpenFoodFactsCountry.AMERICAN_SAMOA:
        return 'American Samoa';
      case OpenFoodFactsCountry.AUSTRIA:
        return 'Austria';
      case OpenFoodFactsCountry.AUSTRALIA:
        return 'Australia';
      case OpenFoodFactsCountry.ARUBA:
        return 'Aruba';
      case OpenFoodFactsCountry.ALAND_ISLANDS:
        return 'Åland Islands';
      case OpenFoodFactsCountry.AZERBAIJAN:
        return 'Azerbaijan';
      case OpenFoodFactsCountry.BOSNIA_AND_HERZEGOVINA:
        return 'Bosnia and Herzegovina';
      case OpenFoodFactsCountry.BARBADOS:
        return 'Barbados';
      case OpenFoodFactsCountry.BANGLADESH:
        return 'Bangladesh';
      case OpenFoodFactsCountry.BELGIUM:
        return 'Belgium';
      case OpenFoodFactsCountry.BURKINA_FASO:
        return 'Burkina Faso';
      case OpenFoodFactsCountry.BULGARIA:
        return 'Bulgaria';
      case OpenFoodFactsCountry.BAHRAIN:
        return 'Bahrain';
      case OpenFoodFactsCountry.BURUNDI:
        return 'Burundi';
      case OpenFoodFactsCountry.BENIN:
        return 'Benin';
      case OpenFoodFactsCountry.SAINT_BARTHELEMY:
        return 'Saint Barthélemy';
      case OpenFoodFactsCountry.BERMUDA:
        return 'Bermuda';
      case OpenFoodFactsCountry.BRUNEI_DARUSSALAM:
        return 'Brunei Darussalam';
      case OpenFoodFactsCountry.BOLIVIA:
        return 'Bolivia';
      case OpenFoodFactsCountry.BONAIRE:
        return 'Bonaire, Sint Eustatius and Saba';
      case OpenFoodFactsCountry.BRAZIL:
        return 'Brazil';
      case OpenFoodFactsCountry.BAHAMAS:
        return 'Bahamas';
      case OpenFoodFactsCountry.BHUTAN:
        return 'Bhutan';
      case OpenFoodFactsCountry.BOUVET_ISLAND:
        return 'Bouvet Island';
      case OpenFoodFactsCountry.BOTSWANA:
        return 'Botswana';
      case OpenFoodFactsCountry.BELARUS:
        return 'Belarus';
      case OpenFoodFactsCountry.BELIZE:
        return 'Belize';
      case OpenFoodFactsCountry.CANADA:
        return 'Canada';
      case OpenFoodFactsCountry.COCOS_ISLANDS:
        return 'Cocos (Keeling) Islands';
      case OpenFoodFactsCountry.DEMOCRATIC_REPUBLIC_OF_THE_CONGO:
        return 'Democratic Republic of the Congo';
      case OpenFoodFactsCountry.CENTRAL_AFRICAN_REPUBLIC:
        return 'Central African Republic';
      case OpenFoodFactsCountry.CONGO:
        return 'Congo';
      case OpenFoodFactsCountry.SWITZERLAND:
        return 'Switzerland';
      case OpenFoodFactsCountry.COTE_D_IVOIRE:
        return "Côte d'Ivoire";
      case OpenFoodFactsCountry.COOK_ISLANDS:
        return 'Cook Islands';
      case OpenFoodFactsCountry.CHILE:
        return 'Chile';
      case OpenFoodFactsCountry.CAMEROON:
        return 'Cameroon';
      case OpenFoodFactsCountry.CHINA:
        return 'China';
      case OpenFoodFactsCountry.COLOMBIA:
        return 'Colombia';
      case OpenFoodFactsCountry.COSTA_RICA:
        return 'Costa Rica';
      case OpenFoodFactsCountry.CUBA:
        return 'Cuba';
      case OpenFoodFactsCountry.CABO_VERDE:
        return 'Cabo Verde';
      case OpenFoodFactsCountry.CURACAO:
        return 'Curaçao';
      case OpenFoodFactsCountry.CHRISTMAS_ISLAND:
        return 'Christmas Island';
      case OpenFoodFactsCountry.CYPRUS:
        return 'Cyprus';
      case OpenFoodFactsCountry.CZECHIA:
        return 'Czechia';
      case OpenFoodFactsCountry.GERMANY:
        return 'Germany';
      case OpenFoodFactsCountry.DJIBOUTI:
        return 'Djibouti';
      case OpenFoodFactsCountry.DENMARK:
        return 'Denmark';
      case OpenFoodFactsCountry.DOMINICA:
        return 'Dominica';
      case OpenFoodFactsCountry.DOMINICAN_REPUBLIC:
        return 'Dominican Republic';
      case OpenFoodFactsCountry.ALGERIA:
        return 'Algeria';
      case OpenFoodFactsCountry.ECUADOR:
        return 'Ecuador';
      case OpenFoodFactsCountry.ESTONIA:
        return 'Estonia';
      case OpenFoodFactsCountry.EGYPT:
        return 'Egypt';
      case OpenFoodFactsCountry.WESTERN_SAHARA:
        return 'Western Sahara';
      case OpenFoodFactsCountry.ERITREA:
        return 'Eritrea';
      case OpenFoodFactsCountry.SPAIN:
        return 'Spain';
      case OpenFoodFactsCountry.ETHIOPIA:
        return 'Ethiopia';
      case OpenFoodFactsCountry.FINLAND:
        return 'Finland';
      case OpenFoodFactsCountry.FIJI:
        return 'Fiji';
      case OpenFoodFactsCountry.FALKLAND_ISLANDS:
        return 'Falkland Islands (Malvinas)';
      case OpenFoodFactsCountry.MICRONESIA:
        return 'Micronesia';
      case OpenFoodFactsCountry.FAROE_ISLANDS:
        return 'Faroe Islands';
      case OpenFoodFactsCountry.FRANCE:
        return 'France';
      case OpenFoodFactsCountry.GABON:
        return 'Gabon';
      case OpenFoodFactsCountry.UNITED_KINGDOM:
        return 'United Kingdom';
      case OpenFoodFactsCountry.GRENADA:
        return 'Grenada';
      case OpenFoodFactsCountry.GEORGIA:
        return 'Georgia';
      case OpenFoodFactsCountry.FRENCH_GUIANA:
        return 'French Guiana';
      case OpenFoodFactsCountry.GUERNSEY:
        return 'Guernsey';
      case OpenFoodFactsCountry.GHANA:
        return 'Ghana';
      case OpenFoodFactsCountry.GIBRALTAR:
        return 'Gibraltar';
      case OpenFoodFactsCountry.GREENLAND:
        return 'Greenland';
      case OpenFoodFactsCountry.GAMBIA:
        return 'Gambia';
      case OpenFoodFactsCountry.GUINEA:
        return 'Guinea';
      case OpenFoodFactsCountry.GUADELOUPE:
        return 'Guadeloupe';
      case OpenFoodFactsCountry.EQUATORIAL_GUINEA:
        return 'Equatorial Guinea';
      case OpenFoodFactsCountry.GREECE:
        return 'Greece';
      case OpenFoodFactsCountry.SOUTH_GEORGIA:
        return 'South Georgia and the South Sandwich Islands';
      case OpenFoodFactsCountry.GUATEMALA:
        return 'Guatemala';
      case OpenFoodFactsCountry.GUAM:
        return 'Guam';
      case OpenFoodFactsCountry.GUINEA_BISSAU:
        return 'Guinea-Bissau';
      case OpenFoodFactsCountry.GUYANA:
        return 'Guyana';
      case OpenFoodFactsCountry.HONG_KONG:
        return 'Hong Kong';
      case OpenFoodFactsCountry.HEARD_ISLAND:
        return 'Heard Island and McDonald Islands';
      case OpenFoodFactsCountry.HONDURAS:
        return 'Honduras';
      case OpenFoodFactsCountry.CROATIA:
        return 'Croatia';
      case OpenFoodFactsCountry.HAITI:
        return 'Haiti';
      case OpenFoodFactsCountry.HUNGARY:
        return 'Hungary';
      case OpenFoodFactsCountry.INDONESIA:
        return 'Indonesia';
      case OpenFoodFactsCountry.IRELAND:
        return 'Ireland';
      case OpenFoodFactsCountry.ISRAEL:
        return 'Israel';
      case OpenFoodFactsCountry.ISLE_OF_MAN:
        return 'Isle of Man';
      case OpenFoodFactsCountry.INDIA:
        return 'India';
      case OpenFoodFactsCountry.BRITISH_INDIAN_OCEAN_TERRITORY:
        return 'British Indian Ocean Territory';
      case OpenFoodFactsCountry.IRAQ:
        return 'Iraq';
      case OpenFoodFactsCountry.IRAN:
        return 'Iran';
      case OpenFoodFactsCountry.ICELAND:
        return 'Iceland';
      case OpenFoodFactsCountry.ITALY:
        return 'Italy';
      case OpenFoodFactsCountry.JERSEY:
        return 'Jersey';
      case OpenFoodFactsCountry.JAMAICA:
        return 'Jamaica';
      case OpenFoodFactsCountry.JORDAN:
        return 'Jordan';
      case OpenFoodFactsCountry.JAPAN:
        return 'Japan';
      case OpenFoodFactsCountry.KENYA:
        return 'Kenya';
      case OpenFoodFactsCountry.KYRGYZSTAN:
        return 'Kyrgyzstan';
      case OpenFoodFactsCountry.CAMBODIA:
        return 'Cambodia';
      case OpenFoodFactsCountry.KIRIBATI:
        return 'Kiribati';
      case OpenFoodFactsCountry.COMOROS:
        return 'Comoros';
      case OpenFoodFactsCountry.SAINT_KITTS_AND_NEVIS:
        return 'Saint Kitts and Nevis';
      case OpenFoodFactsCountry.NORTH_KOREA:
        return 'North Korea';
      case OpenFoodFactsCountry.SOUTH_KOREA:
        return 'South Korea';
      case OpenFoodFactsCountry.KUWAIT:
        return 'Kuwait';
      case OpenFoodFactsCountry.CAYMAN_ISLANDS:
        return 'Cayman Islands';
      case OpenFoodFactsCountry.KAZAKHSTAN:
        return 'Kazakhstan';
      case OpenFoodFactsCountry.LAOS:
        return 'Laos';
      case OpenFoodFactsCountry.LEBANON:
        return 'Lebanon';
      case OpenFoodFactsCountry.SAINT_LUCIA:
        return 'Saint Lucia';
      case OpenFoodFactsCountry.LIECHTENSTEIN:
        return 'Liechtenstein';
      case OpenFoodFactsCountry.SRI_LANKA:
        return 'Sri Lanka';
      case OpenFoodFactsCountry.LIBERIA:
        return 'Liberia';
      case OpenFoodFactsCountry.LESOTHO:
        return 'Lesotho';
      case OpenFoodFactsCountry.LITHUANIA:
        return 'Lithuania';
      case OpenFoodFactsCountry.LUXEMBOURG:
        return 'Luxembourg';
      case OpenFoodFactsCountry.LATVIA:
        return 'Latvia';
      case OpenFoodFactsCountry.LIBYA:
        return 'Libya';
      case OpenFoodFactsCountry.MOROCCO:
        return 'Morocco';
      case OpenFoodFactsCountry.MONACO:
        return 'Monaco';
      case OpenFoodFactsCountry.MOLDOVA:
        return 'Moldova';
      case OpenFoodFactsCountry.MONTENEGRO:
        return 'Montenegro';
      case OpenFoodFactsCountry.SAINT_MARTIN:
        return 'Saint Martin';
      case OpenFoodFactsCountry.MADAGASCAR:
        return 'Madagascar';
      case OpenFoodFactsCountry.MARSHALL_ISLANDS:
        return 'Marshall Islands';
      case OpenFoodFactsCountry.NORTH_MACEDONIA:
        return 'North Macedonia';
      case OpenFoodFactsCountry.MALI:
        return 'Mali';
      case OpenFoodFactsCountry.MYANMAR:
        return 'Myanmar';
      case OpenFoodFactsCountry.MONGOLIA:
        return 'Mongolia';
      case OpenFoodFactsCountry.MACAO:
        return 'Macao';
      case OpenFoodFactsCountry.NORTHERN_MARIANA_ISLANDS:
        return 'Northern Mariana Islands';
      case OpenFoodFactsCountry.MARTINIQUE:
        return 'Martinique';
      case OpenFoodFactsCountry.MAURITANIA:
        return 'Mauritania';
      case OpenFoodFactsCountry.MONTSERRAT:
        return 'Montserrat';
      case OpenFoodFactsCountry.MALTA:
        return 'Malta';
      case OpenFoodFactsCountry.MAURITIUS:
        return 'Mauritius';
      case OpenFoodFactsCountry.MALDIVES:
        return 'Maldives';
      case OpenFoodFactsCountry.MALAWI:
        return 'Malawi';
      case OpenFoodFactsCountry.MEXICO:
        return 'Mexico';
      case OpenFoodFactsCountry.MALAYSIA:
        return 'Malaysia';
      case OpenFoodFactsCountry.MOZAMBIQUE:
        return 'Mozambique';
      case OpenFoodFactsCountry.NAMIBIA:
        return 'Namibia';
      case OpenFoodFactsCountry.NEW_CALEDONIA:
        return 'New Caledonia';
      case OpenFoodFactsCountry.NIGER:
        return 'Niger';
      case OpenFoodFactsCountry.NORFOLK_ISLAND:
        return 'Norfolk Island';
      case OpenFoodFactsCountry.NIGERIA:
        return 'Nigeria';
      case OpenFoodFactsCountry.NICARAGUA:
        return 'Nicaragua';
      case OpenFoodFactsCountry.NETHERLANDS:
        return 'Netherlands';
      case OpenFoodFactsCountry.NORWAY:
        return 'Norway';
      case OpenFoodFactsCountry.NEPAL:
        return 'Nepal';
      case OpenFoodFactsCountry.NAURU:
        return 'Nauru';
      case OpenFoodFactsCountry.NIUE:
        return 'Niue';
      case OpenFoodFactsCountry.NEW_ZEALAND:
        return 'New Zealand';
      case OpenFoodFactsCountry.OMAN:
        return 'Oman';
      case OpenFoodFactsCountry.PANAMA:
        return 'Panama';
      case OpenFoodFactsCountry.PERU:
        return 'Peru';
      case OpenFoodFactsCountry.FRENCH_POLYNESIA:
        return 'French Polynesia';
      case OpenFoodFactsCountry.PAPUA_NEW_GUINEA:
        return 'Papua New Guinea';
      case OpenFoodFactsCountry.PHILIPPINES:
        return 'Philippines';
      case OpenFoodFactsCountry.PAKISTAN:
        return 'Pakistan';
      case OpenFoodFactsCountry.POLAND:
        return 'Poland';
      case OpenFoodFactsCountry.SAINT_PIERRE_AND_MIQUELON:
        return 'Saint Pierre and Miquelon';
      case OpenFoodFactsCountry.PITCAIRN:
        return 'Pitcairn';
      case OpenFoodFactsCountry.PUERTO_RICO:
        return 'Puerto Rico';
      case OpenFoodFactsCountry.PALESTINE:
        return 'Palestine';
      case OpenFoodFactsCountry.PORTUGAL:
        return 'Portugal';
      case OpenFoodFactsCountry.PALAU:
        return 'Palau';
      case OpenFoodFactsCountry.PARAGUAY:
        return 'Paraguay';
      case OpenFoodFactsCountry.QATAR:
        return 'Qatar';
      case OpenFoodFactsCountry.REUNION:
        return 'Réunion';
      case OpenFoodFactsCountry.ROMANIA:
        return 'Romania';
      case OpenFoodFactsCountry.SERBIA:
        return 'Serbia';
      case OpenFoodFactsCountry.RUSSIA:
        return 'Russia';
      case OpenFoodFactsCountry.RWANDA:
        return 'Rwanda';
      case OpenFoodFactsCountry.SAUDI_ARABIA:
        return 'Saudi Arabia';
      case OpenFoodFactsCountry.SOLOMON_ISLANDS:
        return 'Solomon Islands';
      case OpenFoodFactsCountry.SEYCHELLES:
        return 'Seychelles';
      case OpenFoodFactsCountry.SUDAN:
        return 'Sudan';
      case OpenFoodFactsCountry.SWEDEN:
        return 'Sweden';
      case OpenFoodFactsCountry.SINGAPORE:
        return 'Singapore';
      case OpenFoodFactsCountry.SAINT_HELENA:
        return 'Saint Helena, Ascension and Tristan da Cunha';
      case OpenFoodFactsCountry.SLOVENIA:
        return 'Slovenia';
      case OpenFoodFactsCountry.SVALBARD_AND_JAN_MAYEN:
        return 'Svalbard and Jan Mayen';
      case OpenFoodFactsCountry.SLOVAKIA:
        return 'Slovakia';
      case OpenFoodFactsCountry.SIERRA_LEONE:
        return 'Sierra Leone';
      case OpenFoodFactsCountry.SAN_MARINO:
        return 'San Marino';
      case OpenFoodFactsCountry.SENEGAL:
        return 'Senegal';
      case OpenFoodFactsCountry.SOMALIA:
        return 'Somalia';
      case OpenFoodFactsCountry.SURINAME:
        return 'Suriname';
      case OpenFoodFactsCountry.SOUTH_SUDAN:
        return 'South Sudan';
      case OpenFoodFactsCountry.SAO_TOME_AND_PRINCIPE:
        return 'Sao Tome and Principe';
      case OpenFoodFactsCountry.EL_SALVADOR:
        return 'El Salvador';
      case OpenFoodFactsCountry.SINT_MAARTEN:
        return 'Sint Maarten';
      case OpenFoodFactsCountry.SYRIA:
        return 'Syria';
      case OpenFoodFactsCountry.ESWATINI:
        return 'Eswatini';
      case OpenFoodFactsCountry.TURKS_AND_CAICOS_ISLANDS:
        return 'Turks and Caicos Islands';
      case OpenFoodFactsCountry.CHAD:
        return 'Chad';
      case OpenFoodFactsCountry.FRENCH_SOUTHERN_TERRITORIES:
        return 'French Southern Territories';
      case OpenFoodFactsCountry.TOGO:
        return 'Togo';
      case OpenFoodFactsCountry.THAILAND:
        return 'Thailand';
      case OpenFoodFactsCountry.TAJIKISTAN:
        return 'Tajikistan';
      case OpenFoodFactsCountry.TOKELAU:
        return 'Tokelau';
      case OpenFoodFactsCountry.TIMOR_LESTE:
        return 'Timor-Leste';
      case OpenFoodFactsCountry.TURKMENISTAN:
        return 'Turkmenistan';
      case OpenFoodFactsCountry.TUNISIA:
        return 'Tunisia';
      case OpenFoodFactsCountry.TONGA:
        return 'Tonga';
      case OpenFoodFactsCountry.TURKEY:
        return 'Turkey';
      case OpenFoodFactsCountry.TRINIDAD_AND_TOBAGO:
        return 'Trinidad and Tobago';
      case OpenFoodFactsCountry.TUVALU:
        return 'Tuvalu';
      case OpenFoodFactsCountry.TAIWAN:
        return 'Taiwan';
      case OpenFoodFactsCountry.TANZANIA:
        return 'Tanzania';
      case OpenFoodFactsCountry.UKRAINE:
        return 'Ukraine';
      case OpenFoodFactsCountry.UGANDA:
        return 'Uganda';
      case OpenFoodFactsCountry.UNITED_STATES_MINOR_OUTLYING_ISLANDS:
        return 'United States Minor Outlying Islands';
      case OpenFoodFactsCountry.USA:
        return 'United States';
      case OpenFoodFactsCountry.URUGUAY:
        return 'Uruguay';
      case OpenFoodFactsCountry.UZBEKISTAN:
        return 'Uzbekistan';
      case OpenFoodFactsCountry.HOLY_SEE:
        return 'Holy See';
      case OpenFoodFactsCountry.SAINT_VINCENT_AND_THE_GRENADINES:
        return 'Saint Vincent and the Grenadines';
      case OpenFoodFactsCountry.VENEZUELA:
        return 'Venezuela';
      case OpenFoodFactsCountry.BRITISH_VIRGIN_ISLANDS:
        return 'British Virgin Islands';
      case OpenFoodFactsCountry.US_VIRGIN_ISLANDS:
        return 'U.S. Virgin Islands';
      case OpenFoodFactsCountry.VIET_NAM:
        return 'Vietnam';
      case OpenFoodFactsCountry.VANUATU:
        return 'Vanuatu';
      case OpenFoodFactsCountry.WALLIS_AND_FUTUNA:
        return 'Wallis and Futuna';
      case OpenFoodFactsCountry.SAMOA:
        return 'Samoa';
      case OpenFoodFactsCountry.YEMEN:
        return 'Yemen';
      case OpenFoodFactsCountry.MAYOTTE:
        return 'Mayotte';
      case OpenFoodFactsCountry.SOUTH_AFRICA:
        return 'South Africa';
      case OpenFoodFactsCountry.ZAMBIA:
        return 'Zambia';
      case OpenFoodFactsCountry.ZIMBABWE:
        return 'Zimbabwe';
    }
  }
}
