namespace KolosDemo.KolosDemo;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;

page 60003 MraApiSetup
{
    ApplicationArea = All;
    Caption = 'MraApiSetup';
    PageType = List;
    SourceTable = "Mra Api Setup";
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                // field("Entry No "; Rec."Entry No ")
                // {
                //     ToolTip = 'Specifies the value of the Entry No field.', Comment = '%';
                // }
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                }
                field("EBS MRA User Name"; Rec.EbsMraUsername)
                {
                    ToolTip = 'Specifies the value of the EBS MRA User Name field.', Comment = '%';
                }
                field("EBS MRA Id"; Rec.EbsMraId)
                {
                    ToolTip = 'Specifies the value of the EBS MRA Id field.', Comment = '%';
                }
                field("EBS MRA Password"; Rec.EbsMraPasswor)
                {
                    ToolTip = 'Specifies the value of the EBS MRA Password field.', Comment = '%';
                }
                field("URL Token"; Rec.UrlToken)
                {
                    ToolTip = 'Specifies the value of the URL Token field.', Comment = '%';
                }
                field("URL Transmit"; Rec.UrlTransmit)
                {
                    ToolTip = 'Specifies the value of the URL Transmit field.', Comment = '%';
                }
                field("Area Code"; Rec.areaCode)
                {
                    ToolTip = 'Specifies the value of the Area Code field.', Comment = '%';
                }
                field("Third Party URL"; Rec.ThirdPartyUrl)
                {
                    ToolTip = 'Specifies the value of the Third Party URL field.', Comment = '%';
                }
                field(ActiveYN; Rec.ActiveYN)
                {
                    ToolTip = 'Specifies the value of the Active Yes/No field.', Comment = '%';
                }
                field("Remark"; Rec.Remark)
                {
                    ToolTip = 'Specifies the value of the Remark field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(CallAPI)
            {
                Caption = 'Call MRA API';
                ApplicationArea = All;
                trigger OnAction()
                var
                    ok: Boolean;
                    MRAEonvoiceCU: Codeunit MRAEInvoice;
                    SIHRec: Record "Sales Invoice Header";
                begin
                    //Page.Run(50101); // Opens another page
                    ok := Confirm('Do you want to call MRA API?', true, false);
                    if not ok then
                        exit;

                    SIHRec.Reset();
                    SIHRec.SetRange("No.", 'PSI-0016');
                    if SIHRec.FindFirst() then begin
                        SIHRec.FindFirst();
                        //MRAEonvoiceCU.GenerateIRNSingle(SIHRec); // Call the procedure in the codeunit
                        Message('API Called Successfully');
                    end else begin
                        Message('No Record Found');
                    end;


                end;
            }
        }
    }
}
