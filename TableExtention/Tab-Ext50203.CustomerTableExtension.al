tableextension 50203 "Customer Ext" extends Customer
{
    fields
    {
        field(60001; "TAN"; Code[20])
        {
            Caption = 'TAN';
            DataClassification = ToBeClassified;
        }

        field(60002; "BRN"; Code[20])
        {
            Caption = 'BRN';
            DataClassification = ToBeClassified;
        }
    }
}
