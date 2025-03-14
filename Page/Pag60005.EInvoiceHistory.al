namespace KolosDemo.KolosDemo;
using System.Reflection;

page 60005 "E-Invoice History"
{
    ApplicationArea = All;
    Caption = 'EInvoiceHistory';
    PageType = List;
    SourceTable = EInvoiceHistory;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("EInvoice Type"; Rec."EInvoice Type")
                {
                    ToolTip = 'Specifies the value of the E-Invoice Type field.';
                }
                field(RequestText; RequestText)
                {
                    ToolTip = 'Specifies the value of the Response field.';
                    Caption = 'Request Text';
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = true;
                }
                field(ResponseText; ResponseText)
                {
                    ToolTip = 'Specifies the value of the Response field.';
                    Caption = 'Response Text';
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = true;
                }

                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ToolTip = 'Specifies the value of the Created Date field.';
                }
                field("Created Time"; Rec."Created Time")
                {
                    ToolTip = 'Specifies the value of the Created Time field.';
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field.';
                }
            }
        }
    }
    var
        RequestText: Text;
        ResponseText: Text;

    trigger OnAfterGetRecord()
    begin
        RequestText := GetRequestText();
        ResponseText := GetResponseText();
    end;

    procedure GetRequestText() NewLargeText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Request Text");
        Rec."Request Text".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), Rec.FieldName("Request Text")));
    end;

    procedure GetResponseText() NewLargeText: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Response Text");
        Rec."Response Text".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), Rec.FieldName("Response Text")));
    end;
}

