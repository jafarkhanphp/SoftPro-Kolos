
pageextension 50201 PostedSalesInvoiceList extends "Posted Sales Invoices"
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
                        SIHRec: Record "Sales Invoice Header";
                        Ok: Boolean;
                    begin

                        // SIHRec.Reset();
                        // CurrPage.SetSelectionFilter(SIHRec);
                        // Message('Selected Record %1', SIHRec.Count);

                        Ok := Confirm('Are you sure want generate E-Invoice for Sales Invoice No. %1' + Rec."No.");
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
                            CUGenIRN.GenerateIRNSingle(Rec, 'STD');
                        end else begin
                            Message('IRN already genrated');
                        end;
                    end;
                }
                action("EInvoiceMul")
                {
                    ApplicationArea = All;
                    Caption = 'Generate IRN Multiple';
                    Image = GetEntries;

                    trigger OnAction();
                    var
                        CUGenIRN: Codeunit MRAEInvoice;
                        SIHRec: Record "Sales Invoice Header";
                        Ok: Boolean;
                        Cnt: Integer;
                    begin

                        SIHRec.Reset();
                        CurrPage.SetSelectionFilter(SIHRec);
                        SIHRec.SetFilter(IRN, '%1', '');
                        SIHRec.SetRange(EInvoiceStatus, SIHRec.EInvoiceStatus::Pending);
                        Cnt := SIHRec.Count;

                        Message('Selected Record Count Based on Below Filter %1\' + SIHRec.GetFilters(), Cnt);

                        Ok := Confirm('Are you sure want generate E-Invoice for Sales Invoice No. %1' + Rec."No.");
                        if not ok then
                            exit;

                        if (Rec.IRN = '') and (Rec.EInvoiceStatus = Rec.EInvoiceStatus::Pending) then begin
                            CUGenIRN.GenerateIRNMultiple(SIHRec, 'STD');
                        end else begin
                            Message('IRN already genrated');
                        end;

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


                    end;
                }
            }
        }
    }
}