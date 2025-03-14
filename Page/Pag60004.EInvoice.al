namespace KolosDemo.KolosDemo;

page 60004 "E-Invoice"
{
    ApplicationArea = All;
    Caption = 'E-Invoice';
    PageType = List;
    SourceTable = EInvoice;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Created Date"; Rec."Created Date")
                {
                    ToolTip = 'Specifies the value of the Created Date field.', Comment = '%';
                }
                field("Created Time"; Rec."Created Time")
                {
                    ToolTip = 'Specifies the value of the Created Time field.', Comment = '%';
                }
                field("EInvoice Type"; Rec."EInvoice Type")
                {
                    ToolTip = 'Specifies the value of the E-Invoice Type field.', Comment = '%';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field(IRN; Rec.IRN)
                {
                    ToolTip = 'Specifies the value of the IRN field.', Comment = '%';
                }
                field("Message Text"; Rec."Message Text")
                {
                    ToolTip = 'Specifies the value of the Message Text field.', Comment = '%';
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.', Comment = '%';
                }
                field("Remarks."; Rec."Remarks.")
                {
                    ToolTip = 'Specifies the value of the Eway No. field.', Comment = '%';
                }
                field(SignedInvoice; Rec.SignedInvoice)
                {
                    ToolTip = 'Specifies the value of the SignedInvoice field.', Comment = '%';
                }
                field(SignedQRCode; Rec.SignedQRCode)
                {
                    ToolTip = 'Specifies the value of the SignedQRCode field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field.', Comment = '%';
                }
            }
        }
    }
}
