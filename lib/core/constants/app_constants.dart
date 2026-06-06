/// AppConstants — all non-sensitive configuration constants.
abstract final class AppConstants {
  // ─── Firestore Collection Names ──────────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';

  // ─── Pagination ──────────────────────────────────────────────────────────────
  static const int expensePageSize = 25;

  // ─── Categories ──────────────────────────────────────────────────────────────
  static const List<String> categories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
    'Health',
    'Entertainment',
    'Other',
  ];

  // ─── Currency ────────────────────────────────────────────────────────────────
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';

  // ─── Validation ──────────────────────────────────────────────────────────────
  static const int titleMaxLength = 60;
  static const int noteMaxLength = 200;
  static const double maxExpenseAmount = 9999999.99;

  // ─── Animation Durations ─────────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ─── SharedPreferences Keys ──────────────────────────────────────────────────
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefSelectedCurrency = 'selected_currency';
}

/// AppStrings — all user-facing text in one place (i18n-ready).
abstract final class AppStrings {
  // ─── App ─────────────────────────────────────────────────────────────────────
  static const String appName = 'Xpense';
  static const String appTagline = 'Track every rupee.';

  // ─── Auth ────────────────────────────────────────────────────────────────────
  static const String signIn = 'Sign in';
  static const String signUp = 'Create account';
  static const String signOut = 'Sign out';
  static const String continueWithGoogle = 'Continue with Google';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm password';
  static const String forgotPassword = 'Forgot password?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // ─── Expenses ────────────────────────────────────────────────────────────────
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add expense';
  static const String editExpense = 'Edit expense';
  static const String deleteExpense = 'Delete expense';
  static const String expenseTitle = 'Title';
  static const String expenseAmount = 'Amount';
  static const String expenseCategory = 'Category';
  static const String expenseDate = 'Date';
  static const String expenseNote = 'Note (optional)';
  static const String noExpensesYet = 'No expenses yet';
  static const String noExpensesMessage = 'Tap + to log your first expense.';
  static const String deleteConfirmTitle = 'Delete expense?';
  static const String deleteConfirmBody = 'This action cannot be undone.';

  // ─── Dashboard ───────────────────────────────────────────────────────────────
  static const String dashboard = 'Dashboard';
  static const String totalSpent = 'Total spent';
  static const String thisMonth = 'This month';
  static const String topCategories = 'Top categories';

  // ─── Common actions ──────────────────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String all = 'All';
  static const String retry = 'Try again';

  // ─── Errors ──────────────────────────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection.';
  static const String authError = 'Authentication failed. Please try again.';

  // ─── Validation ──────────────────────────────────────────────────────────────
  static const String required = 'This field is required.';
  static const String invalidEmail = 'Enter a valid email address.';
  static const String passwordTooShort = 'Password must be at least 8 characters.';
  static const String passwordsDoNotMatch = 'Passwords do not match.';
  static const String invalidAmount = 'Enter a valid amount.';
  static const String amountTooLarge = 'Amount is too large.';
}
