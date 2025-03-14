pageextension 50204 "Customer Page Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
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
