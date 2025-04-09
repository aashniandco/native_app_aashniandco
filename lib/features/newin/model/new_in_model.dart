// class NewInProduct {
//   final String designerName;
//   final double actualPrice;
//   final String productId;
//   final String sku;
//
//   final String shortDesc;
//   final String smallImgUrl;
//   final String thumbImgUrl;
//
//   NewInProduct({
//     required this.designerName,
//     required this.actualPrice,
//     required this.productId,
//     required this.sku,
//
//     required this.shortDesc,
//     required this.smallImgUrl,
//     required this.thumbImgUrl,
//   });
//
//   factory NewInProduct.fromJson(Map<String, dynamic> json) {
//     return NewInProduct(
//       designerName: json['designer_name'] ?? '',
//       actualPrice: (json['actual_price_1'] ?? 0).toDouble(),
//       productId: json['prod_en_id'].toString(),
//       sku: json['prod_sku'] ?? '',
//
//       shortDesc: json['short_desc'] ?? '',
//       smallImgUrl: json['prod_small_img'] ?? '',
//       thumbImgUrl: json['prod_thumb_img'] ?? '',
//     );
//   }
//
//
//   String parseProductName(dynamic raw) {
//     if (raw == null) return '';
//     if (raw is List && raw.isNotEmpty) return raw.first.toString();
//     if (raw is String) return raw;
//     return raw.toString();
//   }
//
//
// }



class SolrProductResponse {
  final int numFound;
  final List<Product> products;

  SolrProductResponse({
    required this.numFound,
    required this.products,
  });

  factory SolrProductResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'];
    return SolrProductResponse(
      numFound: response['numFound'],
      products: (response['docs'] as List<dynamic>)
          .map((doc) => Product.fromJson(doc))
          .toList(),
    );
  }
}

class Product {
  final String designerName;
  final double actualPrice;
  final String shortDesc;

  final String prodSmallImg;

  Product({
    required this.designerName,
    required this.actualPrice,
    required this.shortDesc,

    required this.prodSmallImg,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      designerName: json['designer_name'] ?? '',
      actualPrice: (json['actual_price_1'] ?? 0).toDouble(),
      shortDesc: json['short_desc'] ?? '',

      prodSmallImg: json['prod_small_img'] ?? '',
    );
  }
}


