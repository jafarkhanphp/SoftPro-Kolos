tableextension 50206 SalesCreditMemoHeaderExt extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50011; IRN; Code[100])
        {
            Caption = 'IRN';
            DataClassification = ToBeClassified;
        }
        field(50012; EInvoiceStatus; Option)
        {
            Caption = 'E-Invoice Status';
            OptionMembers = Pending,Accepted,Error,Cancel;
            DataClassification = ToBeClassified;
            Editable = true;
        }
        field(50013; ErrorText; Text[1024])
        {
            Caption = 'Error Text';
            DataClassification = ToBeClassified;
        }

    }
}

