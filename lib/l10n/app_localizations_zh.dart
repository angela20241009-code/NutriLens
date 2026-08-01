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
  String get profile => '资料';

  @override
  String get profileUnavailable => '资料不可用';

  @override
  String unableToLoadProfile(Object error) {
    return '无法加载资料：$error';
  }

  @override
  String get noNameSet => '未设置姓名';

  @override
  String get phone => '电话';

  @override
  String get sport => '运动';

  @override
  String get height => '身高';

  @override
  String get weight => '体重';

  @override
  String get trainingDays => '训练日';

  @override
  String get sleepTarget => '睡眠目标';

  @override
  String get allergens => '过敏原';

  @override
  String get restrictions => '限制';

  @override
  String get editProfileAndSettings => '编辑资料和设置';

  @override
  String get guestCreateAccountTitle => '创建账户';

  @override
  String get guestCreateAccountBody => '注册以保存您的资料、营养目标和训练数据。';

  @override
  String get guestAccountNotice => '您正在使用无云同步的访客账户。创建账户保存数据前，资料编辑已禁用。';

  @override
  String get signOutTitle => '退出登录？';

  @override
  String get signOutGuestBody => '您尚未绑定邮箱。退出可能会丢失此设备上的数据。';

  @override
  String signOutAccountBody(String account) {
    return '退出 $account？';
  }

  @override
  String get yourAccount => '您的账户';

  @override
  String get deleteAccountTitle => '删除账户？';

  @override
  String get deleteGuestAccountBody =>
      '这将永久删除您的访客账户及此设备上所有已记录的餐食、睡眠和资料数据，无法撤销。';

  @override
  String deleteAccountBody(String account) {
    return '这将永久删除 $account 及所有相关数据，无法撤销。';
  }

  @override
  String get mealPreferencesDescription => '选择饮食风格和过敏信息，以便我们个性化您的餐食计划。';

  @override
  String unableToSavePreferences(String error) {
    return '无法保存偏好：$error';
  }

  @override
  String get unableToLoadProfileShort => '无法加载您的资料。';

  @override
  String get saveAndRefreshMealPlan => '保存并刷新餐食计划';

  @override
  String get accountCreatedSuccessfully => '账户创建成功';

  @override
  String get emailVerificationSent => '验证邮件已发送——请查收邮箱确认。';

  @override
  String get passwordUpdated => '密码已更新';

  @override
  String unableToUpdateAccessibilityMode(String error) {
    return '无法更新无障碍模式：$error';
  }

  @override
  String unableToUpdateSleepMode(String error) {
    return '无法更新睡眠模式：$error';
  }

  @override
  String get modeSwitcher => '模式切换器';

  @override
  String get minimalTabs => '极简标签';

  @override
  String get minimalTabsDescription => '顶部细标签，活动项带下划线。';

  @override
  String get classicPill => '经典胶囊';

  @override
  String get classicPillDescription => '原始圆角分段控件。';

  @override
  String unableToUpdateModeSwitcher(String error) {
    return '无法更新模式切换器：$error';
  }

  @override
  String get select => '选择';

  @override
  String get changeEmail => '更改邮箱';

  @override
  String get newEmail => '新邮箱';

  @override
  String get currentPassword => '当前密码';

  @override
  String get enterPassword => '输入您的密码';

  @override
  String get update => '更新';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get passwordMinCharacters => '至少 6 个字符';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get sleepGreetingMorning => '早上好';

  @override
  String get sleepGreetingAfternoon => '下午好';

  @override
  String get sleepGreetingEvening => '晚上好';

  @override
  String get athlete => '运动员';

  @override
  String get logSleep => '记录睡眠';

  @override
  String get sleepSchedule => '睡眠计划';

  @override
  String unableToSaveSleepSchedule(String error) {
    return '无法保存睡眠计划：$error';
  }

  @override
  String get sleepProfileUnavailableBody => '规划睡眠前需要您的资料。';

  @override
  String get wakeTimePlanning => '起床时间规划';

  @override
  String get setSleepSchedule => '设置睡眠计划';

  @override
  String get wakeTimePlanningDescription => '我们使用您的常用就寝和起床时间来保护训练和比赛日前的恢复。';

  @override
  String get setSleepScheduleDescription => '添加常用就寝和起床时间，以便睡眠模式规划恢复并跟踪睡眠统计。';

  @override
  String get bedtime => '就寝时间';

  @override
  String get wakeTime => '起床时间';

  @override
  String get add => '添加';

  @override
  String get saveSleepSchedule => '保存睡眠计划';

  @override
  String get targetSleep => '目标睡眠';

  @override
  String get tonightBedtime => '今晚就寝时间';

  @override
  String earlierWakeSuggested(String event, String time) {
    return '建议在 $time 的 $event 之前更早起床。';
  }

  @override
  String get customBedtimeLimit => '最多可添加 3 个自定义就寝项目。';

  @override
  String unableToSaveBedtimeItems(String error) {
    return '无法保存就寝项目：$error';
  }

  @override
  String get enterValidTime => '请输入有效时间，如 10:30 PM 或 22:30。';

  @override
  String get addCustomBedtime => '添加自定义就寝时间';

  @override
  String get editCustomBedtime => '编辑自定义就寝时间';

  @override
  String get bedtimeHint => '10:30 PM 或 22:30';

  @override
  String get pickTime => '选择时间';

  @override
  String get save => '保存';

  @override
  String sleepLoggedForDay(String duration, String day, String advice) {
    return '已为 $day 保存 $duration。$advice';
  }

  @override
  String sleepAppliedForDays(String duration, int count, String advice) {
    return '已将 $duration 应用于 $count 天。$advice';
  }

  @override
  String unableToLoadSleepSchedule(String error) {
    return '无法加载睡眠计划：\n$error';
  }

  @override
  String get sleepScheduleUnavailable => '睡眠计划不可用';

  @override
  String get sleepScheduleDescription => '选择日期，输入小时和分钟，然后保存单日或将相同睡眠时长应用于接下来一周。';

  @override
  String get hours => '小时';

  @override
  String get minutes => '分钟';

  @override
  String selectedDuration(String duration) {
    return '所选时长：$duration';
  }

  @override
  String targetDuration(String duration) {
    return '目标 $duration';
  }

  @override
  String get presetBedtimes => '预设就寝时间';

  @override
  String customBedtimeItems(int count, int max) {
    return '自定义就寝项目（$count/$max）';
  }

  @override
  String get noCustomBedtimeItems => '尚无自定义就寝项目。最多添加 3 个。';

  @override
  String get editTime => '编辑时间';

  @override
  String get delete => '删除';

  @override
  String bedtimeItemsDescription(String time) {
    return '就寝项目使用起床时间 $time 来计算睡眠时长。';
  }

  @override
  String get saveDay => '保存当天';

  @override
  String get applyNextSevenDays => '应用于未来7天';

  @override
  String get automaticTrackingStatus => '自动跟踪状态';

  @override
  String get automaticTrackingDescription =>
      '由于后台限制，仅依靠时钟的自动跟踪在 iOS/Android 上并不可靠。请使用此计划工具手动安排，健康同步可作为未来的自动选项。';

  @override
  String get today => '今天';

  @override
  String get mondayShort => '周一';

  @override
  String get tuesdayShort => '周二';

  @override
  String get wednesdayShort => '周三';

  @override
  String get thursdayShort => '周四';

  @override
  String get fridayShort => '周五';

  @override
  String get saturdayShort => '周六';

  @override
  String get sundayShort => '周日';

  @override
  String get sleepDurationInvalid => '请输入有效的小时和分钟（分钟为 0–59）。';

  @override
  String get sleepDurationRange => '睡眠时长应在 2 到 16 小时之间。';

  @override
  String sleepTotal(String duration) {
    return '总计：$duration';
  }

  @override
  String sleepTargetHours(String hours) {
    return '目标：$hours 小时';
  }

  @override
  String get skipForNow => '暂时跳过';

  @override
  String get saveSleep => '保存睡眠';

  @override
  String get sleepCheckInDescription => '您睡了多久？输入小时和分钟，或暂时跳过。';

  @override
  String sleepLogged(String duration, String advice) {
    return '已记录 $duration。$advice';
  }

  @override
  String unableToSaveSleepLog(String error) {
    return '无法保存睡眠记录：$error';
  }

  @override
  String get recoveryAhead => '恢复领先';

  @override
  String sleepAboveTarget(String slept, String target) {
    return '您睡了 $slept，高于 $target 小时目标。';
  }

  @override
  String sleepConsistencyAdvice(String bedtime, String wakeTime) {
    return '保持就寝时间接近 $bedtime，并在 $wakeTime 左右起床以保持一致。';
  }

  @override
  String get onTarget => '达标';

  @override
  String sleepMatchesTarget(String slept, String target) {
    return '您睡了 $slept，达到 $target 小时目标。';
  }

  @override
  String sleepRhythmAdvice(String bedtime, String wakeTime) {
    return '保持节奏：就寝约 $bedtime，起床约 $wakeTime。';
  }

  @override
  String get sleepNeedsBoost => '睡眠需要加强';

  @override
  String sleepBelowTarget(String deficit, String target) {
    return '您比 $target 小时目标少约 $deficit 小时。';
  }

  @override
  String sleepRecoveryAdvice(
    String bedtime,
    String wakeTime,
    String eventNote,
  ) {
    return '今晚，尽量在 $bedtime 左右就寝，以便在 $wakeTime 起床并获得更好恢复。$eventNote';
  }

  @override
  String earlierWakeRecommendation(String event, String time) {
    return '建议在 $time 的 $event 之前更早起床。';
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
  String get authMealPreferencesHint => '注册后告诉我们您喜欢什么以及需要避免什么。';

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
  String get authLegalAgreement => '我同意隐私政策和服务条款';

  @override
  String get authPrivacyPolicy => '隐私政策';

  @override
  String get authTermsAndConditions => '服务条款';

  @override
  String get authValidationLegalRequired => '创建账户前请先同意隐私政策和服务条款';

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
  String get deleteAccountReauthTitle => '确认密码';

  @override
  String get deleteAccountReauthBody => '为保障账户安全，请输入密码以永久删除此账户。';

  @override
  String get deleteAccountReauthPassword => '密码';

  @override
  String get authErrorRequiresRecentLogin => '为保障安全，请确认密码后重试。';

  @override
  String failedToInitializeApp(String error) {
    return '无法初始化应用：\n$error';
  }

  @override
  String failedToLoadAccount(String error) {
    return '无法加载账户：\n$error';
  }

  @override
  String get continueButton => '继续';

  @override
  String get tryAgain => '重试';

  @override
  String get finishSetup => '完成设置';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get maybe => '也许';

  @override
  String get required => '必填';

  @override
  String get enterPositiveNumber => '请输入正数';

  @override
  String get navHome => '首页';

  @override
  String get navMeals => '餐食';

  @override
  String get navSchedule => '日程';

  @override
  String get navProfile => '个人资料';

  @override
  String get navSleep => '睡眠';

  @override
  String get navLog => '记录';

  @override
  String get modeMealTracking => '餐食追踪';

  @override
  String get modeSleep => '睡眠';

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get sportTennis => '网球';

  @override
  String get sportBasketball => '篮球';

  @override
  String get sportSoccer => '足球';

  @override
  String get sportAmericanFootball => '美式橄榄球';

  @override
  String get sportBaseball => '棒球';

  @override
  String get sportSoftball => '垒球';

  @override
  String get sportVolleyball => '排球';

  @override
  String get sportSwimming => '游泳';

  @override
  String get sportTrackAndField => '田径';

  @override
  String get sportCrossCountry => '越野跑';

  @override
  String get sportWrestling => '摔跤';

  @override
  String get sportLacrosse => '长曲棍球';

  @override
  String get sportHockey => '曲棍球';

  @override
  String get sportGolf => '高尔夫';

  @override
  String get sportGymnastics => '体操';

  @override
  String get sportCycling => '自行车';

  @override
  String get sportOther => '其他';

  @override
  String get sportNone => '无';

  @override
  String get onboardingWelcomeTitle => 'NutriLens';

  @override
  String get onboardingWelcomeSubtitle => '聪明补给。更强训练。';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String get onboardingYourName => '你的姓名';

  @override
  String get onboardingFullNameLabel => '全名';

  @override
  String get onboardingAboutSport => '关于你的运动';

  @override
  String get onboardingPlaySportQuestion => '你目前参加运动吗？';

  @override
  String get onboardingPlaySportYes => '是，我参加运动';

  @override
  String get onboardingPlaySportNo => '不，目前没有';

  @override
  String get onboardingYourSportLabel => '你的运动';

  @override
  String get onboardingEnterSport => '请输入你的运动';

  @override
  String get onboardingNoSportTargets => '没问题——我们会根据你的身体指标估算营养目标。';

  @override
  String get onboardingChooseOption => '请选择上方选项以继续。';

  @override
  String get onboardingYourSchool => '你的学校';

  @override
  String get onboardingSchoolNameLabel => '学校名称（可选）';

  @override
  String get onboardingGraduationYearLabel => '毕业年份（可选）';

  @override
  String get onboardingEnterFourDigitYear => '请输入四位年份';

  @override
  String get onboardingSleepCheck => '睡眠检查';

  @override
  String get onboardingSleepCheckIntro => '三个快速问题。点击选项以选择；再次点击即可取消选择。';

  @override
  String get sleepQuestionWakeTired => '你醒来时会感到疲惫吗？';

  @override
  String get sleepQuestionWakeTiredHint => '想想典型的上学周。';

  @override
  String get sleepQuestionBedtimeChanges => '你的就寝时间变化很大吗？';

  @override
  String get sleepQuestionBedtimeChangesHint => '比赛、训练或作业可能会让你晚睡。';

  @override
  String get sleepQuestionReminder => '睡前提醒会有帮助吗？';

  @override
  String get sleepQuestionReminderHint => '在目标睡眠时间前给你一个温和提醒。';

  @override
  String get sleepAnswerNotOften => '不常';

  @override
  String get sleepAnswerSometimes => '有时';

  @override
  String get sleepAnswerOften => '经常';

  @override
  String get onboardingUseSleepMode => '使用睡眠模式';

  @override
  String get onboardingSleepRecommended => '我们建议使用睡眠模式';

  @override
  String get onboardingSleepOptional => '睡眠模式为可选项';

  @override
  String get onboardingSleepRecommendation => '根据你的回答，睡眠模式可以帮助你恢复。';

  @override
  String get onboardingSleepOptionalBody => '如果你的日程改变，可以稍后在设置中开启。';

  @override
  String get onboardingBodyMetrics => '你的身体指标';

  @override
  String get onboardingBodyMetricsHint => '我们使用身高和体重来估算你的每日营养目标。';

  @override
  String get onboardingHeightLabel => '身高（CM）';

  @override
  String get onboardingWeightLabel => '体重（KG）';

  @override
  String onboardingMaximumHeight(int height) {
    return '最大身高为 $height 厘米';
  }

  @override
  String onboardingMaximumWeight(int weight) {
    return '最大体重为 $weight 千克';
  }

  @override
  String get onboardingNutritionTargets => '每日营养目标';

  @override
  String get onboardingTargetsFromSport => '我们根据你的运动、身高和体重进行了估算。你可以调整。';

  @override
  String get onboardingTargetsFromMetrics => '我们根据你的身高和体重进行了估算。你可以调整。';

  @override
  String get homeTodayMealPlan => '今日餐食计划';

  @override
  String get homeNoMealsPlanned => '今天尚未安排餐食。';

  @override
  String get homeMealPlanUnavailable => '餐食计划暂时不可用。';

  @override
  String get homeMealPlanRefreshed => '已根据你的偏好更新餐食计划';

  @override
  String homeUnableToSaveHydration(String error) {
    return '无法保存饮水量：$error';
  }

  @override
  String homeFailedToLoadData(String error) {
    return '无法加载首页数据：\n$error';
  }

  @override
  String get homeThisWeeksFuel => '本周补给';

  @override
  String get homeTodayFuel => '今日补给';

  @override
  String get homeHydration => '饮水量';

  @override
  String get homeProgramTitle => '你的计划';

  @override
  String get homeProgramSubtitle => '保持规律，为训练补足能量。';

  @override
  String get homeWeeklySleep => '每周睡眠';

  @override
  String get homeLogged => '已记录';

  @override
  String homeTargetHours(String hours) {
    return '目标 $hours 小时';
  }

  @override
  String get scheduleTitle => '日程';

  @override
  String get scheduleTimeline => '时间线';

  @override
  String get scheduleMeals => '餐食';

  @override
  String get scheduleEvents => '活动';

  @override
  String get scheduleSleep => '睡眠';

  @override
  String get scheduleLogSleep => '记录睡眠';

  @override
  String get scheduleLogSleepForDay => '记录当天睡眠';

  @override
  String scheduleNewMealReady(String meal) {
    return '新的$meal餐已准备好';
  }

  @override
  String scheduleMealGenerationFailed(String error) {
    return '无法生成新餐食：$error';
  }

  @override
  String get scheduleDeleteEventTitle => '删除活动？';

  @override
  String scheduleDeleteEventBody(String title) {
    return '要从日程中删除“$title”吗？';
  }

  @override
  String get scheduleDeleteEventFailed => '无法删除活动。';

  @override
  String get scheduleEventDeleted => '活动已删除。';

  @override
  String get scheduleNoItems => '当天没有安排。';

  @override
  String get scheduleCreateEvent => '创建活动';

  @override
  String get scheduleEventCreated => '活动已创建';

  @override
  String get scheduleEventType => '活动类型';

  @override
  String get scheduleEventTitle => '标题';

  @override
  String get scheduleDate => '日期';

  @override
  String get scheduleTime => '时间';

  @override
  String get scheduleSubtitle => '副标题';

  @override
  String get scheduleLocation => '地点';

  @override
  String get scheduleBadge => '徽章';

  @override
  String get scheduleFuelingHints => '补给提示';

  @override
  String get scheduleTiming => '时机';

  @override
  String get scheduleHint => '提示';

  @override
  String get scheduleFilterAll => '全部';

  @override
  String get scheduleFilterMeals => '餐食';

  @override
  String get scheduleFilterEvents => '活动';

  @override
  String get scheduleFilterSleep => '睡眠';

  @override
  String get scheduleEventPractice => '训练';

  @override
  String get scheduleEventGame => '比赛';

  @override
  String get scheduleEventWorkout => '锻炼';

  @override
  String get scheduleEventOther => '其他';

  @override
  String get scheduleEventMeal => '餐食';

  @override
  String get scheduleEventTraining => '训练';

  @override
  String get scheduleEventMatch => '比赛';

  @override
  String get mealsTitle => '餐食';

  @override
  String get mealsLogMeal => '记录餐食';

  @override
  String get mealsMealLogged => '餐食记录成功';

  @override
  String get mealsMealName => '餐食名称';

  @override
  String get mealsCalories => '卡路里 kcal';

  @override
  String get mealsProtein => '蛋白质';

  @override
  String get mealsCarbs => '碳水化合物';

  @override
  String get mealsFats => '脂肪';

  @override
  String get mealsSaveMeal => '保存餐食';

  @override
  String get mealsFavorites => '收藏';

  @override
  String mealsFavoriteLogged(String title) {
    return '已记录$title';
  }

  @override
  String get mealsRecipeDetails => '食谱详情';

  @override
  String get mealsIngredients => '食材';

  @override
  String get mealsInstructions => '做法';

  @override
  String mealsMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String mealsServings(int count) {
    return '$count 份';
  }

  @override
  String get sleepDashboardTitle => '睡眠日程';

  @override
  String get sleepProfileUnavailable => '个人资料不可用';

  @override
  String get sleepBedtime => '就寝时间';

  @override
  String get sleepWakeTime => '起床时间';

  @override
  String get sleepSaveSchedule => '保存睡眠日程';

  @override
  String sleepUnableToSaveSchedule(String error) {
    return '无法保存睡眠日程：$error';
  }

  @override
  String get sleepTargetSleep => '目标睡眠';

  @override
  String get sleepTonightBedtime => '今晚就寝时间';

  @override
  String get sleepRecoveryAhead => '恢复在前方';

  @override
  String get sleepOnTarget => '达到目标';

  @override
  String sleepUnableToSaveLog(String error) {
    return '无法保存睡眠记录：$error';
  }

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileSignOutTitle => '退出登录？';

  @override
  String get profileSignOutBody => '确定要退出登录吗？';

  @override
  String get profileDeleteAccountTitle => '删除账户？';

  @override
  String get profileDeleteGuestBody =>
      '这将永久删除你的访客账户，以及此设备上所有记录的餐食、睡眠和个人资料数据。此操作无法撤销。';

  @override
  String profileDeleteAccountBody(String email) {
    return '这将永久删除$email及所有相关数据。此操作无法撤销。';
  }

  @override
  String get profileAccountCreated => '账户创建成功';

  @override
  String get profileVerificationSent => '验证邮件已发送——请检查收件箱并确认。';

  @override
  String get profilePasswordUpdated => '密码已更新';

  @override
  String get profileCreateAccount => '创建账户';

  @override
  String get profileLinkEmail => '关联电子邮件';

  @override
  String get profileGuestNotice => '创建账户以备份数据，并在所有设备上使用。';

  @override
  String get profileSaveRefreshMealPlan => '保存并刷新餐食计划';

  @override
  String profileUnableToUpdateAccessibility(String error) {
    return '无法更新无障碍模式：$error';
  }

  @override
  String profileUnableToUpdateSleepMode(String error) {
    return '无法更新睡眠模式：$error';
  }

  @override
  String get profileModeSwitcher => '模式切换器';

  @override
  String get profileMinimalTabs => '简洁标签页';

  @override
  String get profileMinimalTabsDescription => '带有活动下划线的精简顶部标签页。';

  @override
  String get profileClassicPill => '经典胶囊';

  @override
  String get profileClassicPillDescription => '原始圆角分段控件。';

  @override
  String profileUnableToUpdateModeSwitcher(String error) {
    return '无法更新模式切换器：$error';
  }

  @override
  String get scheduleMealPlan => '餐食计划';

  @override
  String get scheduleNoMealsPlanned => '此日无计划餐食。';

  @override
  String get scheduleMealPlanUnavailable => '餐食计划目前不可用。';

  @override
  String get scheduleGenerating => '生成中...';

  @override
  String get scheduleNewMeal => '新餐食';

  @override
  String get scheduleSleepLogged => '已记录睡眠';

  @override
  String get scheduleThisWeek => '本周';

  @override
  String get scheduleFullMonth => '整月';

  @override
  String get scheduleTodaysMatch => '今日比赛';

  @override
  String get scheduleAddTitle => '添加标题';

  @override
  String get scheduleAddSubtitle => '添加副标题';

  @override
  String get scheduleAddLocation => '添加地点';

  @override
  String get scheduleAddBadge => '添加徽章';

  @override
  String get scheduleAddHints => '添加提示';

  @override
  String scheduleHintCount(int count) {
    return '$count 条提示';
  }

  @override
  String get scheduleTimingHint => '提前 2 小时';

  @override
  String get scheduleHydrate => '补水';

  @override
  String get scheduleRemoveHint => '移除提示';

  @override
  String get scheduleLoadFailed => '无法加载日程。';

  @override
  String get scheduleLogSleepEmpty => '此日无睡眠记录。';

  @override
  String get scheduleNoEvents => '此日无安排赛事。';

  @override
  String get scheduleNoMeals => '此日无已记录餐食。';

  @override
  String get scheduleNoEntries => '此日无赛事、餐食或睡眠记录。';

  @override
  String get mealSearchTitle => '查找菜品';

  @override
  String get mealSearchDescription => '搜索食谱并在应用内查看配料和步骤。';

  @override
  String get mealSearchHint => '搜索鸡肉、意面、沙拉...';

  @override
  String mealSearchResultsFor(String query) {
    return '“$query”的搜索结果';
  }

  @override
  String get mealPopularDishes => '热门菜品';

  @override
  String get mealUnableToLoadDishes => '无法加载菜品';

  @override
  String get mealNoDishesFound => '未找到菜品，请尝试其他搜索。';

  @override
  String get mealEnterDishName => '输入菜名并在键盘上点击搜索。';

  @override
  String mealUnableToLog(String error) {
    return '无法记录餐食：$error';
  }

  @override
  String get mealEnterValidNumber => '请输入有效数字';

  @override
  String get mealLogFavorite => '记录收藏';

  @override
  String mealUnableToLogFavorite(String error) {
    return '无法记录收藏：$error';
  }

  @override
  String get mealEditBeforeLogging => '记录前编辑';

  @override
  String get mealSavedToProfile => '已保存到资料';

  @override
  String mealServingCount(int count) {
    return '$count 份';
  }

  @override
  String get mealProtein => '蛋白质';

  @override
  String get mealCarbs => '碳水化合物';

  @override
  String get mealFats => '脂肪';

  @override
  String get mealUnableToLoadRecipeDetails => '无法加载食谱详情';

  @override
  String get mealFavoriteBerryYogurtBowl => '浆果酸奶碗';

  @override
  String get mealFavoriteSalmonBowl => '三文鱼碗';

  @override
  String get mealFavoriteChickenBowl => '鸡肉碗';

  @override
  String get homeHydrationReminder => '补水提醒';

  @override
  String get homeHydrationGoalReached => '做得好——目标已达成！';

  @override
  String homeHydrationDrinkMore(String liters) {
    return '今天再喝 $liters 升';
  }

  @override
  String homeHydrationLoggedOf(String current, String target) {
    return '已记录 $current 升 / $target 升';
  }

  @override
  String get homeMealCapture => '餐食记录';

  @override
  String get homeReadyToLog => '准备记录了吗？';

  @override
  String get homeMealCaptureOptions => '手动、偏好或收藏';

  @override
  String get homePrefsShort => '偏好';

  @override
  String get homePersonalNutritionProgram => '个人营养计划';

  @override
  String homeSchoolSportProgram(String school, String sport) {
    return '$school $sport 计划';
  }

  @override
  String homeSportNutritionProgram(String sport) {
    return '$sport 营养计划';
  }

  @override
  String get homeNoSleepLoggedWeek => '本周尚无睡眠记录。';

  @override
  String homeSleepWeekAvg(String avg, int logged) {
    return '平均 $avg • 已记录 $logged/7 天';
  }

  @override
  String homeFailedLoadWeeklyFuel(String error) {
    return '无法加载本周营养数据：\n$error';
  }

  @override
  String get homeNoMealsLoggedWeek => '本周尚无餐食记录。';

  @override
  String homeDaysLoggedCount(int logged) {
    return '已记录 $logged/7 天';
  }

  @override
  String get homeTotal => '总计';

  @override
  String get homeWeeklyTarget => '每周目标';

  @override
  String get homeDailyAverage => '日均';

  @override
  String get homeDailyCalories => '每日卡路里';

  @override
  String get homeDailyBreakdown => '每日明细';

  @override
  String homeTodayDateLabel(String date) {
    return '今天 • $date';
  }

  @override
  String get homeNoMealsLogged => '无餐食记录';

  @override
  String homeCaloriesProgress(String current, String target) {
    return '$current / $target 千卡';
  }

  @override
  String homeMacroSummary(String protein, String carbs, String fats) {
    return '蛋白质 $protein 克 • 碳水 $carbs 克 • 脂肪 $fats 克';
  }

  @override
  String homeMealKcalProtein(String kcal, String protein) {
    return '$kcal 千卡 · 蛋白质 $protein 克';
  }

  @override
  String get homeNextSession => '下一场训练';

  @override
  String get homeManualLog => '手动';

  @override
  String homeCaloriesOfTarget(String target) {
    return '/ $target 千卡';
  }

  @override
  String get scanMealSaved => '餐食已保存到记录';

  @override
  String scanUnableAnalyze(String error) {
    return '无法分析餐食照片：$error';
  }

  @override
  String scanUnablePickImage(String error) {
    return '无法选择图片：$error';
  }

  @override
  String get scanTakePhoto => '拍照';

  @override
  String get scanTakePhotoSubtitle => '使用相机扫描餐食';

  @override
  String get scanPhotoLibrary => '照片库';

  @override
  String get scanPhotoLibrarySubtitle => '选择已有图片';

  @override
  String get scanMeal => '扫描餐食';

  @override
  String get scanPointAtFood => '对准您的食物';

  @override
  String get scanTapToCapture => '点击拍照或从图库选择';

  @override
  String get scanAnalyzing => '正在分析餐食...';

  @override
  String get scanPhoto => '照片';

  @override
  String get scanManual => '手动';

  @override
  String get scanPrevious => '历史';

  @override
  String get scanMealAdded => '餐食已添加到记录';

  @override
  String get scanMealAnalysis => '餐食分析';

  @override
  String get scanMealAnalysisSubtitle => '保存到记录前请查看 AI 估算结果。';

  @override
  String get scanPreviousMeals => '历史餐食';

  @override
  String scanPreviousMealsSubtitle(int count) {
    return '点击餐食再次记录。最多显示 $count 条最近记录。';
  }

  @override
  String get scanNoMealsLogged => '尚无餐食记录。';

  @override
  String scanMealListSubtitle(String kcal, String protein) {
    return '$kcal 千卡 · 蛋白质 $protein 克';
  }

  @override
  String get onboardingSleepReasonWakeTired => '您经常醒来感到疲惫。';

  @override
  String get onboardingSleepReasonBedtimeChanges => '您的就寝时间变化很大。';

  @override
  String get onboardingSleepReasonReminder => '提醒可能有助于您放松入睡。';

  @override
  String get onboardingSleepReasonSteadierRoutine => '睡眠模式可帮助您建立更稳定的作息。';

  @override
  String get profileEditPhoto => '编辑照片';

  @override
  String get mealTypeBreakfast => '早餐';

  @override
  String get mealTypeLunch => '午餐';

  @override
  String get mealTypeDinner => '晚餐';

  @override
  String get mealTypeSnack => '加餐';
}
