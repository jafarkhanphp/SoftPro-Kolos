tableextension 50204 SalesHeaderExtension extends "Sales Header"
{
    fields
    {
        field(50205; "Last Modified Date"; Date)
        {
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
