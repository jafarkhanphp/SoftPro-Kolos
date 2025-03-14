namespace KolosProject.KolosProject;

using Microsoft.Sales.Receivables;

page 70008 CustomerLedgerAPI
{
    APIGroup = 'SoftProGroup';
    APIPublisher = 'SoftPro';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'customerLedgerAPI';
    DelayedInsert = true;
    EntityName = 'customerLedgerAPI';
    EntitySetName = 'entitySetName';
    PageType = API;
    SourceTable = "Cust. Ledger Entry";
    Editable = false;
    //IT Solutions
    // some testing again for git hub

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentDate; Rec."Document Date")
                {
                    Caption = 'Document Date';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNo; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(customerNo; Rec."Customer No.")
                {
                    Caption = 'Customer No.';
                }
                field(customerName; Rec."Customer Name")
                {
                    Caption = 'Customer Name';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(amountLCY; Rec."Amount (LCY)")
                {
                    Caption = 'Amount (LCY)';
                }
                field(remainingAmount; Rec."Remaining Amount")
                {
                    Caption = 'Remaining Amount';
                }
                field(remainingAmtLCY; Rec."Remaining Amt. (LCY)")
                {
                    Caption = 'Remaining Amt. (LCY)';
                }
                field(salesLCY; Rec."Sales (LCY)")
                {
                    Caption = 'Sales (LCY)';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due Date';
                    //we can filter data on this field
                }
                field(pmtDiscountDate; Rec."Pmt. Discount Date")
                {
                    Caption = 'Pmt. Discount Date';

                }
                field(pmtDiscToleranceDate; Rec."Pmt. Disc. Tolerance Date")
                {
                    Caption = 'Pmt. Disc. Tolerance Date';
                }
                field(paymentMethodCode; Rec."Payment Method Code")
                {
                    Caption = 'Payment Method Code';
                }
                field(open; Rec.Open)
                {
                    Caption = 'Open';
                }
                field(onHold; Rec."On Hold")
                {
                    Caption = 'On Hold';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field(exportedToPaymentFile; Rec."Exported to Payment File")
                {
                    Caption = 'Exported to Payment File';
                }
                field(messageToRecipient; Rec."Message to Recipient")
                {
                    Caption = 'Message to Recipient';
                }
                field(recipientBankAccount; Rec."Recipient Bank Account")
                {
                    Caption = 'Recipient Bank Account';
                }
                field(debitAmount; Rec."Debit Amount")
                {
                    Caption = 'Debit Amount';
                }
                field(debitAmountLCY; Rec."Debit Amount (LCY)")
                {
                    Caption = 'Debit Amount (LCY)';
                }
                field(creditAmount; Rec."Credit Amount")
                {
                    Caption = 'Credit Amount';
                }
                field(creditAmountLCY; Rec."Credit Amount (LCY)")
                {
                    Caption = 'Credit Amount (LCY)';
                }
            }
        }
    }
}
