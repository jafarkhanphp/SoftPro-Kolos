pageextension 50203 "Company Info Page Ext" extends "Company Information"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field(TAN; Rec."TAN")
            {
                ApplicationArea = All;
            }

            field(BRN; Rec."BRN")
            {
                ApplicationArea = All;
            }
        }
    }
}
