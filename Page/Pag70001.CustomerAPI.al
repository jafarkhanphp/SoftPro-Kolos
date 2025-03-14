page 70001 "Customer API"
{
    PageType = API;
    APIPublisher = 'MyCompany';
    APIGroup = 'Customers';
    APIVersion = 'v1.0';
    EntityName = 'Customer';
    EntitySetName = 'Customers';
    SourceTable = Customer;
    DelayedInsert = true;
    EntityCaption = 'Customers';
    EntitySetCaption = 'Customers';

    layout
    {
        area(content)
        {
            field(No; Rec."No.")
            {
                Caption = 'Customer Number';
            }
            field(Name; Rec.Name)
            {
                Caption = 'Customer Name';
            }
            field(Address; Rec.Address)
            {
                Caption = 'Address';
            }
            field(City; Rec.City)
            {
                Caption = 'City';
            }
            // field("VAT Registration No."; Rec."VAT Registration No.")
            // {
            //     Caption = 'VAT Registration No.';
            // }
            field(GenBusPostingGroup; Rec."Gen. Bus. Posting Group")
            {
                Caption = 'Gen. Bus. Posting Group';
            }
            field(CustomerPostingGroup; Rec."Customer Posting Group")
            {
                Caption = 'Customer Posting Group';
            }
            field(PaymentTermsCode; Rec."Payment Terms Code")
            {
                Caption = 'Payment Terms Code';
            }

            field(LastDateModified; Rec."Last Date Modified")
            {
                Caption = 'Last Date Modified';
            }


        }
    }
}
