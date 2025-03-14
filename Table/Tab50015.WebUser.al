table 50015 "Web User"
{
    DataPerCompany = false;

    fields
    {
        field(1; "User ID"; Code[20])
        {
        }
        field(2; Password; Text[50])
        {
        }
        field(3; "User Name"; Text[100])
        {
        }
        field(4; "Active Yes/No"; Boolean)
        {
        }
        field(5; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(6; "Sales to Customer No."; Code[20])
        {
            Caption = 'Sales To Customer No.';
            DataClassification = ToBeClassified;
            TableRelation = Customer;
            //CaptionML=[ENU=Sales-to Customer No.];
        }

        field(7; "Sell To customer Name"; Text[100])
        {
            Caption = 'Sell To customer Name';
            DataClassification = ToBeClassified;
        }

        field(8; "EMail"; Text[100])
        {
            Caption = 'EMail';
            DataClassification = ToBeClassified;
        }



    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        UserRec: Record 2000000120;
}