page 70003 "Sales Order API"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'Sales';
    APIVersion = 'v1.0';
    EntityName = 'SalesOrder';
    EntitySetName = 'SalesOrders';
    SourceTable = "Sales Header";
    DelayedInsert = true;


    layout
    {
        area(content)
        {
            field(DocumentType; Rec."Document Type")
            {
                Caption = 'Document Type';
            }

            field("No"; Rec."No.")
            {
                Caption = 'Sales Order Number';
            }
            field(SelltoCustomerNo; Rec."Sell-to Customer No.")
            {
                Caption = 'Customer Number';
            }
            field(SelltoCustomerName; Rec."Sell-to Customer Name")
            {
                Caption = 'Customer Name';
            }
            field(PostingDate; Rec."Posting Date")
            {
                Caption = 'Posting Date';
            }
            field(DueDate; Rec."Due Date")
            {
                Caption = 'Due Date';
            }
            field(DocumentDate; Rec."Document Date")
            {
                Caption = 'Document Date';
            }
            field(OrderDate; Rec."Order Date")
            {
                Caption = 'Order Date';
            }
            field(ExternalDocumentNo; Rec."External Document No.")
            {
                Caption = 'External Document No.';
            }
            field(CurrencyCode; Rec."Currency Code")
            {
                Caption = 'Currency Code';
            }
            field(LocationCode; Rec."Location Code")
            {
                Caption = 'Location Code';
            }
            field(LastDateModified; Rec."Last Modified Date")
            {
                Caption = 'Last Date Modified';
            }
        }
    }
}