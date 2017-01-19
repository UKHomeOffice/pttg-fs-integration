package uk.gov.digital.ho.proving.financialstatus.domain

import java.time.LocalDate

import com.fasterxml.jackson.annotation.JsonInclude
import com.fasterxml.jackson.annotation.JsonInclude.Include

case class Account(sortCode: String, accountNumber: String)

case class AccountDailyBalances(accountHolderName: String, balances: Seq[AccountDailyBalance])

case class AccountDailyBalance(date: LocalDate, balance: BigDecimal)

case class UserConsentResult(status: String, description: String)

case class UserConsent(accountId: String, sortCode: String, accountNumber: String, result: UserConsentResult)
