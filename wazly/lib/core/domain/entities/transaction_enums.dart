enum TransactionType {
  debt, // Liability creation (does NOT affect treasury)
  payment, // Settling a debt (affects treasury)
  treasuryIn, // General income (affects treasury)
  treasuryOut, // General expense (affects treasury)
}

enum DebtDirection {
  theyOweMe, // I lent them money (asset)
  iOweThem, // I borrowed money from them (liability)
}
