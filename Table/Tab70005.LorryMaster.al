table 70005 "Lorry Master"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "S No."; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Account Number"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                if Cust.Get("Account Number") then
                    "Customer Name" := Cust.Name;
            end;
        }
        field(3; "Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Mandate"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Mandate 1"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Mandate 2"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Mandate 3"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        // Add other mandate fields as needed
    }
    
    keys
    {
        key(PK; "S No.", "Account Number")
        {
            Clustered = true;
        }
    } 
}