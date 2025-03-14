
pageextension 50205 PostedSalesCreditMemoList extends "Posted Sales Credit Memos"
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
                    Caption = 'Generate IRN Single';
                    Image = GetEntries;

                    trigger OnAction();
                    var
                        CUGenIRN: Codeunit MRAEInvoice;
                        SCHRec: Record "Sales Cr.Memo Header";

                        Ok: Boolean;
                    begin

                        // SCHRec.Reset();
                        // CurrPage.SetSelectionFilter(SCHRec);
                        // Message('Selected Record %1', SCHRec.Count);

                        Ok := Confirm('Are you sure want generate E-Invoice for Sales Credit Memo No. ' + Rec."No.", true, false);
                        if not ok then
                            exit;

                        // SIHRec.Reset();
                        // // SIHRec.SetFilter(SIHRec."No.", 'PSI-0039');
                        // SIHRec.SetFilter(SIHRec."No.",Rec."No.");
                        // if SIHRec.FindFirst() then begin
                        //     // repeat
                        //         // Perform necessary operations on each record
                        //         SIHRec.EInvoiceStatus := Rec.EInvoiceStatus::Pending; // Example update
                        //         SIHRec.Modify(True);
                        //     // until SIHRec.Next() = 0;
                        // end;

                        if (Rec.IRN = '') and (Rec.EInvoiceStatus = Rec.EInvoiceStatus::Pending) then begin
                            CUGenIRN.GenerateIRNSalesCreditSingle(Rec, 'CRN');
                        end else begin
                            Message('IRN already genrated');
                        end;
                    end;
                }
            }
        }
    }
}