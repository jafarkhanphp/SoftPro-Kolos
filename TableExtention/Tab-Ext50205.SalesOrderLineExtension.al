namespace KolosProject.KolosProject;

using Microsoft.Sales.Document;

tableextension 50205 SalesOrderLineExtension extends "Sales Line"
{
    fields
    {
        field(50206; "Last Modified Date"; Date)
        {
            Caption = 'Last Modified Date';
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
