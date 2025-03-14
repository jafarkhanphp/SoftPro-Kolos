tableextension 50202 "Company Info Ext" extends "Company Information"
{
    fields
    {
        field(50100; "TAN"; Code[20])
        {
            Caption = 'TAN';
            DataClassification = ToBeClassified;
        }

        field(50101; "BRN"; Code[20])
        {
            Caption = 'BRN';
            DataClassification = ToBeClassified;
        }
    }
}
