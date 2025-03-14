table 60003 EInvoice
{
    Caption = 'E-Invoice';
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
        field(3; "EInvoice Type"; Option)
        {
            Caption = 'E-Invoice Type';
            OptionMembers = " ","Generate E-Invoice","Cancel E-Invoice","Generate E-WayBill on IRN","Cancel E-WayBill on IRN","Einvoice UnPosted SI";
            DataClassification = ToBeClassified;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = ToBeClassified;
        }
        field(6; "Status"; Code[10])
        {
            Caption = 'Status';
            DataClassification = ToBeClassified;
        }
        field(8; "Message Text"; Text[150])
        {
            Caption = 'Message Text';
            DataClassification = ToBeClassified;
        }
        field(10; "IRN"; Text[100])
        {
            Caption = 'IRN';
            DataClassification = ToBeClassified;
        }
        field(11; "AckDt"; DateTime)
        {
            Caption = 'Acknowledgement Date';
            DataClassification = ToBeClassified;
        }
        field(12; "AckNo."; Code[20])
        {
            Caption = 'Acknowledgement No.';
            DataClassification = ToBeClassified;
        }
        field(13; "EwbDt."; DateTime)
        {
            Caption = 'Eway Date';
            DataClassification = ToBeClassified;
        }
        field(14; "EwbNo."; Code[20])
        {
            Caption = 'Eway No.';
            DataClassification = ToBeClassified;
        }
        field(15; "Remarks."; Text[50])
        {
            Caption = 'Eway No.';
            DataClassification = ToBeClassified;
        }
        field(16; "EwbValidTill"; DateTime)
        {
            Caption = 'EwbValid Till';
            DataClassification = ToBeClassified;
        }
        field(17; "SignedQRCode"; Text[1024])
        {
            Caption = 'SignedQRCode';
            DataClassification = ToBeClassified;
        }
        field(18; "SignedInvoice"; Blob)
        {
            Caption = 'SignedInvoice';
            DataClassification = ToBeClassified;
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
        key(key1; "No.")
        { }
    }
    trigger OnInsert()
    var
        EInvoiceRec: Record EInvoice;
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