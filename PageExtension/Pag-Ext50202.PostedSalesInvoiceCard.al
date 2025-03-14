pageextension 50202 PostedSalesInvoiceCard extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Posting Date")
        {
            group("E-Invoice Details")
            {
                field(IRN; Rec.IRN)
                {
                    ApplicationArea = All;
                }
                field(EInvoiceStatus; Rec.EInvoiceStatus)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field(ErrorText; Rec.ErrorText)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }
}
    