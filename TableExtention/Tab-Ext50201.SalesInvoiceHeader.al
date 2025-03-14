tableextension 50201 SalesInvoiceHeaderExt extends "Sales Invoice Header"
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

// tableextension 50100 "Custom Sales Header Ext" extends "Sales Header"
// {
//     fields
//     {
//         field(50000; "Custom Field"; Text[50])
//         {
//             DataClassification = ToBeClassified;
//         }
//     }
// }


// tableextension 50101 "Custom Sales Line Ext" extends "Sales Line"
// {
//     fields
//     {
//         field(50000; "Custom Field"; Text[50])
//         {
//             DataClassification = ToBeClassified;
//         }
//     }
// }
