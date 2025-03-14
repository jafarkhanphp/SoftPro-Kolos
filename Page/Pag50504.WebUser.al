page 50504 WebUser
{
    ApplicationArea = All;
    Caption = 'WebUser';
    PageType = List;
    SourceTable = "Web User";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field.', Comment = '%';
                }
                field("User Name"; Rec."User Name")
                {
                    ToolTip = 'Specifies the value of the User Name field.', Comment = '%';
                }
                field(Password; Rec.Password)
                {
                    ToolTip = 'Specifies the value of the Password field.', Comment = '%';
                }
                field("Active Yes/No"; Rec."Active Yes/No")
                {
                    ToolTip = 'Specifies the value of the Active Yes/No field.', Comment = '%';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field(EMail; Rec.EMail)
                {
                    ToolTip = 'Specifies the value of the EMail field.', Comment = '%';
                }
            }
        }
    }
}
