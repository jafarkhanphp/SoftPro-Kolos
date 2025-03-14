table 60004 EInvoiceHistory
{
    Caption = 'E-Invoice History';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(4; "EInvoice Type"; Option)
        {
            Caption = 'E-Invoice Type';
            OptionMembers = " ","Generate E-Invoice","Cancel E-Invoice","Generate Sales Credit Note","Cancel Sales Credit Note";
            DataClassification = ToBeClassified;
            Editable = false;
        }

        field(6; "Request Text"; Blob)
        {
            Caption = 'Request Text';
            DataClassification = ToBeClassified;
        }

        field(8; "Response Text"; Blob)
        {
            Caption = 'Response Text';
            DataClassification = ToBeClassified;
        }
        field(10; "Status"; Boolean)
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
            Editable = false;
        }



        field(20; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; "Created Time"; Time)
        {
            Caption = 'Created Time';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(24; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        EInvoiceRec: Record EInvoiceHistory;
    begin
        if EInvoiceRec.FindLast() then
            "Entry No." := EInvoiceRec."Entry No." + 1
        else
            "Entry No." := 1;

        "Created Date" := Today;
        "Created Time" := Time;
        "User ID" := UserId;

    end;

    trigger OnModify()
    var

    begin
        "User ID" := UserId;
    end;
}