page 70002 "Item API"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'Items';
    APIVersion = 'v1.0';
    EntityName = 'Item';
    EntitySetName = 'Items';
    SourceTable = Item;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            field(No; Rec."No.")
            {
                Caption = 'Item Number';
            }
            field(Description; Rec.Description)
            {
                Caption = 'Description';
            }
            field(BaseUnitofMeasure; Rec."Base Unit of Measure")
            {
                Caption = 'Base Unit of Measure';
            }
            field(GenProdPostingGroup; Rec."Gen. Prod. Posting Group")
            {
                Caption = 'Inventory Posting Group';
            }

            field(InventoryPostingGroup; Rec."Inventory Posting Group")
            {
                Caption = 'Inventory Posting Group';
            }
            // field(UnitPrice; Rec."Unit Price")
            // {
            //     Caption = 'Unit Price';
            // }
            // field("Unit Cost"; Rec."Unit Cost")
            // {
            //     Caption = 'Unit Cost';
            // }
            field(VATProdPostingGroup; Rec."VAT Prod. Posting Group")
            {
                Caption = 'VAT Product Posting Group';
            }
            // field(Blocked; Rec.Blocked)
            // {
            //     Caption = 'Blocked';
            // }
            field(LastDateModified; Rec."Last Date Modified")
            {
                Caption = 'Last Date Modified';
            }


        }
    }
}