tableextension 50204 SalesHeaderExtension extends "Sales Header"
{
    fields
    {
        field(50205; "Last Modified Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
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
    trigger OnAfterModify()
    begin
        "Last Modified Date" := Today();
    end;

    trigger OnAfterInsert()
    begin
        "Last Modified Date" := Today();
    end;

}
