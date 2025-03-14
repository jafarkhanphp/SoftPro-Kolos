page 70005 "Lorry Master List"
{
    PageType = List;
    SourceTable = "Lorry Master";
    ApplicationArea = All;
    UsageCategory = Lists;
    //CardPageId = "Lorry Master Card";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("S No."; Rec."S No.") { }
                field("Account Number"; Rec."Account Number") { }
                field("Customer Name"; Rec."Customer Name") { }
                field("Mandate"; Rec."Mandate") { }
                field("Mandate 1"; Rec."Mandate 1") { }
                field("Mandate 2"; Rec."Mandate 2") { }
                field("Mandate 3"; Rec."Mandate 3") { }
                // Add other mandate fields as needed
            }
        }
    }
}
