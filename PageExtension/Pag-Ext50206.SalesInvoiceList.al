
pageextension 50206 SalesInvoiceListExt extends "Sales Invoice List"
{

    layout
    {
        addafter("Posting Date")
        {
            field(IRN; Rec.IRN)
            {
                ApplicationArea = All;
            }
            field(EInvoiceStatus; Rec.EInvoiceStatus)
            {
                ApplicationArea = All;
                Editable = true;
                //Enabled = true;
            }
            field(ErrorText; Rec.ErrorText)
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        // The "addfirst" construct will add the action as the first action
        // in the Navigation group.
        addfirst(Navigation)
        {
            group("E-Invoice Live")
            {
                action("EInvoice")
                {
                    ApplicationArea = All;
                    Caption = 'Generate IRN';
                    Image = GetEntries;
                    Visible = true;

                    trigger OnAction();
                    var
                        CUGenIRN: Codeunit MRAEInvoice;
                        SIHRec: Record "Sales Invoice Header";
                        Ok: Boolean;
                    begin

                        // SIHRec.Reset();
                        // CurrPage.SetSelectionFilter(SIHRec);
                        // Message('Selected Record %1', SIHRec.Count);

                        Ok := Confirm('Are you sure want generate E-Invoice for Sales Invoice No. %1' + Rec."No.");
                        if not ok then
                            exit;


                        if (Rec.IRN = '') and (Rec.EInvoiceStatus = Rec.EInvoiceStatus::Pending) then begin
                            CUGenIRN.GenerateIRN(Rec, 'PRF');
                        end else begin
                            Message('IRN already genrated');
                        end;
                    end;
                }

            }
        }
    }
}