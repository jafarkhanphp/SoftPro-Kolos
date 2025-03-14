page 70004 "Sales Order Line API"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'Sales';
    APIVersion = 'v1.0';
    EntityName = 'SalesOrderLine';
    EntitySetName = 'SalesOrderLines';
    SourceTable = "Sales Line";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            field(DocumentType; Rec."Document Type")
            {
                Caption = 'Document Type';
            }
            field(DocumentNo; Rec."Document No.")
            {
                Caption = 'Sales Order Number';
            }

            field(LineNo; Rec."Line No.")
            {
                Caption = 'Line Number';
            }
            field(Type; Rec.Type)
            {
                Caption = 'Type';
            }
            field(No; Rec."No.")
            {
                Caption = 'Item/Resource/GL Account No.';
            }
            field(Description; Rec.Description)
            {
                Caption = 'Description';
            }
            field(Quantity; Rec.Quantity)
            {
                Caption = 'Quantity';
            }
            field(UnitofMeasureCode; Rec."Unit of Measure Code")
            {
                Caption = 'Unit of Measure';
            }
            field(UnitPrice; Rec."Unit Price")
            {
                Caption = 'Unit Price';
            }
            field(LineDiscount; Rec."Line Discount %")
            {
                Caption = 'Line Discount %';
            }
            // field(shortcutDimension1Code; Rec."Shortcut Dimension 1 Code")
            // {
            //     Caption = 'Shortcut Dimension 1 Code';
            // }
            field(LastDateModified; Rec."Last Modified Date")
            {
                Caption = 'Last Date Modified';
            }


        }
    }
}