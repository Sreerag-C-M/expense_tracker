class GqlQueries {
  static const String getDashboardData = r'''
    query {
      dashboard {
        currentBalance
        thisMonthIncome
        thisMonthExpenses
        upcomingTotal
        projectedBalance
        dailyAverage
        monthEndBalance
        categoryExpenses {
          category
          total
        }
        monthlyTrend {
          month
          val
        }
        topCategories {
          category
          total
        }
      }
    }
  ''';

  static const String getExpenses = r'''
    query {
      expenses {
        id
        amount
        category
        description
        date
        paymentType
        isRecurring
        recurrenceType
      }
    }
  ''';

  static const String addExpense = r'''
    mutation AddExpense($amount: Float!, $category: String, $description: String!, $date: String, $paymentType: String!, $isRecurring: Boolean, $recurrenceType: String) {
      addExpense(amount: $amount, category: $category, description: $description, date: $date, paymentType: $paymentType, isRecurring: $isRecurring, recurrenceType: $recurrenceType) {
        id
      }
    }
  ''';

  static const String updateExpense = r'''
    mutation UpdateExpense($id: ID!, $amount: Float, $category: String, $description: String, $date: String, $paymentType: String, $isRecurring: Boolean, $recurrenceType: String) {
      updateExpense(id: $id, amount: $amount, category: $category, description: $description, date: $date, paymentType: $paymentType, isRecurring: $isRecurring, recurrenceType: $recurrenceType) {
        id
      }
    }
  ''';

  static const String deleteExpense = r'''
    mutation DeleteExpense($id: ID!) {
      deleteExpense(id: $id) {
        id
      }
    }
  ''';

  static const String getCategories = r'''
    query {
      categories {
        id
        name
        type
        isDefault
      }
    }
  ''';

  static const String addCategory = r'''
    mutation AddCategory($name: String!, $type: String, $isDefault: Boolean) {
      addCategory(name: $name, type: $type, isDefault: $isDefault) {
        id
      }
    }
  ''';

  static const String deleteCategory = r'''
    mutation DeleteCategory($id: ID!) {
      deleteCategory(id: $id) {
        id
      }
    }
  ''';

  static const String addIncome = r'''
    mutation AddIncome($amount: Float!, $source: String!, $date: String, $isRecurring: Boolean) {
      addIncome(amount: $amount, source: $source, date: $date, isRecurring: $isRecurring) {
        id
      }
    }
  ''';

  static const String getUpcomingPayments = r'''
    query {
      upcomingPayments {
        id
        title
        amount
        dueDate
        frequency
      }
    }
  ''';

  static const String addUpcomingPayment = r'''
    mutation AddUpcomingPayment($title: String!, $amount: Float!, $dueDate: String!, $frequency: String!) {
      addUpcomingPayment(title: $title, amount: $amount, dueDate: $dueDate, frequency: $frequency) {
        id
      }
    }
  ''';

  static const String deleteUpcomingPayment = r'''
    mutation DeleteUpcomingPayment($id: ID!) {
      deleteUpcomingPayment(id: $id) {
        id
      }
    }
  ''';
  static const String updateIncome = r'''
    mutation UpdateIncome($id: ID!, $amount: Float, $source: String, $date: String, $isRecurring: Boolean) {
      updateIncome(id: $id, amount: $amount, source: $source, date: $date, isRecurring: $isRecurring) {
        id
      }
    }
  ''';

  static const String updateUpcomingPayment = r'''
    mutation UpdateUpcomingPayment($id: ID!, $title: String, $amount: Float, $dueDate: String, $frequency: String) {
      updateUpcomingPayment(id: $id, title: $title, amount: $amount, dueDate: $dueDate, frequency: $frequency) {
        id
      }
    }
  ''';
  static const String getIncomes = r'''
    query {
      incomes {
        id
        amount
        source
        date
        isRecurring
      }
    }
  ''';
  static const String deleteIncome = r'''
    mutation DeleteIncome($id: ID!) {
      deleteIncome(id: $id) {
        id
      }
    }
  ''';
}
