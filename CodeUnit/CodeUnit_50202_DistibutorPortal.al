codeunit 50202 "DistibutorPortal"
{

    var
    //StoreEmailRec: Record "Store Email";

    trigger OnRun()
    var

    begin

    end;

    PROCEDURE AddNum(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        N1: Code[50];
        N2: Code[20];
        OPT: Code[50];// 'Distributor,ASM/RSM'

        N1INT: Decimal;
        N2INT: Decimal;
        TotalINT: Decimal;

        //Function Out
        //Total: Code[50];

        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get UserID
        if input.Get('Num1', c) then begin
            N1 := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Num1 Node not found in Payload');
            exit(Myresult);
        end;
        //Get PWS
        if input.Get('Num2', c) then begin
            N2 := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Num2 Node not found in Payload');
            exit(Myresult);
        end;
        //Get PWS
        if input.Get('OPT', c) then begin
            OPT := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'OPT Node not found in Payload');
            exit(Myresult);
        end;

        Evaluate(N1INT, N1);
        Evaluate(N2INT, N2);

        If OPT = '+' then begin
            TotalINT := N1INT + N2INT;
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('Result', TotalINT);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        end ELSE if OPT = '-' then begin
            TotalINT := N1INT - N2INT;
            Orderjson.Add('id', '1');
            Orderjson.Add('Success', 'True');
            Orderjson.Add('Result', TotalINT);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'Invalid Operator');
            exit(Myresult);
        end;


    END;


    PROCEDURE ValidateWebUser(inputJson: Text[2024]): Text[1024]
    var
        //Function In
        UserID: Code[50];
        PWS: Code[20];
        LoginType: Text[100];// 'Distributor,ASM/RSM'

        //Function Out
        ErrText: Text[250];
        UserName: Text[250];
        CustomerCode: Code[20];
        Flg: Boolean;

        WebUserRec: Record "Web User";


        input: JsonObject;
        c: JsonToken;
        Myresult: Text[1024];
        Orderjson: JsonObject;

    BEGIN

        input.ReadFrom(inputJson);
        //Get UserID
        if input.Get('UserID', c) then begin
            UserID := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'UserID Node not found in Payload');
            exit(Myresult);
        end;
        //Get PWS
        if input.Get('PWS', c) then begin
            PWS := c.AsValue().AsText();
        end else begin
            Myresult := CreateJsonPayload('0', 'False', 'PWS Node not found in Payload');
            exit(Myresult);
        end;



        WebUserRec.RESET;
        WebUserRec.SETRANGE("User ID", UserID);
        WebUserRec.SETRANGE(Password, PWS);

        CustomerCode := '';

        IF WebUserRec.FINDFIRST THEN BEGIN
            IF WebUserRec."Active Yes/No" THEN BEGIN
                UserName := WebUserRec."User Name";
                //CustomerCode := WebUserRec."Sell-to Customer No.";
                CustomerCode := WebUserRec."Sales To Customer No.";
                ErrText := '';
                //EXIT(TRUE);
                Orderjson.Add('id', '1');
                Orderjson.Add('Success', 'True');
                Orderjson.Add('Message', '');
                Orderjson.Add('UserName', UserName);
                Orderjson.Add('CustomerCode', CustomerCode);
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END ELSE BEGIN
                UserName := WebUserRec."User Name";
                CustomerCode := WebUserRec."Sales To Customer No.";
                ErrText := 'User Not Active';
                //EXIT(FALSE);
                Orderjson.Add('id', '0');
                Orderjson.Add('Success', 'False');
                Orderjson.Add('Message', ErrText);
                Orderjson.Add('UserName', UserName);
                Orderjson.Add('CustomerCode', CustomerCode);
                Orderjson.WriteTo(Myresult);
                exit(Myresult);
            END;
        END ELSE BEGIN
            UserName := '';
            CustomerCode := '';
            ErrText := 'Invalid User ID';
            //EXIT(FALSE);
            Orderjson.Add('id', '0');
            Orderjson.Add('Success', 'False');
            Orderjson.Add('Message', ErrText);
            Orderjson.Add('UserName', UserName);
            Orderjson.Add('CustomerCode', CustomerCode);
            Orderjson.WriteTo(Myresult);
            exit(Myresult);
        END;
    END;
    //************************* CreateJsonPayload ********************************
    procedure CreateJsonPayload(id: Text; Success: Text; Message: Text): Text[1024]
    var
        Orderjson: JsonObject;
        jsontext: Text[1024];
    begin
        Orderjson.Add('id', id);
        Orderjson.Add('Success', Success);
        Orderjson.Add('Message', Message);
        Orderjson.WriteTo(jsontext);
        jsontext := jsontext.Replace('\', '');
        exit(jsontext);
    end;
}
