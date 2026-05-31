abstract final class RouteConstants {
  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String categoryProducts = '/categories/:id';
  static const String productDetail = '/products/:id';
  static const String offerList = '/offers';
  static const String offerDetail = '/offers/:id';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static const String admin = '/admin';
  static const String adminProducts = '/admin/products';
  static const String adminProductNew = '/admin/products/new';
  static const String adminProductEdit = '/admin/products/:id';
  static const String adminCategories = '/admin/categories';
  static const String adminCategoryNew = '/admin/categories/new';
  static const String adminCategoryEdit = '/admin/categories/:id';
  static const String adminOffers = '/admin/offers';
  static const String adminOfferNew = '/admin/offers/new';
  static const String adminOfferEdit = '/admin/offers/:id';
  static const String adminBanners = '/admin/banners';
  static const String adminBannerNew = '/admin/banners/new';
  static const String adminBannerEdit = '/admin/banners/:id';
  static const String adminUsers = '/admin/users';
  static const String adminSettings = '/admin/settings';

  static String categoryProductsPath(String id) => '/categories/$id';
  static String productDetailPath(String id) => '/products/$id';
  static String offerDetailPath(String id) => '/offers/$id';
  static String adminProductEditPath(String id) => '/admin/products/$id';
  static String adminCategoryEditPath(String id) => '/admin/categories/$id';
  static String adminOfferEditPath(String id) => '/admin/offers/$id';
  static String adminBannerEditPath(String id) => '/admin/banners/$id';
}
