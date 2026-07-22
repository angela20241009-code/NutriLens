// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'NutriLens';

  @override
  String get languageLabel => '语言';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageChinese => '中文';

  @override
  String get languagePickerTitle => '语言';

  @override
  String get cancel => '取消';

  @override
  String get saveChanges => '保存更改';

  @override
  String get signOut => '退出登录';

  @override
  String get deleteAccount => '删除账户';

  @override
  String comingSoon(String feature) {
    return '$feature 即将推出';
  }

  @override
  String get authCreateTitle => '创建账户';

  @override
  String get authWelcomeBack => '欢迎回来';

  @override
  String get authCreate => '创建';

  @override
  String get authSignIn => '登录';

  @override
  String get authMealPreferences => '饮食偏好';

  @override
  String get authMealPreferencesHint => '登录前告诉我们您喜欢什么以及需要避免什么。';

  @override
  String get authMealsPerDay => '每日餐数';

  @override
  String get authMealsPerDayHint => '您通常一天吃几餐？';

  @override
  String get authEmail => '电子邮件';

  @override
  String get authPassword => '密码';

  @override
  String get authCreateAccount => '创建账户';

  @override
  String get authContinueAsGuest => '以访客身份继续';

  @override
  String get authValidationEmailRequired => '请输入电子邮件';

  @override
  String get authValidationEmailInvalid => '请输入有效的电子邮件';

  @override
  String get authValidationPasswordMin => '密码至少需要6个字符';

  @override
  String get authErrorWeakPassword => '请使用更强的密码。';

  @override
  String get authErrorEmailInUse => '该电子邮件已有账户。';

  @override
  String get authErrorInvalidEmail => '请输入有效的电子邮件地址。';

  @override
  String get authErrorWrongCredentials => '电子邮件或密码不正确。';

  @override
  String get authErrorNetwork => '请检查网络连接后重试。';

  @override
  String get authErrorGeneric => '身份验证失败，请重试。';

  @override
  String get mealStylesTitle => '您喜欢的饮食风格';

  @override
  String get mealStyleHighProtein => '高蛋白';

  @override
  String get mealStyleMediterranean => '地中海';

  @override
  String get mealStyleVegetarian => '素食';

  @override
  String get mealStyleVegan => '纯素';

  @override
  String get mealStyleGlutenFree => '无麸质';

  @override
  String get mealStyleLowCarb => '低碳水';

  @override
  String get mealStyleBalanced => '均衡';

  @override
  String get mealStyleAsianInspired => '亚洲风味';

  @override
  String get mealStyleOthers => '其他';

  @override
  String get mealStyleOtherLabel => '其他饮食风格';

  @override
  String get mealStyleOtherHelper => '描述您偏好的饮食风格';

  @override
  String get allergensLabel => '过敏原';

  @override
  String get allergensHelper => '使用逗号或换行分隔。例如：花生、贝类';

  @override
  String get restrictionsLabel => '饮食限制';

  @override
  String get restrictionsHelper => '使用逗号或换行分隔。例如：清真、无乳制品';

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionAccount => '账户';

  @override
  String get sectionPersonal => '个人信息';

  @override
  String get sectionAthlete => '运动员';

  @override
  String get sectionNutritionGoals => '营养目标';

  @override
  String get sectionDietary => '饮食';

  @override
  String get sectionDisplay => '显示';

  @override
  String get sectionApp => '应用';

  @override
  String get displayName => '显示名称';

  @override
  String get nameRequired => '名称为必填项';

  @override
  String get email => '电子邮件';

  @override
  String get notLinked => '未关联';

  @override
  String get createAccount => '创建账户';

  @override
  String get changePassword => '更改密码';

  @override
  String get gender => '性别';

  @override
  String get selectGender => '选择性别';

  @override
  String get genderFemale => '女性';

  @override
  String get genderMale => '男性';

  @override
  String get genderNonBinary => '非二元';

  @override
  String get genderPreferNotToSay => '不愿透露';

  @override
  String get phoneNumber => '电话号码';

  @override
  String get birthYear => '出生年份';

  @override
  String get enterValidYear => '请输入有效年份';

  @override
  String get heightCm => '身高 (cm)';

  @override
  String get weightKg => '体重 (kg)';

  @override
  String get primarySport => '主要运动';

  @override
  String get noSportSelected => '未选择运动';

  @override
  String get school => '学校';

  @override
  String get graduationYear => '毕业年份';

  @override
  String get trainingDaysPerWeek => '每周训练天数';

  @override
  String get selectTrainingDays => '选择训练天数';

  @override
  String trainingDaysCount(int count) {
    return '$count 天';
  }

  @override
  String get activityLevel => '活动水平';

  @override
  String get selectActivityLevel => '选择活动水平';

  @override
  String get activityLow => '低';

  @override
  String get activityModerate => '中等';

  @override
  String get activityHigh => '高';

  @override
  String get activityVeryHigh => '非常高';

  @override
  String get caloriesKcal => '卡路里 (kcal)';

  @override
  String get proteinG => '蛋白质 (g)';

  @override
  String get carbsG => '碳水化合物 (g)';

  @override
  String get fatsG => '脂肪 (g)';

  @override
  String get hydrationL => '饮水量 (L)';

  @override
  String get sleepHrs => '睡眠 (小时)';

  @override
  String get fieldRequired => '必填';

  @override
  String get enterNumber => '请输入数字';

  @override
  String get accessibilityMode => '无障碍模式';

  @override
  String get textSize => '文字大小';

  @override
  String get themeColors => '主题颜色';

  @override
  String get textScaleSmall => '小';

  @override
  String get textScaleMedium => '中';

  @override
  String get textScaleLarge => '大';

  @override
  String get textScaleExtraLarge => '特大';

  @override
  String get textScaleSmallDesc => '紧凑的标签和正文。';

  @override
  String get textScaleMediumDesc => '默认文字大小。';

  @override
  String get textScaleLargeDesc => '在大多数屏幕上更易阅读。';

  @override
  String get textScaleExtraLargeDesc => '最大可读性。';

  @override
  String get themeClassic => '经典青柠';

  @override
  String get themeOcean => '海洋蓝';

  @override
  String get themeSunset => '日落珊瑚';

  @override
  String get themeForest => '森林绿';

  @override
  String get themePaletteDesc => '整个应用中的强调色和高亮色。';

  @override
  String get sleepMode => '睡眠模式';

  @override
  String get notifications => '通知';

  @override
  String get units => '单位';

  @override
  String get changesSaved => '更改已保存';

  @override
  String failedToSave(String error) {
    return '保存失败：$error';
  }

  @override
  String unableToLoadSettings(String error) {
    return '无法加载设置：$error';
  }

  @override
  String unableToUpdateTextSize(String error) {
    return '无法更新文字大小：$error';
  }

  @override
  String unableToUpdateTheme(String error) {
    return '无法更新主题：$error';
  }

  @override
  String unableToUpdateLanguage(String error) {
    return '无法更新语言：$error';
  }

  @override
  String unableToSignOut(String error) {
    return '无法退出登录：$error';
  }

  @override
  String unableToDeleteAccount(String error) {
    return '无法删除账户：$error';
  }

  @override
  String failedToInitializeApp(String error) {
    return '无法初始化应用：\n$error';
  }

  @override
  String failedToLoadAccount(String error) {
    return '无法加载账户：\n$error';
  }
}
