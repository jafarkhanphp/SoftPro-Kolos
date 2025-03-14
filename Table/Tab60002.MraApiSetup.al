table 60002 "Mra Api Setup"
{
    Caption = 'Mra Api Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No "; Integer)
        {
            Caption = 'Entry No ';
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Code"; Code[50])
        {
            Caption = 'Code';
        }
        field(3; EbsMraId; Code[50])
        {
            Caption = 'EbsMraId';
        }
        field(4; EbsMraUsername; Text[50])
        {
            Caption = 'EBS MRA User Name';
        }
        field(5; EbsMraPasswor; Text[50])
        {
            Caption = 'EBS MRA Password';
        }
        field(6; areaCode; Integer)
        {
            Caption = 'AREA Code ';
        }
        field(7; UrlToken; Text[100])
        {
            Caption = 'URL Token';
        }
        field(8; UrlTransmit; Text[100])
        {
            Caption = 'URL Transmit';
        }
        field(9; "User Id"; Code[50])
        {
            Caption = 'User Id';
            Editable = false;  // User manually edit na kar sake

        }
        field(10; CreatedDate; Date)
        {
            Caption = 'Created Date';
            Editable = false;  // User manually edit na kar sake
        }
        field(11; CreatedTime; Time)
        {
            Caption = 'Created Time';
            Editable = false;  // User manually edit na kar sake
        }
        field(12; ModifyDate; Date)
        {
            Caption = 'Modify Date';
            Editable = false;  // User manually edit na kar sake
        }
        field(13; ModifyTime; Time)
        {
            Caption = 'Modify Time';
            Editable = false;  // User manually edit na kar sake
        }
        field(14; Remark; Text[255])
        {
            Caption = 'Remark';
        }
        field(15; ThirdPartyUrl; Text[100])
        {
            Caption = 'ThirdPartyUrl';
        }
        field(16; ActiveYN; Boolean)
        {
            Caption = 'Active Yes/No';
        }
    }
    keys
    {
        key(PK; "Entry No ")
        {
            Clustered = true;
        }
    }

    trigger
    OnInsert()
    var
        ErrorMessage: Text;
    begin
        ErrorMessage := '';

        if (Code = '') then
            ErrorMessage += 'Code, ';
        if (EbsMraUsername = '') then
            ErrorMessage += 'EbsMraUsername, ';
        if (EbsMraPasswor = '') then
            ErrorMessage += 'EbsMraPassword, ';
        if (areaCode = 0) then
            ErrorMessage += 'areaCode, ';
        if (UrlToken = '') then
            ErrorMessage += 'UrlToken, ';
        if (UrlTransmit = '') then
            ErrorMessage += 'UrlTransmit, ';

        //if ErrorMessage <> '' then
         //   Error('The following fields cannot be blank: %1', CopyStr(ErrorMessage, 1, StrLen(ErrorMessage) - 2));


        CreatedDate := Today;
        CreatedTime := Time;
        "User Id" := USERID;

    end;


    trigger OnModify()
    begin
        ModifyDate := Today;
        ModifyTime := Time;
        "User Id" := USERID;
    end;
}
