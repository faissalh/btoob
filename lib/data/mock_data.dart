import '../models/offer.dart';
import '../models/purchase_request.dart';
import '../models/company.dart';

class MockData {
  static const List<String> categories = [
    'الكل',
    'مواد بناء',
    'آلات ومعدات صناعية',
    'مواد غذائية',
    'أثاث ومفروشات',
    'أجهزة كهربائية',
    'إلكترونيات',
    'بلاستيك ومطاط',
    'حديد وصلب',
    'مواد كيميائية',
    'زراعة ومستلزمات زراعية',
    'سيارات وقطع غيار',
    'أدوية ومستلزمات طبية',
    'ملابس ومنسوجات',
    'تغليف وعبوات',
    'ورق ومطبوعات',
    'أدوات ومستلزمات مكتبية',
    'مستلزمات فندقية ومطاعم',
    'طاقة ومياه',
    'نقل وخدمات لوجستية',
    'خدمات مهنية',
    'أخرى',
  ];

  static const List<String> gulfCountries = [
    'السعودية',
    'الإمارات',
    'الكويت',
    'قطر',
    'البحرين',
    'عُمان',
  ];

  static bool matchesCategory(String? itemCategory, String selectedCategory) {
    if (selectedCategory == 'الكل') return true;
    if (selectedCategory == 'أخرى') {
      return itemCategory == null ||
          itemCategory == 'أخرى' ||
          !categories.contains(itemCategory);
    }
    return itemCategory == selectedCategory;
  }

  static final List<Offer> offers = [
    const Offer(
      id: 'o1',
      title: 'رمل وحصى مكسر — توريد يومي',
      type: 'منتج',
      price: 'من 32 ر.س/متر مكعب',
      minOrder: '100 م³',
      category: 'مواد بناء',
      countries: ['عُمان', 'السعودية'],
      companyName: 'الرمال والحصى للإعمار',
      rating: 4.2,
      colorIndex: 0,
      description: 'رمل وحصى مكسر عالي الجودة للمشاريع الإنشائية. توريد يومي بكميات كبيرة مع ضمان الجودة وفق المعايير المعتمدة.',
      details: 'متوفر بأحجام مختلفة: ناعم، متوسط، خشن. مناسب للخرسانة والبناء.',
      features: [
        'توريد يومي منتظم',
        'أحجام متعددة',
        'شهادة جودة معتمدة',
        'أسعار تنافسية للكميات الكبيرة',
      ],
    ),
    const Offer(
      id: 'o2',
      title: 'معدات صناعية — صيانة وقطع غيار',
      type: 'خدمة',
      price: 'حسب المشروع',
      category: 'آلات ومعدات صناعية',
      countries: ['السعودية', 'الإمارات', 'الكويت', 'قطر'],
      companyName: 'الشرق المتوسط للصلب',
      isVerified: true,
      rating: 4.5,
      colorIndex: 1,
      description: 'خدمات صيانة شاملة للمعدات الصناعية مع توفير قطع الغيار الأصلية. فريق فني متخصص بخبرة تزيد عن 15 سنة.',
      features: [
        'قطع غيار أصلية',
        'فريق فني متخصص',
        'ضمان على الصيانة',
        'خدمة 24/7 للحالات الطارئة',
      ],
    ),
    const Offer(
      id: 'o3',
      title: 'منتجات غذائية معلبة — تصدير للخليج',
      type: 'منتج',
      price: 'من 42 ر.س/كرتون',
      minOrder: '500 كرتون',
      category: 'مواد غذائية',
      countries: ['الكويت', 'قطر', 'البحرين', 'السعودية'],
      companyName: 'المصنع الوطني للأغذية',
      isVerified: true,
      rating: 4.6,
      colorIndex: 2,
      description: 'منتجات غذائية معلبة عالية الجودة بشهادة ISO22000. تشمل: فول، حمص، تونة، خضار معلبة.',
      features: [
        'شهادة ISO22000',
        'تعبئة وتغليف حديث',
        'صلاحية طويلة',
        'أسعار جملة تنافسية',
      ],
    ),
    const Offer(
      id: 'o4',
      title: 'أثاث مكتبي يُنفّذ حسب الطلب',
      type: 'منتج',
      price: 'من 1,900 ر.س/قطعة',
      minOrder: '10 قطع',
      category: 'أثاث ومفروشات',
      countries: ['قطر', 'السعودية', 'عُمان'],
      companyName: 'مصانع الخليج للأثاث',
      rating: 4.4,
      colorIndex: 3,
      description: 'أثاث مكتبي تنفيذي يُصنع حسب الطلب بأعلى معايير الجودة.',
      features: [
        'تصميم حسب الطلب',
        'خامات فاخرة',
        'ضمان 5 سنوات',
        'تركيب مجاني',
      ],
    ),
    const Offer(
      id: 'o5',
      title: 'أجهزة منزلية من المصنع — شحنة جاهزة',
      type: 'منتج',
      price: 'بالجملة — اسأل عن السعر',
      minOrder: '20 وحدة',
      category: 'أجهزة كهربائية',
      countries: ['السعودية', 'الكويت', 'البحرين'],
      companyName: 'تقنية الشرق الحديثة',
      isVerified: true,
      rating: 4.8,
      colorIndex: 4,
      description: 'أجهزة منزلية جاهزة للشحن: ثلاجات، غسالات، مكيفات، أفران. مباشرة من المصنع بأسعار الجملة.',
      features: [
        'مباشرة من المصنع',
        'ضمان رسمي',
        'شحن لجميع دول الخليج',
        'أسعار جملة تنافسية',
      ],
    ),
    const Offer(
      id: 'o6',
      title: 'أجهزة نقاط بيع 2026 — الجيل الجديد',
      type: 'منتج',
      price: 'من 1,450 ر.س/وحدة',
      minOrder: '10 وحدات',
      category: 'إلكترونيات',
      countries: ['السعودية', 'الإمارات', 'قطر'],
      companyName: 'تقنية الشرق الحديثة',
      isVerified: true,
      rating: 4.8,
      colorIndex: 5,
      description: 'أجهزة نقاط بيع الجيل الجديد 2026 مع شاشة لمس، طابعة حرارية مدمجة، ودعم جميع وسائل الدفع.',
      features: [
        'شاشة لمس 10 بوصة',
        'طابعة حرارية مدمجة',
        'دعم جميع وسائل الدفع',
        'نظام سحابي متكامل',
      ],
    ),
    const Offer(
      id: 'o7',
      title: 'أنابيب PP-R للسباكة — أقطار متعددة',
      type: 'منتج',
      price: 'من 8 ر.س/متر',
      minOrder: '1000 متر',
      category: 'بلاستيك ومطاط',
      countries: ['السعودية', 'الإمارات', 'البحرين'],
      companyName: 'مصنع الخليج للبلاستيك',
      isVerified: true,
      rating: 4.7,
      colorIndex: 6,
      description:
          'أنابيب PP-R وPVC بأقطار متعددة لمشاريع السباكة والبنية التحتية.',
      features: [
        'شهادة ISO9001',
        'أقطار من 20mm إلى 160mm',
        'مقاومة للحرارة والضغط',
      ],
    ),
    const Offer(
      id: 'o8',
      title: 'حديد تسليح — توريد بالطن',
      type: 'منتج',
      price: 'من 2,800 ر.س/طن',
      minOrder: '50 طن',
      category: 'حديد وصلب',
      countries: ['الإمارات', 'السعودية', 'عُمان'],
      companyName: 'الشرق المتوسط للصلب',
      isVerified: true,
      rating: 4.5,
      colorIndex: 7,
      description:
          'حديد تسليح بجميع المقاسات وفق المواصفات السعودية والإماراتية.',
      features: ['مواصفات ASTM', 'توريد سريع', 'أسعار تنافسية'],
    ),
  ];

  static final List<PurchaseRequest> purchaseRequests = [
    const PurchaseRequest(
      id: 'pr1',
      title: 'أجهزة تكييف سبليت 3 طن — 500 وحدة',
      status: 'مفتوح',
      buyerName: 'مؤسسة النور التجارية',
      contactPerson: 'أ. هدى العنزي',
      quantity: '500 وحدة',
      budget: '400,000 - 600,000 ر.س',
      country: 'السعودية',
      city: 'جدة',
      description: 'نحتاج 500 وحدة تكييف سبليت 3 طن للمشاريع السكنية. يفضل أن تكون موفرة للطاقة بتصنيف A+ أو أعلى.',
      deadline: '2026-12-15',
      category: 'أجهزة كهربائية',
    ),
    const PurchaseRequest(
      id: 'pr2',
      title: 'طابعات حرارية للمطاعم — 200 وحدة',
      status: 'مفتوح',
      buyerName: 'شركة وجبة الخليج',
      contactPerson: 'م. خالد الشمري',
      quantity: '200 وحدة',
      budget: '80,000 - 120,000 ر.س',
      country: 'السعودية',
      city: 'الرياض',
      description:
          'نبحث عن طابعات حرارية 80mm مع قاطع أوتوماتيكي لفروع المطاعم.',
      deadline: '2026-11-30',
      category: 'إلكترونيات',
    ),
    const PurchaseRequest(
      id: 'pr3',
      title: 'مواد تعبئة وتغليف غذائي — كميات شهرية',
      status: 'مفتوح',
      buyerName: 'مصنع الريان للحلويات',
      contactPerson: 'أ. فاطمة القحطاني',
      quantity: '10,000 وحدة/شهر',
      budget: '50,000 - 75,000 ر.س/شهر',
      country: 'السعودية',
      city: 'الدمام',
      description:
          'نحتاج علب كرتونية مطبوعة بالألوان لتعبئة الحلويات والمعجنات.',
      deadline: '2026-11-01',
      category: 'مواد غذائية',
    ),
  ];

  static final List<Company> companies = [
    const Company(
      id: 'c1',
      name: 'مصنع الخليج للبلاستيك',
      isVerified: true,
      type: 'مصنع',
      country: 'السعودية',
      city: 'الرياض',
      description: 'مصنع أنابيب PP-R وPVC بأقطار متعددة، بشهادة ISO9001، وتوريد مباشر مع شهادات مطابقة.',
      rating: 4.7,
      reviewCount: 64,
      offersCount: 1,
      phone: '+966 11 xxx xxxx',
      email: 'info@gulfplastic.sa',
      certifications: ['ISO9001', 'SASO'],
      yearEstablished: 2008,
    ),
    const Company(
      id: 'c2',
      name: 'الشرق المتوسط للصلب',
      isVerified: true,
      type: 'مورد',
      country: 'الإمارات',
      city: 'دبي',
      description: 'مورد حديد تسليح وألمنيوم للجملة في دول الخليج، بأسعار تنافسية وتوريد يومي.',
      rating: 4.5,
      reviewCount: 112,
      offersCount: 2,
      phone: '+971 4 xxx xxxx',
      email: 'sales@mideaststeel.ae',
      certifications: ['ISO9001', 'ISO14001'],
      yearEstablished: 2003,
    ),
    const Company(
      id: 'c3',
      name: 'تقنية الشرق الحديثة',
      isVerified: true,
      type: 'مورد',
      country: 'السعودية',
      city: 'جدة',
      description: 'أجهزة نقاط بيع وأنظمة محاسبة سحابية للشركات، مع دعم فني عربي وضمان سنتين.',
      rating: 4.8,
      reviewCount: 89,
      offersCount: 2,
      phone: '+966 12 xxx xxxx',
      email: 'info@easttech.sa',
      certifications: ['ISO27001'],
      yearEstablished: 2015,
    ),
    const Company(
      id: 'c4',
      name: 'المصنع الوطني للأغذية',
      isVerified: true,
      type: 'مصنع',
      country: 'الكويت',
      city: 'الكويت',
      description: 'منتجات غذائية معلبة بشهادة ISO22000، وتصدير إلى الخليج والشرق الأوسط.',
      rating: 4.6,
      reviewCount: 47,
      offersCount: 1,
      phone: '+965 xxxx xxxx',
      email: 'export@natfood.kw',
      certifications: ['ISO22000', 'HACCP'],
      yearEstablished: 1998,
    ),
    const Company(
      id: 'c5',
      name: 'مصانع الخليج للأثاث',
      type: 'مصنع',
      country: 'قطر',
      city: 'الدوحة',
      description:
          'أثاث مكتبي تنفيذي يُنفّذ حسب الطلب، بخامات مستوردة وضمان خمس سنوات.',
      rating: 4.4,
      reviewCount: 36,
      offersCount: 1,
      certifications: [],
      yearEstablished: 2012,
    ),
    const Company(
      id: 'c6',
      name: 'الرمال والحصى للإعمار',
      type: 'مورد',
      country: 'عُمان',
      city: 'مسقط',
      description: 'رمل وحصى وبلاط خرساني جاهزة للمشاريع، بتوريد يومي.',
      rating: 4.2,
      reviewCount: 28,
      offersCount: 1,
      certifications: [],
      yearEstablished: 2010,
    ),
  ];

  static List<Offer> getCompanyOffers(String companyName) {
    return offers.where((o) => o.companyName == companyName).toList();
  }

  static Company? getCompanyByName(String name) {
    try {
      return companies.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}
