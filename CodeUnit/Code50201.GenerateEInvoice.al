codeunit 50201 GenerateEInvoice
{

    SingleInstance = true;
    Permissions = TableData 112 = rimd;
    //EventSubscriberInstance = Manual;
    trigger OnRun();
    begin
        //GenerateIRN(Rec);
    end;

    ///////////////////// Generate IRN ///////////////////////
    procedure GenerateIRN(var SIHRec: Record "Sales Invoice Header")
    var
        //CD: Codeunit "Rest API Codeunit";
        //EInvoiceSetupRec: Record EInvoiceSetup;
        //EInvoiceFindRec: Record EInvoice;
        //EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
    //EInvoiceHistorRec: Record EInvoiceHistory;
    //EInvoiceHistorRecFind: Record EInvoiceHistory;

    begin
        /*
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-Invoice");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;
        */
        JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        //Message('Request\' + JsonPayLoad); MC18022025
        Message('Generated JSON: %1', JsonPayload);
        /*
        //exit; //MC101024 //261224
        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckDt', AckDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckNo', AckNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);

        /*
        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-Invoice";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);


        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;
            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-Invoice";
            EInvoiceRec.Insert(true);
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Accpted;
            SIHRec."Acknowledgement Date" := AckDtDt;
            SIHRec."Acknowledgement No." := AckNoStr;
            SIHRec.Modify(True);

            Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SIHRec."No.", IrnStr);
        end else begin
            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Error;
            if StrLen(messageStr) > 1024 then begin
                SIHRec.ErrorText := CopyStr(messageStr, 1, 1023);
            end else begin
                SIHRec.ErrorText := messageStr;
            end;
            SIHRec.Modify(True);
            
            Message(responseText);
        end;
        */
    end;


    ///////////////////Local /////////////////////////////// MC18FEB2025
    local procedure CreateJSONForEInvoice(SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        //StateRec: Record State;
        CustRec: Record Customer;
        //DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;
        //MC18FEB2025
        JsonObject: JsonObject;
        Seller, Buyer : JsonObject;
        ItemArray: JsonArray;
        Item: JsonObject;
        JsonText: Text;
        JsonOutput: OutStream;
        JsonInput: InStream;
        TempBlob: Codeunit "Temp Blob";
        DateTimeString: Text;
        PostingDateTime: DateTime;
    //MC18FEB2025
    Begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);
        Clear(TempBlob);
        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if CompRec.get() THEN;


        ////////// Get Sellr Detl////////
        // if CustRec.FindFirst() then;
        // BuyerDtls_Stcd := '';
        // if CustRec.get() THEN;


        //if SIHRec.FindFirst() then begin

        if CustRec.get(SIHRec."Sell-to Customer No.") then;


        // MC18022025
        JsonObject.Add('invoiceCounter', '1');
        JsonObject.Add('transactionType', 'B2C');
        JsonObject.Add('personType', 'VATR');
        JsonObject.Add('invoiceTypeDesc', 'STD');
        JsonObject.Add('currency', 'MUR');
        JsonObject.Add('invoiceIdentifier', SIHRec."No.");
        JsonObject.Add('invoiceRefIdentifier', '');
        JsonObject.Add('previousNoteHash', 'prevNote');
        JsonObject.Add('reasonStated', 'rgeegr');
        //JsonObject.Add('totalVatAmount', SIHRec."VAT Amount"); //MA18022024
        JsonObject.Add('totalVatAmount', SIHRec."Amount Including VAT");
        JsonObject.Add('totalAmtWoVatCur', SIHRec."Amount");
        JsonObject.Add('totalAmtWoVatMur', SIHRec."Amount");
        JsonObject.Add('invoiceTotal', SIHRec."Amount Including VAT");
        JsonObject.Add('discountTotalAmount', SIHRec."Invoice Discount Amount");
        JsonObject.Add('totalAmtPaid', SIHRec."Amount Including VAT"); //MA08MAR2025
        //JsonObject.Add('dateTimeInvoiceIssued', Format(SIHRec."Posting Date", 0, '<Year4><Month,2><Day,2> <Hour24,2><Minute,2><Second,2>'));
        PostingDateTime := CreateDateTime(SIHRec."Posting Date", 000000T); // Convert Posting Date to DateTime
        DateTimeString := Format(PostingDateTime, 0, 'yyyyMMdd HHmmss'); // Correct format
        JsonObject.Add('dateTimeInvoiceIssued', PostingDateTime);


        // Seller Details
        Seller.Add('name', 'Test User');
        Seller.Add('tradeName', CompRec.Name);
        Seller.Add('tan', CompRec.TAN);
        Seller.Add('brn', CompRec.BRN);
        Seller.Add('businessAddr', CompRec.Address);
        Seller.Add('businessPhoneNo', CompRec."Phone No.");
        Seller.Add('ebsCounterNo', 'a1');
        JsonObject.Add('seller', Seller);

        // Buyer Details
        Buyer.Add('name', CustRec.Name);
        Buyer.Add('tan', CustRec.TAN);
        Buyer.Add('brn', CustRec.BRN);
        Buyer.Add('businessAddr', CustRec.Address);
        Buyer.Add('buyerType', 'VATR');
        Buyer.Add('nic', '');
        JsonObject.Add('buyer', Buyer);

        // Loop through Sales Invoice Lines
        SILRec.SetRange("Document No.", SIHRec."No.");
        if SILRec.FindSet() then
            repeat
                Clear(Item);
                Item.Add('itemNo', Format(SILRec."Line No."));
                Item.Add('taxCode', 'TC01');
                Item.Add('nature', 'GOODS');
                Item.Add('productCodeMra', 'pdtCode');
                Item.Add('productCodeOwn', 'pdtOwn');
                Item.Add('itemDesc', SILRec.Description);
                Item.Add('quantity', Format(SILRec.Quantity));
                Item.Add('unitPrice', Format(SILRec."Unit Price"));
                Item.Add('discount', '0'); // Replace with actual discount if applicable
                Item.Add('discountedValue', SILRec."Inv. Discount Amount"); //MA08MAR2025
                Item.Add('amtWoVatCur', Format(SILRec.Amount));
                Item.Add('amtWoVatMur', Format(SILRec.Amount));
                //Item.Add('vatAmt', Format(ItemRec."VAT Amount"));  //MA18022024
                Item.Add('vatAmt', Format(SILRec."VAT %"));
                Item.Add('totalPrice', Format(SILRec."Line Amount"));
                ItemArray.Add(Item);
            until SILRec.Next() = 0;

        JsonObject.Add('itemList', ItemArray);
        JsonObject.Add('salesTransactions', 'CASH');

        // Convert JSON to Text using InStream
        Clear(TempBlob);
        TempBlob.CreateOutStream(JsonOutput);
        JsonObject.WriteTo(JsonOutput);

        TempBlob.CreateInStream(JsonInput);
        JsonInput.ReadText(JsonText);
        JsonText := '[' + JsonText + ']';

        exit(JsonText);



    end;



    /*

    ///////////////////// Generate IRN UnPosted Sales Invoice /////////////////////// 02/05/2024AA
    procedure SHGenerateIRN(var SHRec: Record "Sales Header")
    var
        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;
        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-Invoice");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        JsonPayLoad := CreateJSONForSHEInvoice(SHRec);
        Message('Request\' + JsonPayLoad);
        exit; //MC101024
        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckDt', AckDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckNo', AckNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);

        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Einvoice UnPosted SI";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);


        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;
            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Einvoice UnPosted SI";
            EInvoiceRec.Insert(true);
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SHRec.IRN := IrnStr;
            SHRec.EInvoiceStatus := SHRec.EInvoiceStatus::Accpted;
            SHRec."Ackmt Date" := AckDtDt;
            SHRec."Ackmt No." := AckNoStr;
            SHRec.Modify(True);

            Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SHRec."No.", IrnStr);
        end else begin
            SHRec.IRN := IrnStr;
            SHRec.EInvoiceStatus := SHRec.EInvoiceStatus::Error;
            if StrLen(messageStr) > 1024 then begin
                SHRec.ErrorText := CopyStr(messageStr, 1, 1023);
            end else begin
                SHRec.ErrorText := messageStr;
            end;
            SHRec.Modify(True);
            Message(responseText);
        end;
    end;

    /////////////// Generate IRN Sandbox ///////////////////////////////////////
    procedure GenerateIRNSandbox(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-Invoice");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        JsonPayLoad := CreateIRNPayload();
        //Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckDt', AckDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckNo', AckNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);

        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-Invoice";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);

        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-Invoice";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Accpted;
            SIHRec."Acknowledgement Date" := AckDtDt;
            SIHRec."Acknowledgement No." := AckNoStr;
            SIHRec.Modify(True);

            Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SIHRec."No.", IrnStr);

        end else begin
            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);

            Message(responseText);

        end;




    end;

    //////////////////// Cancel IRN ///////////////////////////////////
    procedure CancelIRN(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Cancel E-Invoice");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        //JsonPayLoad := CreateIRNPayload();
        JsonPayLoad := CreateJSONForCancelEInvoice(SIHRec);
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckDt', AckDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckNo', AckNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);

        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Cancel E-Invoice";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);



        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Cancel E-Invoice";
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            //SIHRec.IRN := IrnStr;
            SIHRec.IRN := '';
            SIHRec."Ackmt No." := '';
            SIHRec."Ackmt Date" := 0DT;

            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Cancel;
            SIHRec.Modify(True);

            Message('E-Invoice Cancel Successfully Inv No. %1 and IRN %2', SIHRec."No.", IrnStr);

        end else begin
            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);

            Message(responseText);

        end;




    end;

    //////////////////// Cancel IRN UnPosted Sales Invoice///////////////////////////////////
    procedure SHCancelIRN(var SHRec: Record "Sales Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Cancel E-Invoice");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        JsonPayLoad := CreateIRNPayload();
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckDt', AckDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckNo', AckNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);

        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Cancel E-Invoice";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);



        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Cancel E-Invoice";
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SHRec.IRN := IrnStr;
            SHRec.EInvoiceStatus := SHRec.EInvoiceStatus::Accpted;
            SHRec.Modify(True);

            Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SHRec."No.", IrnStr);

        end else begin
            SHRec.IRN := IrnStr;
            SHRec.EInvoiceStatus := SHRec.EInvoiceStatus::Error;
            SHRec.ErrorText := messageStr;
            SHRec.Modify(True);

            Message(responseText);

        end;
    end;

    ///////////////////// Cancel IRN Sandbox //////////////////////////////
    procedure CancelIRNSandbox(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        IrnStr: Text;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Cancel E-Invoice");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        JsonPayLoad := CreateIRNPayload();
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckDt', AckDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('AckNo', AckNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Cancel E-Invoice";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);
        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec.IRN := IrnStr;
            Evaluate(AckDtDt, AckDtStr);
            EInvoiceRec.AckDt := AckDtDt;
            EInvoiceRec."AckNo." := AckNoStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Cancel E-Invoice";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Accpted;
            SIHRec.Modify(True);

            Message('E-Invoice Generated Successfully Inv No. %1 and IRN %2', SIHRec."No.", IrnStr);

        end else begin
            SIHRec.IRN := IrnStr;
            SIHRec.EInvoiceStatus := SIHRec.EInvoiceStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);

            Message(responseText);
        end;
    end;

    //////////////////////// Generate E-WayBill on IRN ////////////////////////////
    procedure GenerateEWayBillonIRN(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        messageStr: Text;
        EwbDtStr: Text;
        EwbDtDt: DateTime;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        // JsonPayLoad := CreateEWayIRNPayload(SIHRec);
        //JsonPayLoad := CreateEWayIRNPayload(SIHRec); //MA120124
        JsonPayLoad := CreateEwaybill(SIHRec); //MA120124
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-WayBill on IRN";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);
        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Accpted;
            SIHRec.Modify(True);

            Message('Generate E-WayBill on IRN Generated Successfully Inv No. %1 and E-WayBill %2', SIHRec."No.", EwbNoStr);

        end else begin
            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);
            Message(responseText);
        end;
    end;


    ///////////////////////// Generate E-WayBill Without IRN//////////////////////////////////////////////////

    procedure GenerateEWayBillWithoutIRN(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        messageStr: Text;
        EwbDtStr: Text;
        EwbDtDt: DateTime;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        // JsonPayLoad := CreateEWayIRNPayload(SIHRec);
        JsonPayLoad := CreateEWayIRNPayload(SIHRec);
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-WayBill on IRN";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);
        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Accpted;
            SIHRec.Modify(True);

            Message('Generate E-WayBill Without IRN Generated Successfully Inv No. %1 and E-WayBill %2', SIHRec."No.", EwbNoStr);

        end else begin
            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);
            Message(responseText);
        end;
    end;
    /////////////////////////   END Generate E-WayBill Without IRN//////////////////////////////////////////////////

    //////////////////////// Generate E-WayBill on IRN  UnPosted Sales Invoice ////////////////////////////
    procedure SHGenerateEWayBillonIRN(var SHRec: Record "Sales Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        messageStr: Text;
        EwbDtStr: Text;
        EwbDtDt: DateTime;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        //JsonPayLoad := CreateEWayIRNPayload();
        //JsonPayLoad := CreateEWayIRNPayload();
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-WayBill on IRN";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);
        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SHRec.EwayBillNo := EwbNoStr;
            SHRec.EwayBillStatus := SHRec.EwayBillStatus::Accpted;
            SHRec.Modify(True);

            Message('Generate E-WayBill on IRN Generated Successfully Inv No. %1 and E-WayBill %2', SHRec."No.", EwbNoStr);

        end else begin
            SHRec.EwayBillNo := EwbNoStr;
            SHRec.EwayBillStatus := SHRec.EwayBillStatus::Error;
            SHRec.ErrorText := messageStr;
            SHRec.Modify(True);
            Message(responseText);
        end;
    end;

    ////////////////////////// Generate E-Way Bill on IRN Sandbox /////////////////////////
    procedure GenerateEWayBillonIRNSandbox(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        EwbDtDt: DateTime;
        EwbDtStr: Text;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Generate E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        JsonPayLoad := CreateEWayIRNPayload(SIHRec);
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);

        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Generate E-WayBill on IRN";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);

        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Generate E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Accpted;
            SIHRec.Modify(True);

            Message('Generate E-WayBill on IRN Generated Successfully Inv No. %1 and E-WayBill %2', SIHRec."No.", EwbNoStr);

        end else begin
            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);
            Message(responseText);
        end;
    end;


    ///////////////////// Cancel E-WayBill on IRN ///////////////////////////////
    procedure CancelEWayBillonIRN(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        EwbDtDt: DateTime;
        EwbDtStr: Text;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Cancel E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        JsonPayLoad := CancelEWayBillonIRNPayload(SIHRec);
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Cancel E-WayBill on IRN";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);

        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Cancel E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            //SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillNo := '';
            // SIHRec. := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Cancel;
            SIHRec.Modify(True);

            Message('Cancel E-WayBill on IRN Cancel Successfully Inv No. %1 and Cancel E-WayBill %2', SIHRec."No.", EwbNoStr);

        end else begin
            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);
            Message(responseText);
        end;
    end;


    ///////////////////// Cancel E-WayBill on IRN  Unposted Sales Invoice ///////////////////////////////
    procedure SHCancelEWayBillonIRN(var SHRec: Record "Sales Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        EwbDtDt: DateTime;
        EwbDtStr: Text;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Cancel E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        //JsonPayLoad := CancelEWayBillonIRNPayload();
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Cancel E-WayBill on IRN";
        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);

        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Cancel E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SHRec.EwayBillNo := EwbNoStr;
            SHRec.EwayBillStatus := SHRec.EwayBillStatus::Accpted;
            SHRec.Modify(True);

            Message('Cancel E-WayBill on IRN Generated Successfully Inv No. %1 and Cancel E-WayBill %2', SHRec."No.", EwbNoStr);

        end else begin
            SHRec.EwayBillNo := EwbNoStr;
            SHRec.EwayBillStatus := SHRec.EwayBillStatus::Error;
            SHRec.ErrorText := messageStr;
            SHRec.Modify(True);
            Message(responseText);
        end;
    end;


    ///////////////////// Cancel E-WayBill on IRN Sandbox ///////////////////////////////
    procedure CancelEWayBillonIRNSandbox(var SIHRec: Record "Sales Invoice Header")
    var

        //CD: Codeunit "Rest API Codeunit";
        EInvoiceSetupRec: Record EInvoiceSetup;
        EInvoiceFindRec: Record EInvoice;

        EInvoiceRec: Record EInvoice;
        contentHeaders: HttpHeaders;
        JsonPayLoad: Text;
        request: HttpRequestMessage;
        url: Text;
        TokenStr: Text;
        responseText: Text;
        httpclient: HttpClient;
        content: HttpContent;
        client: HttpClient;
        response: HttpResponseMessage;
        JsonResponse: JsonObject;
        JsonTokeValue: JsonToken;
        status: Code[20];
        Irn: Code[150];
        IrnStr: Text;
        JSONManagement: Codeunit "JSON Management";
        statusStr: Text;
        EwbNoStr: Text;
        EwbDtDt: DateTime;
        EwbDtStr: Text;
        EwbValidTillStr: Text;
        EwbValidTillDT: DateTime;
        messageStr: Text;
        AckDtStr: Text;
        AckDtDt: DateTime;
        AckNoStr: Text;
        SignedQRCodeStr: Text;
        SignedInvoiceStr: Text;
        EntryNo: Integer;
        EInvoiceHistorRec: Record EInvoiceHistory;
        EInvoiceHistorRecFind: Record EInvoiceHistory;


    begin
        EInvoiceSetupRec.Reset();
        EInvoiceSetupRec.SetRange("EInvoice Type", EInvoiceSetupRec."EInvoice Type"::"Cancel E-WayBill on IRN");
        EInvoiceSetupRec.SetRange(ActiveYN, true);
        if EInvoiceSetupRec.FindFirst() then begin
            EInvoiceSetupRec.TestField(Token);
            EInvoiceSetupRec.TestField(URL);
            TokenStr := EInvoiceSetupRec.Token;
            url := EInvoiceSetupRec.URL;
        end else begin
            Error('EInvoice Setup not found with below filter-\' + EInvoiceSetupRec.GetFilters());
        end;

        //JsonPayLoad := CreateJSONForEInvoice(SIHRec);
        //JsonPayLoad := CancelEWayBillonIRNPayload();
        Message('Request\' + JsonPayLoad);

        // Add the payload to the content
        content.WriteFrom(JsonPayLoad);
        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');
        contentHeaders.Add('Token', TokenStr);
        //client.DefaultRequestHeaders().Add('Authorization', AuthString);
        request.Content := content;
        request.SetRequestUri(url);
        request.Method := 'POST';// 'POST';

        client.Send(request, response);
        // Read the response content as json.
        response.Content().ReadAs(responseText);
        //Message(responseText);

        JSONManagement.InitializeObject(responseText);
        JSONManagement.GetArrayPropertyValueAsStringByName('status', statusStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbNo', EwbNoStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbDt', EwbDtStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('EwbValidTill', EwbValidTillStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('Irn', IrnStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedQRCode', SignedQRCodeStr);
        //JSONManagement.GetArrayPropertyValueAsStringByName('SignedInvoice', SignedInvoiceStr);
        JSONManagement.GetArrayPropertyValueAsStringByName('message', messageStr);


        if EInvoiceHistorRecFind.FindLast() then
            EntryNo := EInvoiceHistorRecFind."Entry No." + 1
        else
            EntryNo := 1;

        EInvoiceHistorRec.Init();
        EInvoiceHistorRec."Entry No." := EntryNo;
        EInvoiceHistorRec."Document No." := SIHRec."No.";
        EInvoiceHistorRec.Insert(true);
        //Request Text
        SetRequestText(EInvoiceHistorRec, JsonPayLoad);
        //Request Text
        SetResponseText(EInvoiceHistorRec, responseText);
        EInvoiceHistorRec."EInvoice Type" := EInvoiceHistorRec."EInvoice Type"::"Cancel E-WayBill on IRN";

        if statusStr = '1' then begin
            EInvoiceHistorRec.Status := true;
        end;
        EInvoiceHistorRec.Modify(true);

        if statusStr = '1' then begin
            if EInvoiceFindRec.FindLast() then
                EntryNo := EInvoiceFindRec."Entry No." + 1
            else
                EntryNo := 1;

            EInvoiceRec.Init();
            EInvoiceRec."Entry No." := EntryNo;
            EInvoiceRec."No." := SIHRec."No.";
            EInvoiceRec.Status := statusStr;
            EInvoiceRec."EwbNo." := EwbNoStr;
            Evaluate(EwbDtDt, EwbDtStr);
            EInvoiceRec."EwbDt." := EwbDtDt;
            Evaluate(EwbValidTillDT, EwbValidTillStr);
            EInvoiceRec.EwbValidTill := EwbValidTillDT;
            EInvoiceRec.IRN := IrnStr;
            EInvoiceRec.SignedQRCode := SignedQRCodeStr;
            //EInvoiceRec.SignedInvoice := SignedInvoiceStr;
            EInvoiceRec."EInvoice Type" := EInvoiceRec."EInvoice Type"::"Cancel E-WayBill on IRN";
            EInvoiceRec.Insert(true);
            // Update SignedInvoice
            SetSignedInvoiceText(EInvoiceRec, SignedInvoiceStr);

            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Accpted;
            SIHRec.Modify(True);

            Message('Cancel E-WayBill on IRN Generated Successfully Inv No. %1 and Cancel E-WayBill %2', SIHRec."No.", EwbNoStr);

        end else begin
            SIHRec.EwayBillNo := EwbNoStr;
            SIHRec.EwayBillStatus := SIHRec.EwayBillStatus::Error;
            SIHRec.ErrorText := messageStr;
            SIHRec.Modify(True);
            Message(responseText);
        end;
    end;


    local procedure CreateIRNPayload(): Text;
    var
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;

    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);


        //TranDtls

        TranDtls.Add('TaxSch', 'GST');
        TranDtls.Add('SupTyp', 'B2B');
        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');


        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', '23-24/DEM/54');
        DocDtls.Add('Dt', '11/09/2023');
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', '29AADCG4992P1ZP');
        SellerDtls.Add('LglNm', 'GSTZEN DEMO PRIVATE LIMITED');
        SellerDtls.Add('Addr1', 'Manyata Tech Park');
        SellerDtls.Add('Loc', 'BANGALORE');
        SellerDtls.Add('Pin', 560077);
        SellerDtls.Add('Stcd', '29');
        MainJson.Add('SellerDtls', SellerDtls);

        //BuyerDtls
        BuyerDtls.Add('Gstin', '06AAMCS8709B1ZA');
        BuyerDtls.Add('LglNm', 'Quality Products Private Limited');
        BuyerDtls.Add('Pos', '06');
        BuyerDtls.Add('Addr1', '133, Mahatma Gandhi Road');
        BuyerDtls.Add('Loc', 'HARYANA');
        BuyerDtls.Add('Pin', 121009);
        BuyerDtls.Add('Stcd', '06');
        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', 'Maharashtra Storage');
        DispDtls.Add('Addr1', '133, Mahatma Gandhi Road');
        DispDtls.Add('Loc', 'Bhiwandi');
        DispDtls.Add('Pin', 400001);
        DispDtls.Add('Stcd', '27');
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', 'URP');
        ShipDtls.Add('LglNm', 'Quality Products Construction Site');
        ShipDtls.Add('Addr1', 'Anna Salai');
        ShipDtls.Add('Loc', 'Chennai');
        ShipDtls.Add('Pin', 600001);
        ShipDtls.Add('Stcd', '33');
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 

        //ItemListArr Line Data
        ItemList.Add('ItemNo', '1010');
        ItemList.Add('SlNo', 1);
        ItemList.Add('IsServc', 'N');
        ItemList.Add('PrdDesc', 'Computer Hardware - Keyboard and Mouse');
        ItemList.Add('HsnCd', '33059011');
        ItemList.Add('Qty', 25);
        ItemList.Add('FreeQty', 0);
        ItemList.Add('Unit', 'PCS');
        ItemList.Add('UnitPrice', 200);
        ItemList.Add('TotAmt', 5000);
        ItemList.Add('Discount', 0);
        ItemList.Add('PreTaxVal', 0);
        ItemList.Add('AssAmt', 5000);
        ItemList.Add('GstRt', 18);
        ItemList.Add('IgstAmt', 900);
        ItemList.Add('CgstAmt', 0);
        ItemList.Add('SgstAmt', 0);
        ItemList.Add('CesRt', 0);
        ItemList.Add('CesAmt', 0);
        ItemList.Add('CesNonAdvlAmt', 0);
        ItemList.Add('StateCesRt', 0);
        ItemList.Add('StateCesAmt', 0);
        ItemList.Add('StateCesNonAdvlAmt', 0);
        ItemList.Add('OthChrg', 0);
        ItemList.Add('TotItemVal', 5900);
        ItemListArr.Add(ItemList);
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', 5000);
        ValDtls.Add('CgstVal', 0);
        ValDtls.Add('SgstVal', 0);
        ValDtls.Add('IgstVal', 900);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', 5900);
        MainJson.Add('ValDtls', ValDtls);
        MainJson.WriteTo(JsonData);
        exit(JsonData);
    end;

    /////////////////////////////////////////E WAY BILL WITH IRN ///////////////////////////////////12JAN2024
    local procedure CreateEwaybill(SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        StateRec: Record State;
        CustRec: Record Customer;
        DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;
        EwbDtls: JsonObject; //MA120125
        PP: Text;
    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);
        Clear(EwbDtls); //MA120125

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        //if SIHRec.FindFirst() then begin

        if CustRec.get(SIHRec."Sell-to Customer No.") then;



        //TranDtls

        TranDtls.Add('TaxSch', 'GST');
        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            TranDtls.Add('SupTyp', 'EXPWOP');
        end else begin
            TranDtls.Add('SupTyp', 'B2B');
        end;

        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');
        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', SIHRec."No.");
        DocDtls.Add('Dt', FORMAT(SIHRec."Posting Date", 10, '<Day,2>/<Month,2>/<Year4>'));
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', CompRec."GST Registration No.");
        SellerDtls.Add('LglNm', CompRec.Name);
        SellerDtls.Add('Addr1', CompRec.Address);
        SellerDtls.Add('Loc', CompRec.City);
        Evaluate(SellerDtlsPin, CompRec."Post Code");
        SellerDtls.Add('Pin', SellerDtlsPin);
        SellerDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('SellerDtls', SellerDtls);


        //BuyerDtls
        BuyerDtls_Stcd := '';
        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Gstin', 'URP');
            BuyerDtls_Stcd := '96'
        end else begin
            BuyerDtls.Add('Gstin', CustRec."GST Registration No.");
        end;

        BuyerDtls.Add('LglNm', CustRec.Name);

        BuyerDtls.Add('Pos', BuyerDtls_Stcd);


        BuyerDtls.Add('Addr1', CustRec.Address);
        BuyerDtls.Add('Loc', CustRec.City);
        Evaluate(BuyerDtlsPin, CustRec."Post Code");

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Pin', '999999');
            BuyerDtls.Add('Stcd', '96');
        end else begin
            BuyerDtls.Add('Pin', BuyerDtlsPin);
            BuyerDtls.Add('Stcd', BuyerDtls_Stcd);
        end;

        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', CompRec.Name);
        DispDtls.Add('Addr1', CompRec.Address);
        DispDtls.Add('Loc', CompRec.City);
        Evaluate(DispDtlsPin, CompRec."Post Code");
        DispDtls.Add('Pin', DispDtlsPin);
        DispDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', CustRec."GST Registration No.");
        ShipDtls.Add('LglNm', SIHRec."Ship-to Name");
        //ShipDtls.Add('Addr1', StringConversionManagementCU.RemoveNonAlphaNumericCharacters(SIHRec."Ship-to Address"));
        ShipDtls.Add('Addr1', DeleteSpecialChars(SIHRec."Ship-to Address"));

        ShipDtls.Add('Loc', SIHRec."Ship-to City");
        Evaluate(ShipDtlsPin, SIHRec."Ship-to Post Code");
        ShipDtls.Add('Pin', ShipDtlsPin);
        ShipDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 


        //////Create JSON Line Item /////////////////////////////
        //ItemListArr Line Data
        Ln := 1;
        SILRec.Reset();
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');

        if SILRec.FindFirst() then begin
            Clear(ItemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;

            repeat
                Clear(ItemList);
                ItemCode := 0;
                //ItemNo := SILRec."No.";
                //ReplaceString;
                //ItemNo := ReplaceString(ItemNo, '-', '');
                // ItemNo := ReplaceString(ItemNo, '/', '');
                // ItemNo := ReplaceString(ItemNo, '\', '');
                ItemList.Add('ItemNo', ItemCode);
                //ItemList.Add('SlNo', SILRec."Line No.");
                ItemList.Add('SlNo', Format(Ln));

                if (SILRec.Type = SILRec.Type::"G/L Account") then begin
                    ItemList.Add('IsServc', 'Y');
                end else begin
                    ItemList.Add('IsServc', 'N');
                end;
                ItemList.Add('PrdDesc', SILRec.Description);
                ItemList.Add('HsnCd', SILRec."HSN/SAC Code");
                ItemList.Add('Qty', SILRec.Quantity);
                ItemList.Add('FreeQty', 0);
                ItemList.Add('Unit', SILRec."Unit of Measure Code");
                ItemList.Add('UnitPrice', SILRec."Unit Price");
                ItemList.Add('TotAmt', SILRec."Line Amount");
                ItemList.Add('Discount', SILRec."Line Discount Amount");
                ItemList.Add('PreTaxVal', 0);
                ItemList.Add('AssAmt', SILRec.Amount);
                G_AssVal += SILRec.Amount;

                DetailedGSTLedgerEntryRec.Reset();
                DetailedGSTLedgerEntryRec.SetRange("Document No.", SILRec."Document No.");
                DetailedGSTLedgerEntryRec.SetRange("Document Line No.", SILRec."Line No.");
                if DetailedGSTLedgerEntryRec.FindFirst() then;
                Cnt := DetailedGSTLedgerEntryRec.Count;

                TotItemVal := SILRec.Amount;


                ItemList.Add('GstRt', DetailedGSTLedgerEntryRec."GST %");
                if Cnt = 1 then begin
                    ItemList.Add('IgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                    G_IgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_CgstVal += 0;
                    G_SgstVal += 0;


                    ItemList.Add('CgstAmt', 0);
                    ItemList.Add('SgstAmt', 0);
                end else begin
                    ItemList.Add('IgstAmt', 0);
                    ItemList.Add('CgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);
                    ItemList.Add('SgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1 * 2;

                    G_IgstVal += 0;
                    G_CgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_SgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                end;

                ItemList.Add('CesRt', 0);
                ItemList.Add('CesAmt', 0);
                ItemList.Add('CesNonAdvlAmt', 0);
                ItemList.Add('StateCesRt', 0);
                ItemList.Add('StateCesAmt', 0);
                ItemList.Add('StateCesNonAdvlAmt', 0);
                ItemList.Add('OthChrg', 0);
                ItemList.Add('TotItemVal', TotItemVal);
                G_TotItemVal += TotItemVal;
                ItemListArr.Add(ItemList);
                Ln += 1;
            until SILRec.Next() = 0;
        end;
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', G_AssVal);
        ValDtls.Add('CgstVal', G_CgstVal);
        ValDtls.Add('SgstVal', G_SgstVal);
        ValDtls.Add('IgstVal', G_IgstVal);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', G_TotItemVal);
        MainJson.Add('ValDtls', ValDtls);
        //M120124//MainJson.WriteTo(JsonData);
        //exit(JsonData);
        //end;


        //EwbDtls
        //PP := '@null@';
        //EwbDtls.Add('TransId', PP);
        //EwbDtls.Add('TransName', PP);
        EwbDtls.Add('TransMode', '1');
        EwbDtls.Add('Distance', 0);
        EwbDtls.Add('VehNo', 'PVC1234');
        EwbDtls.Add('VehType', 'R');
        MainJson.Add('EwbDtls', EwbDtls);
        MainJson.WriteTo(JsonData);
        //JsonData := JsonData.Replace('`', 'null');
        exit(JsonData);
        //end;
    end;


    /////////////////////////////////////////END E WAY BILL WITH IRN ///////////////////////////////////12JAN2024


    local procedure CreateEWayIRNPayload(var SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        BuyerDtls_Stcd: code[20];
        SellerDtlsPin: Integer;
        CustRec: Record Customer;
        SellerDtls_Stcd: Code[20];
        CompRec: Record "Company Information";
        actFromStateCode: Code[20];
        StateRec: Record "State";
        StateComRec: Record "State";
        EWayPayload: JsonObject;
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        itemListArr: JsonArray;
        itemList: JsonObject;
        ValDtls: JsonObject;
        EwbDtls: JsonObject;
        Ln: Integer;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

    begin
        Clear(EWayPayload);
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(itemListArr);
        Clear(itemList);
        Clear(ValDtls);

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
            //actFromStateCode := StateRec.
        end;
        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        //if SIHRec.FindFirst() then begin

        if CustRec.get(SIHRec."Sell-to Customer No.") then;
        //TranDtls

        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;

        EWayPayload.Add('supplyType', '0');
        EWayPayload.Add('subSupplyType', '1');
        EWayPayload.Add('subSupplyDesc', '');
        EWayPayload.Add('docType', 'INV');
        EWayPayload.Add('docNo', SIHRec."No.");
        EWayPayload.Add('docDate', SIHRec."Posting Date");
        EWayPayload.Add('fromGstin', CompRec."GST Registration No.");
        EWayPayload.Add('fromTrdName', CompRec."Name");
        EWayPayload.Add('fromAddr1', CompRec.Address);
        EWayPayload.Add('fromAddr2', CompRec."Address 2");
        EWayPayload.Add('fromPlace', CompRec.City);
        EWayPayload.Add('fromPincode', CompRec."Post Code");
        EWayPayload.Add('actFromStateCode', SellerDtls_Stcd);
        EWayPayload.Add('fromStateCode', SellerDtls_Stcd);
        EWayPayload.Add('toGstin', CustRec."GST Registration No.");
        EWayPayload.Add('toTrdName', CustRec.Name);
        EWayPayload.Add('toAddr1', CustRec.Address);
        EWayPayload.Add('toAddr2', CustRec."Address 2");
        EWayPayload.Add('toPlace', CustRec.City);
        EWayPayload.Add('toPincode', CustRec."Post Code");
        EWayPayload.Add('actToStateCode', BuyerDtls_Stcd);
        EWayPayload.Add('toStateCode', BuyerDtls_Stcd);
        EWayPayload.Add('transactionType', 4);
        EWayPayload.Add('otherValue', '0');
        EWayPayload.Add('totalValue', SILRec.Amount);
        EWayPayload.Add('cgstValue', G_CgstVal);
        EWayPayload.Add('sgstValue', G_SgstVal);
        EWayPayload.Add('igstValue', G_IgstVal);
        EWayPayload.Add('cessValue', 400.56);
        EWayPayload.Add('cessNonAdvolValue', 400);
        EWayPayload.Add('totInvValue', 68358);
        EWayPayload.Add('transporterId', '');
        EWayPayload.Add('transporterName', '');
        EWayPayload.Add('transDocNo', '');
        EWayPayload.Add('transMode', '1');
        EWayPayload.Add('transDistance', '100');
        EWayPayload.Add('transDocDate', '');
        EWayPayload.Add('vehicleNo', 'PVC1234');
        EWayPayload.Add('vehicleType', 'R');

        Ln := 1;
        SILRec.Reset();
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');

        if SILRec.FindFirst() then begin
            Clear(itemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;
            repeat
                Clear(itemList);

                //ItemList.Add('ItemNo', SILRec."No.");  //MA050125
                itemList.Add('productName', SILRec.Description);
                itemList.Add('productDesc', SILRec.Description);
                itemList.Add('hsnCode', SILRec."HSN/SAC Code");
                itemList.Add('quantity', SILRec.Quantity);
                itemList.Add('qtyUnit', SILRec."Unit of Measure");
                itemList.Add('cgstRate', G_CgstVal);
                itemList.Add('sgstRate', G_SgstVal);
                itemList.Add('igstRate', G_IgstVal);
                itemList.Add('cessRate', 3);
                itemList.Add('cessNonadvol', 0);
                itemList.Add('taxableAmount', 5609889);
                itemListArr.Add(itemList);
            until SILRec.Next() = 0;

            EWayPayload.Add('itemList', itemListArr);

            //EWayPayload.WriteTo(JsonData);//MA27122024

            //TranDtls
            // TranDtls.Add('TaxSch', 'GST');
            // TranDtls.Add('SupTyp', 'B2B');
            // TranDtls.Add('RegRev', 'N');
            // TranDtls.Add('IgstOnIntra', 'N');


            // MainJson.Add('Version', '1.1');
            // MainJson.Add('TranDtls', TranDtls);
            // //MainJson.WriteTo(JsonData);

            // //DocDtls
            // DocDtls.Add('Typ', 'INV');
            // DocDtls.Add('No', '23-24/DEM/54');
            // DocDtls.Add('Dt', '11/09/2023');
            // MainJson.Add('DocDtls', DocDtls);


            // //SellerDtls
            // SellerDtls.Add('Gstin', '29AADCG4992P1ZP');
            // SellerDtls.Add('LglNm', 'GSTZEN DEMO PRIVATE LIMITED');
            // SellerDtls.Add('Addr1', 'Manyata Tech Park');
            // SellerDtls.Add('Loc', 'BANGALORE');
            // SellerDtls.Add('Pin', 560077);
            // SellerDtls.Add('Stcd', '29');
            // MainJson.Add('SellerDtls', SellerDtls);

            // //BuyerDtls
            // BuyerDtls.Add('Gstin', '06AAMCS8709B1ZA');
            // BuyerDtls.Add('LglNm', 'Quality Products Private Limited');
            // BuyerDtls.Add('Pos', '06');
            // BuyerDtls.Add('Addr1', '133, Mahatma Gandhi Road');
            // BuyerDtls.Add('Loc', 'HARYANA');
            // BuyerDtls.Add('Pin', 121009);
            // BuyerDtls.Add('Stcd', '06');
            // MainJson.Add('BuyerDtls', BuyerDtls);


            // //DispDtls
            // DispDtls.Add('Nm', 'Maharashtra Storage');
            // DispDtls.Add('Addr1', '133, Mahatma Gandhi Road');
            // DispDtls.Add('Loc', 'Bhiwandi');
            // DispDtls.Add('Pin', 400001);
            // DispDtls.Add('Stcd', '27');
            // MainJson.Add('DispDtls', DispDtls);

            // //ShipDtls
            // ShipDtls.Add('Gstin', 'URP');
            // ShipDtls.Add('LglNm', 'Quality Products Construction Site');
            // ShipDtls.Add('Addr1', 'Anna Salai');
            // ShipDtls.Add('Loc', 'Chennai');
            // ShipDtls.Add('Pin', 600001);
            // ShipDtls.Add('Stcd', '33');
            // MainJson.Add('ShipDtls', ShipDtls);
            // //MainJson.WriteTo(JsonData); 

            // //ItemListArr Line Data
            // ItemList.Add('ItemNo', '1010');
            // ItemList.Add('SlNo', 1);
            // ItemList.Add('IsServc', 'N');
            // ItemList.Add('PrdDesc', 'Computer Hardware - Keyboard and Mouse');
            // ItemList.Add('HsnCd', '33059011');
            // ItemList.Add('Qty', 25);
            // ItemList.Add('FreeQty', 0);
            // ItemList.Add('Unit', 'PCS');
            // ItemList.Add('UnitPrice', 200);
            // ItemList.Add('TotAmt', 5000);
            // ItemList.Add('Discount', 0);
            // ItemList.Add('PreTaxVal', 0);
            // ItemList.Add('AssAmt', 5000);
            // ItemList.Add('GstRt', 18);
            // ItemList.Add('IgstAmt', 900);
            // ItemList.Add('CgstAmt', 0);
            // ItemList.Add('SgstAmt', 0);
            // ItemList.Add('CesRt', 0);
            // ItemList.Add('CesAmt', 0);
            // ItemList.Add('CesNonAdvlAmt', 0);
            // ItemList.Add('StateCesRt', 0);
            // ItemList.Add('StateCesAmt', 0);
            // ItemList.Add('StateCesNonAdvlAmt', 0);
            // ItemList.Add('OthChrg', 0);
            // ItemList.Add('TotItemVal', 5900);
            // ItemListArr.Add(ItemList);
            // MainJson.Add('ItemList', ItemListArr);

            // //ValDtls
            // ValDtls.Add('AssVal', 5000);
            // ValDtls.Add('CgstVal', 0);
            // ValDtls.Add('SgstVal', 0);
            // ValDtls.Add('IgstVal', 900);
            // ValDtls.Add('CesVal', 0);
            // ValDtls.Add('StCesVal', 0);
            // ValDtls.Add('Discount', 0);
            // ValDtls.Add('OthChrg', 0);
            // ValDtls.Add('RndOffAmt', 0);
            // ValDtls.Add('TotInvVal', 5900);
            // MainJson.Add('ValDtls', ValDtls);

            // //EwbDtls
            // EwbDtls.Add('TransId', '21ADAPP6261D1Z1');
            // EwbDtls.Add('TransName', 'Just in time Shippers Pvt Limited');
            // EwbDtls.Add('TransMode', '1');
            // EwbDtls.Add('Distance', '0');
            // EwbDtls.Add('VehNo', 'KA331234');
            // EwbDtls.Add('VehType', 'R');
            // MainJson.Add('EwbDtls', EwbDtls);
            // MainJson.WriteTo(JsonData);//MA271224
            EWayPayload.WriteTo(JsonData);
            exit(JsonData);

        end;
    end;
    ///////////////////////////////// CancelEWayBillonIRNPayload ///////////////////////////////////////////////// MC18012025
    local procedure CancelEWayBillonIRNPayload(SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        StateRec: Record State;
        CustRec: Record Customer;
        DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;
        EwbDtls: JsonObject; //MA120125
        PP: Text;
    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);
        Clear(EwbDtls); //MA120125

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        //if SIHRec.FindFirst() then begin

        if CustRec.get(SIHRec."Sell-to Customer No.") then;



        //TranDtls

        TranDtls.Add('TaxSch', 'GST');
        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            TranDtls.Add('SupTyp', 'EXPWOP');
        end else begin
            TranDtls.Add('SupTyp', 'B2B');
        end;

        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');
        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', SIHRec."No.");
        DocDtls.Add('Dt', FORMAT(SIHRec."Posting Date", 10, '<Day,2>/<Month,2>/<Year4>'));
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', CompRec."GST Registration No.");
        SellerDtls.Add('LglNm', CompRec.Name);
        SellerDtls.Add('Addr1', CompRec.Address);
        SellerDtls.Add('Loc', CompRec.City);
        Evaluate(SellerDtlsPin, CompRec."Post Code");
        SellerDtls.Add('Pin', SellerDtlsPin);
        SellerDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('SellerDtls', SellerDtls);


        //BuyerDtls
        BuyerDtls_Stcd := '';
        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Gstin', 'URP');
            BuyerDtls_Stcd := '96'
        end else begin
            BuyerDtls.Add('Gstin', CustRec."GST Registration No.");
        end;

        BuyerDtls.Add('LglNm', CustRec.Name);

        BuyerDtls.Add('Pos', BuyerDtls_Stcd);


        BuyerDtls.Add('Addr1', CustRec.Address);
        BuyerDtls.Add('Loc', CustRec.City);
        Evaluate(BuyerDtlsPin, CustRec."Post Code");

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Pin', '999999');
            BuyerDtls.Add('Stcd', '96');
        end else begin
            BuyerDtls.Add('Pin', BuyerDtlsPin);
            BuyerDtls.Add('Stcd', BuyerDtls_Stcd);
        end;

        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', CompRec.Name);
        DispDtls.Add('Addr1', CompRec.Address);
        DispDtls.Add('Loc', CompRec.City);
        Evaluate(DispDtlsPin, CompRec."Post Code");
        DispDtls.Add('Pin', DispDtlsPin);
        DispDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', CustRec."GST Registration No.");
        ShipDtls.Add('LglNm', SIHRec."Ship-to Name");
        //ShipDtls.Add('Addr1', StringConversionManagementCU.RemoveNonAlphaNumericCharacters(SIHRec."Ship-to Address"));
        ShipDtls.Add('Addr1', DeleteSpecialChars(SIHRec."Ship-to Address"));

        ShipDtls.Add('Loc', SIHRec."Ship-to City");
        Evaluate(ShipDtlsPin, SIHRec."Ship-to Post Code");
        ShipDtls.Add('Pin', ShipDtlsPin);
        ShipDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 


        //////Create JSON Line Item /////////////////////////////
        //ItemListArr Line Data
        Ln := 1;
        SILRec.Reset();
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');

        if SILRec.FindFirst() then begin
            Clear(ItemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;

            repeat
                Clear(ItemList);
                ItemCode := 0;
                //ItemNo := SILRec."No.";
                //ReplaceString;
                //ItemNo := ReplaceString(ItemNo, '-', '');
                // ItemNo := ReplaceString(ItemNo, '/', '');
                // ItemNo := ReplaceString(ItemNo, '\', '');
                ItemList.Add('ItemNo', ItemCode);
                //ItemList.Add('SlNo', SILRec."Line No.");
                ItemList.Add('SlNo', Format(Ln));

                if (SILRec.Type = SILRec.Type::"G/L Account") then begin
                    ItemList.Add('IsServc', 'Y');
                end else begin
                    ItemList.Add('IsServc', 'N');
                end;
                ItemList.Add('PrdDesc', SILRec.Description);
                ItemList.Add('HsnCd', SILRec."HSN/SAC Code");
                ItemList.Add('Qty', SILRec.Quantity);
                ItemList.Add('FreeQty', 0);
                ItemList.Add('Unit', SILRec."Unit of Measure Code");
                ItemList.Add('UnitPrice', SILRec."Unit Price");
                ItemList.Add('TotAmt', SILRec."Line Amount");
                ItemList.Add('Discount', SILRec."Line Discount Amount");
                ItemList.Add('PreTaxVal', 0);
                ItemList.Add('AssAmt', SILRec.Amount);
                G_AssVal += SILRec.Amount;

                DetailedGSTLedgerEntryRec.Reset();
                DetailedGSTLedgerEntryRec.SetRange("Document No.", SILRec."Document No.");
                DetailedGSTLedgerEntryRec.SetRange("Document Line No.", SILRec."Line No.");
                if DetailedGSTLedgerEntryRec.FindFirst() then;
                Cnt := DetailedGSTLedgerEntryRec.Count;

                TotItemVal := SILRec.Amount;


                ItemList.Add('GstRt', DetailedGSTLedgerEntryRec."GST %");
                if Cnt = 1 then begin
                    ItemList.Add('IgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                    G_IgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_CgstVal += 0;
                    G_SgstVal += 0;


                    ItemList.Add('CgstAmt', 0);
                    ItemList.Add('SgstAmt', 0);
                end else begin
                    ItemList.Add('IgstAmt', 0);
                    ItemList.Add('CgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);
                    ItemList.Add('SgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1 * 2;

                    G_IgstVal += 0;
                    G_CgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_SgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                end;

                ItemList.Add('CesRt', 0);
                ItemList.Add('CesAmt', 0);
                ItemList.Add('CesNonAdvlAmt', 0);
                ItemList.Add('StateCesRt', 0);
                ItemList.Add('StateCesAmt', 0);
                ItemList.Add('StateCesNonAdvlAmt', 0);
                ItemList.Add('OthChrg', 0);
                ItemList.Add('TotItemVal', TotItemVal);
                G_TotItemVal += TotItemVal;
                ItemListArr.Add(ItemList);
                Ln += 1;
            until SILRec.Next() = 0;
        end;
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', G_AssVal);
        ValDtls.Add('CgstVal', G_CgstVal);
        ValDtls.Add('SgstVal', G_SgstVal);
        ValDtls.Add('IgstVal', G_IgstVal);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', G_TotItemVal);
        MainJson.Add('ValDtls', ValDtls);

        MainJson.WriteTo(JsonData);
        exit(JsonData);
        //end;


        //EwbDtls
        //PP := '@null@';
        //EwbDtls.Add('TransId', PP);
        //EwbDtls.Add('TransName', PP);
        //EwbDtls.Add('TransMode', '1');
        //EwbDtls.Add('Distance', 0);
        //EwbDtls.Add('VehNo', 'PVC1234');
        //EwbDtls.Add('VehType', 'R');
        //MainJson.Add('EwbDtls', EwbDtls);
        //MainJson.WriteTo(JsonData);
        //JsonData := JsonData.Replace('`', 'null');
        //exit(JsonData);
        //end;
    end;
    ///////////////////////////////// END CancelEWayBillonIRNPayload ///////////////////////////////////////////////// MC18012025
    


    //////////////////////////////////////// CreateJSONForCancelEInvoice//////////////////////////////////////////////// //MC 17012025
    local procedure CreateJSONForCancelEInvoice(SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        StateRec: Record State;
        CustRec: Record Customer;
        DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;

    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        //if SIHRec.FindFirst() then begin

        if CustRec.get(SIHRec."Sell-to Customer No.") then;



        //TranDtls

        TranDtls.Add('TaxSch', 'GST');
        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            TranDtls.Add('SupTyp', 'EXPWOP');
        end else begin
            TranDtls.Add('SupTyp', 'B2B');
        end;

        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');
        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', SIHRec."No.");
        DocDtls.Add('Dt', FORMAT(SIHRec."Posting Date", 10, '<Day,2>/<Month,2>/<Year4>'));
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', CompRec."GST Registration No.");
        SellerDtls.Add('LglNm', CompRec.Name);
        SellerDtls.Add('Addr1', CompRec.Address);
        SellerDtls.Add('Loc', CompRec.City);
        Evaluate(SellerDtlsPin, CompRec."Post Code");
        SellerDtls.Add('Pin', SellerDtlsPin);
        SellerDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('SellerDtls', SellerDtls);


        //BuyerDtls
        BuyerDtls_Stcd := '';
        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Gstin', 'URP');
            BuyerDtls_Stcd := '96'
        end else begin
            BuyerDtls.Add('Gstin', CustRec."GST Registration No.");
        end;

        BuyerDtls.Add('LglNm', CustRec.Name);

        BuyerDtls.Add('Pos', BuyerDtls_Stcd);


        BuyerDtls.Add('Addr1', CustRec.Address);
        BuyerDtls.Add('Loc', CustRec.City);
        Evaluate(BuyerDtlsPin, CustRec."Post Code");

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Pin', '999999');
            BuyerDtls.Add('Stcd', '96');
        end else begin
            BuyerDtls.Add('Pin', BuyerDtlsPin);
            BuyerDtls.Add('Stcd', BuyerDtls_Stcd);
        end;

        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', CompRec.Name);
        DispDtls.Add('Addr1', CompRec.Address);
        DispDtls.Add('Loc', CompRec.City);
        Evaluate(DispDtlsPin, CompRec."Post Code");
        DispDtls.Add('Pin', DispDtlsPin);
        DispDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', CustRec."GST Registration No.");
        ShipDtls.Add('LglNm', SIHRec."Ship-to Name");
        //ShipDtls.Add('Addr1', StringConversionManagementCU.RemoveNonAlphaNumericCharacters(SIHRec."Ship-to Address"));
        ShipDtls.Add('Addr1', DeleteSpecialChars(SIHRec."Ship-to Address"));

        ShipDtls.Add('Loc', SIHRec."Ship-to City");
        Evaluate(ShipDtlsPin, SIHRec."Ship-to Post Code");
        ShipDtls.Add('Pin', ShipDtlsPin);
        ShipDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 


        //////Create JSON Line Item /////////////////////////////
        //ItemListArr Line Data
        Ln := 1;
        SILRec.Reset();
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');

        if SILRec.FindFirst() then begin
            Clear(ItemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;

            repeat
                Clear(ItemList);
                ItemCode := 0;
                //ItemNo := SILRec."No.";
                //ReplaceString;
                //ItemNo := ReplaceString(ItemNo, '-', '');
                // ItemNo := ReplaceString(ItemNo, '/', '');
                // ItemNo := ReplaceString(ItemNo, '\', '');
                ItemList.Add('ItemNo', ItemCode);
                //ItemList.Add('SlNo', SILRec."Line No.");
                ItemList.Add('SlNo', Format(Ln));

                if (SILRec.Type = SILRec.Type::"G/L Account") then begin
                    ItemList.Add('IsServc', 'Y');
                end else begin
                    ItemList.Add('IsServc', 'N');
                end;
                ItemList.Add('PrdDesc', SILRec.Description);
                ItemList.Add('HsnCd', SILRec."HSN/SAC Code");
                ItemList.Add('Qty', SILRec.Quantity);
                ItemList.Add('FreeQty', 0);
                ItemList.Add('Unit', SILRec."Unit of Measure Code");
                ItemList.Add('UnitPrice', SILRec."Unit Price");
                ItemList.Add('TotAmt', SILRec."Line Amount");
                ItemList.Add('Discount', SILRec."Line Discount Amount");
                ItemList.Add('PreTaxVal', 0);
                ItemList.Add('AssAmt', SILRec.Amount);
                G_AssVal += SILRec.Amount;

                DetailedGSTLedgerEntryRec.Reset();
                DetailedGSTLedgerEntryRec.SetRange("Document No.", SILRec."Document No.");
                DetailedGSTLedgerEntryRec.SetRange("Document Line No.", SILRec."Line No.");
                if DetailedGSTLedgerEntryRec.FindFirst() then;
                Cnt := DetailedGSTLedgerEntryRec.Count;

                TotItemVal := SILRec.Amount;


                ItemList.Add('GstRt', DetailedGSTLedgerEntryRec."GST %");
                if Cnt = 1 then begin
                    ItemList.Add('IgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                    G_IgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_CgstVal += 0;
                    G_SgstVal += 0;


                    ItemList.Add('CgstAmt', 0);
                    ItemList.Add('SgstAmt', 0);
                end else begin
                    ItemList.Add('IgstAmt', 0);
                    ItemList.Add('CgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);
                    ItemList.Add('SgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1 * 2;

                    G_IgstVal += 0;
                    G_CgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_SgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                end;

                ItemList.Add('CesRt', 0);
                ItemList.Add('CesAmt', 0);
                ItemList.Add('CesNonAdvlAmt', 0);
                ItemList.Add('StateCesRt', 0);
                ItemList.Add('StateCesAmt', 0);
                ItemList.Add('StateCesNonAdvlAmt', 0);
                ItemList.Add('OthChrg', 0);
                ItemList.Add('TotItemVal', TotItemVal);
                G_TotItemVal += TotItemVal;
                ItemListArr.Add(ItemList);
                Ln += 1;
            until SILRec.Next() = 0;
        end;
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', G_AssVal);
        ValDtls.Add('CgstVal', G_CgstVal);
        ValDtls.Add('SgstVal', G_SgstVal);
        ValDtls.Add('IgstVal', G_IgstVal);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', G_TotItemVal);
        MainJson.Add('ValDtls', ValDtls);
        MainJson.WriteTo(JsonData);
        exit(JsonData);
        //end;
    end;
    /////////////////////////// End Cancel IRN //////////////////////////////////////// MC 17012025   

    ////////////////////////  CreateJSONFor Unposted Sales Header ////////////////////////// 02/05/2024AA
    local procedure CreateJSONForSHEInvoice(SHRec: Record "Sales Header"): Text;
    var
        SILRec: Record "Sales Line";
        CompRec: Record "Company Information";
        StateRec: Record State;
        CustRec: Record Customer;
        DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;

        Cnt: Integer;
        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];
        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;

    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        if CustRec.get(SHRec."Sell-to Customer No.") then;

        //if SIHRec.FindFirst() then begin



        //TranDtls
        TranDtls.Add('TaxSch', 'GST');
        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            TranDtls.Add('SupTyp', 'EXPWOP');
        end else begin
            TranDtls.Add('SupTyp', 'B2B');
        end;

        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');
        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', SHRec."No.");
        DocDtls.Add('Dt', FORMAT(SHRec."Posting Date", 10, '<Day,2>/<Month,2>/<Year4>'));
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', CompRec."GST Registration No.");
        SellerDtls.Add('LglNm', CompRec.Name);
        SellerDtls.Add('Addr1', CompRec.Address);
        SellerDtls.Add('Loc', CompRec.City);
        if CompRec."Post Code" = '' then
            Evaluate(SellerDtlsPin, '0')
        else
            Evaluate(SellerDtlsPin, CompRec."Post Code");

        SellerDtls.Add('Pin', SellerDtlsPin);
        SellerDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('SellerDtls', SellerDtls);

        //BuyerDtls

        if CustRec.get(SHRec."Sell-to Customer No.") then;
        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls_Stcd := '96';
            BuyerDtls.Add('Gstin', 'URP');
        end else begin
            BuyerDtls.Add('Gstin', CustRec."GST Registration No.");
        end;

        BuyerDtls.Add('LglNm', CustRec.Name);
        BuyerDtls.Add('Pos', BuyerDtls_Stcd);
        BuyerDtls.Add('Addr1', CustRec.Address);
        BuyerDtls.Add('Loc', CustRec.City);
        if CustRec."Post Code" = '' then
            Evaluate(BuyerDtlsPin, '0')
        else
            Evaluate(BuyerDtlsPin, CustRec."Post Code");

        if (CustRec."Gen. Bus. Posting Group" = 'EXPORT') oR (CustRec."State Code" = 'OT') then begin
            BuyerDtls.Add('Pin', 999999);
        END ELSE begin
            BuyerDtls.Add('Pin', BuyerDtlsPin);
        end;

        BuyerDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', CompRec.Name);
        DispDtls.Add('Addr1', CompRec.Address);
        DispDtls.Add('Loc', CompRec.City);
        if CompRec."Post Code" = '' then
            Evaluate(DispDtlsPin, '0')
        else
            Evaluate(DispDtlsPin, CompRec."Post Code");

        DispDtls.Add('Pin', DispDtlsPin);
        DispDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', CustRec."GST Registration No.");
        ShipDtls.Add('LglNm', SHRec."Ship-to Name");
        //ShipDtls.Add('Addr1', StringConversionManagementCU.RemoveNonAlphaNumericCharacters(SIHRec."Ship-to Address"));
        ShipDtls.Add('Addr1', DeleteSpecialChars(SHRec."Ship-to Address"));

        ShipDtls.Add('Loc', SHRec."Ship-to City");
        //mc04092024
        // if SHRec."Ship-to Post Code" = '' then
        //     Evaluate(ShipDtlsPin, '0')
        // else
        Evaluate(ShipDtlsPin, SHRec."Ship-to Post Code");


        ShipDtls.Add('Pin', ShipDtlsPin);
        ShipDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 


        //////Create JSON Line Item /////////////////////////////
        //ItemListArr Line Data
        Ln := 1;
        SILRec.Reset();
        SILRec.SetRange("Document Type", SHRec."Document Type");
        SILRec.SetRange("Document No.", SHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');

        if SILRec.FindFirst() then begin
            Clear(ItemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;

            repeat
                Clear(ItemList);
                ItemCode := 0;
                //ItemNo := SILRec."No.";
                //ReplaceString;
                //ItemNo := ReplaceString(ItemNo, '-', '');
                // ItemNo := ReplaceString(ItemNo, '/', '');
                // ItemNo := ReplaceString(ItemNo, '\', '');
                ItemList.Add('ItemNo', ItemCode);
                //ItemList.Add('SlNo', SILRec."Line No.");
                ItemList.Add('SlNo', Format(Ln));

                if (SILRec.Type = SILRec.Type::"G/L Account") then begin
                    ItemList.Add('IsServc', 'Y');
                end else begin
                    ItemList.Add('IsServc', 'N');
                end;
                ItemList.Add('PrdDesc', SILRec.Description);
                ItemList.Add('HsnCd', SILRec."HSN/SAC Code");
                ItemList.Add('Qty', SILRec.Quantity);
                ItemList.Add('FreeQty', 0);
                ItemList.Add('Unit', SILRec."Unit of Measure Code");
                ItemList.Add('UnitPrice', SILRec."Unit Price");
                ItemList.Add('TotAmt', SILRec."Line Amount");
                ItemList.Add('Discount', SILRec."Line Discount Amount");
                ItemList.Add('PreTaxVal', 0);
                ItemList.Add('AssAmt', SILRec.Amount);
                G_AssVal += SILRec.Amount;

                //FC 120824 +
                if SHRec."GST Bill-to State Code" <> SHRec."Location State Code" then begin

                    ItemList.Add('GstRt', GetIGSTAmount(SILRec.RecordId, 1));


                    TotItemVal := GetIGSTAmount(SILRec.RecordId, 0);

                    ItemList.Add('IgstAmt', ROUND(ABS(TotItemVal), 0.01, '='));

                    TotItemVal := SILRec.Amount + ROUND(ABS(TotItemVal), 0.01, '=');

                    G_IgstVal += ROUND(ABS(GetIGSTAmount(SILRec.RecordId, 0)), 0.01, '=');
                    G_CgstVal += 0;
                    G_SgstVal += 0;


                    ItemList.Add('CgstAmt', 0);
                    ItemList.Add('SgstAmt', 0);
                end else begin

                    TotItemVal := GetCGSTAmount(SILRec.RecordId, 1);

                    ItemList.Add('GstRt', TotItemVal * 2);

                    ItemList.Add('IgstAmt', 0);

                    //FORMAT(ROUND(ABS(GetSGSTAmount(SILRec.RecordId, 0)),0.01,'='))

                    ItemList.Add('CgstAmt', ROUND(ABS(GetCGSTAmount(SILRec.RecordId, 0)), 0.01, '='));
                    ItemList.Add('SgstAmt', ROUND(ABS(GetSGSTAmount(SILRec.RecordId, 0)), 0.01, '='));

                    TotItemVal := SILRec.Amount + ROUND(ABS(GetCGSTAmount(SILRec.RecordId, 0)), 0.01, '=') + ROUND(ABS(GetSGSTAmount(SILRec.RecordId, 0)), 0.01, '=');

                    G_IgstVal += 0;
                    G_CgstVal += ROUND(ABS(GetCGSTAmount(SILRec.RecordId, 0)), 0.01, '=');
                    G_SgstVal += ROUND(ABS(GetSGSTAmount(SILRec.RecordId, 0)), 0.01, '=');

                end;

                //FC 120824 -



                ItemList.Add('CesRt', 0);
                ItemList.Add('CesAmt', 0);
                ItemList.Add('CesNonAdvlAmt', 0);
                ItemList.Add('StateCesRt', 0);
                ItemList.Add('StateCesAmt', 0);
                ItemList.Add('StateCesNonAdvlAmt', 0);
                ItemList.Add('OthChrg', 0);
                ItemList.Add('TotItemVal', TotItemVal);
                G_TotItemVal += TotItemVal;
                ItemListArr.Add(ItemList);
                Ln += 1;
            until SILRec.Next() = 0;
        end;
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', G_AssVal);
        ValDtls.Add('CgstVal', G_CgstVal);
        ValDtls.Add('SgstVal', G_SgstVal);
        ValDtls.Add('IgstVal', G_IgstVal);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', G_TotItemVal);
        MainJson.Add('ValDtls', ValDtls);
        MainJson.WriteTo(JsonData);
        exit(JsonData);
        //end;
    end;

    local procedure CreateJSONEWayBillIRN(SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        StateRec: Record State;
        CustRec: Record Customer;
        DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;
        EwbDtls: JsonObject;

        Cnt: Integer;



        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];


        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;

    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        //if SIHRec.FindFirst() then begin

        //TranDtls
        TranDtls.Add('TaxSch', 'GST');
        TranDtls.Add('SupTyp', 'B2B');
        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');
        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', SIHRec."No.");
        DocDtls.Add('Dt', SIHRec."Posting Date");
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', CompRec."GST Registration No.");
        SellerDtls.Add('LglNm', CompRec.Name);
        SellerDtls.Add('Addr1', CompRec.Address);
        SellerDtls.Add('Loc', CompRec.City);
        Evaluate(SellerDtlsPin, CompRec."Post Code");
        SellerDtls.Add('Pin', SellerDtlsPin);
        SellerDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('SellerDtls', SellerDtls);

        //BuyerDtls

        if CustRec.get(SIHRec."Sell-to Customer No.") then;
        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        BuyerDtls.Add('Gstin', CustRec."GST Registration No.");
        BuyerDtls.Add('LglNm', CustRec.Name);
        BuyerDtls.Add('Pos', BuyerDtls_Stcd);
        BuyerDtls.Add('Addr1', CustRec.Address);
        BuyerDtls.Add('Loc', CustRec.City);
        Evaluate(BuyerDtlsPin, CustRec."Post Code");
        BuyerDtls.Add('Pin', BuyerDtlsPin);
        BuyerDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', CompRec.Name);
        DispDtls.Add('Addr1', CompRec.Address);
        DispDtls.Add('Loc', CompRec.City);
        Evaluate(DispDtlsPin, CompRec."Post Code");
        DispDtls.Add('Pin', DispDtlsPin);
        DispDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', CustRec."GST Registration No.");
        ShipDtls.Add('LglNm', SIHRec."Ship-to Name");
        //ShipDtls.Add('Addr1', StringConversionManagementCU.RemoveNonAlphaNumericCharacters(SIHRec."Ship-to Address"));
        ShipDtls.Add('Addr1', DeleteSpecialChars(SIHRec."Ship-to Address"));

        ShipDtls.Add('Loc', SIHRec."Ship-to City");
        Evaluate(ShipDtlsPin, SIHRec."Ship-to Post Code");
        ShipDtls.Add('Pin', ShipDtlsPin);
        ShipDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 


        //////Create JSON Line Item /////////////////////////////
        //ItemListArr Line Data
        SILRec.Reset();
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');

        if SILRec.FindFirst() then begin
            Clear(ItemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;

            repeat
                Clear(ItemList);
                ItemCode := 0;
                //ItemNo := SILRec."No.";
                //ReplaceString;
                //ItemNo := ReplaceString(ItemNo, '-', '');
                // ItemNo := ReplaceString(ItemNo, '/', '');
                // ItemNo := ReplaceString(ItemNo, '\', '');
                ItemList.Add('ItemNo', ItemCode);
                //ItemList.Add('SlNo', SILRec."Line No.");
                ItemList.Add('SlNo', Format(Ln));

                if (SILRec.Type = SILRec.Type::"G/L Account") then begin
                    ItemList.Add('IsServc', 'Y');
                end else begin
                    ItemList.Add('IsServc', 'N');
                end;
                ItemList.Add('PrdDesc', SILRec.Description);
                ItemList.Add('HsnCd', SILRec."HSN/SAC Code");
                ItemList.Add('Qty', SILRec.Quantity);
                ItemList.Add('FreeQty', 0);
                ItemList.Add('Unit', SILRec."Unit of Measure Code");
                ItemList.Add('UnitPrice', SILRec."Unit Price");
                ItemList.Add('TotAmt', SILRec."Line Amount");
                ItemList.Add('Discount', SILRec."Line Discount Amount");
                ItemList.Add('PreTaxVal', 0);
                ItemList.Add('AssAmt', SILRec.Amount);
                G_AssVal += SILRec.Amount;

                DetailedGSTLedgerEntryRec.Reset();
                DetailedGSTLedgerEntryRec.SetRange("Document No.", SILRec."Document No.");
                DetailedGSTLedgerEntryRec.SetRange("Document Line No.", SILRec."Line No.");
                if DetailedGSTLedgerEntryRec.FindFirst() then;
                Cnt := DetailedGSTLedgerEntryRec.Count;

                TotItemVal := SILRec.Amount;


                ItemList.Add('GstRt', DetailedGSTLedgerEntryRec."GST %");
                if Cnt = 1 then begin
                    ItemList.Add('IgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                    G_IgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_CgstVal += 0;
                    G_SgstVal += 0;


                    ItemList.Add('CgstAmt', 0);
                    ItemList.Add('SgstAmt', 0);
                end else begin
                    ItemList.Add('IgstAmt', 0);
                    ItemList.Add('CgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);
                    ItemList.Add('SgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1 * 2;

                    G_IgstVal += 0;
                    G_CgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_SgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                end;

                ItemList.Add('CesRt', 0);
                ItemList.Add('CesAmt', 0);
                ItemList.Add('CesNonAdvlAmt', 0);
                ItemList.Add('StateCesRt', 0);
                ItemList.Add('StateCesAmt', 0);
                ItemList.Add('StateCesNonAdvlAmt', 0);
                ItemList.Add('OthChrg', 0);
                ItemList.Add('TotItemVal', TotItemVal);
                G_TotItemVal += TotItemVal;
                ItemListArr.Add(ItemList);
            until SILRec.Next() = 0;
        end;
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', G_AssVal);
        ValDtls.Add('CgstVal', G_CgstVal);
        ValDtls.Add('SgstVal', G_SgstVal);
        ValDtls.Add('IgstVal', G_IgstVal);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', G_TotItemVal);
        MainJson.Add('ValDtls', ValDtls);
        //EwbDtls
        EwbDtls.Add('TransId', '21ADAPP6261D1Z1');
        EwbDtls.Add('TransName', 'Just in time Shippers Pvt Limited');
        EwbDtls.Add('TransMode', '1');
        EwbDtls.Add('Distance', '0');
        EwbDtls.Add('VehNo', 'KA331234');
        EwbDtls.Add('VehType', 'R');
        MainJson.Add('EwbDtls', EwbDtls);
        MainJson.WriteTo(JsonData);
        exit(JsonData);
        //end;
    end;

    local procedure CreateJSONCancelEWayBillonIRN(SIHRec: Record "Sales Invoice Header"): Text;
    var
        SILRec: Record "Sales Invoice Line";
        CompRec: Record "Company Information";
        StateRec: Record State;
        CustRec: Record Customer;
        DetailedGSTLedgerEntryRec: Record "Detailed GST Ledger Entry";
        TotItemVal: Decimal;
        G_TotItemVal: Decimal;
        StringConversionManagementCU: Codeunit StringConversionManagement;

        G_AssVal: Decimal;
        G_CgstVal: Decimal;
        G_SgstVal: Decimal;
        G_IgstVal: Decimal;
        EwbDtls: JsonObject;

        Cnt: Integer;



        SellerDtls_Stcd: Code[20];
        BuyerDtls_Stcd: code[20];


        TranDtls: JsonObject;
        JsonData: Text;
        MainJson: JsonObject;
        DocDtls: JsonObject;
        SellerDtls: JsonObject;
        BuyerDtls: JsonObject;
        DispDtls: JsonObject;
        ShipDtls: JsonObject;
        ItemListArr: JsonArray;
        ItemList: JsonObject;
        ValDtls: JsonObject;
        SellerDtlsPin: Integer;
        BuyerDtlsPin: Integer;
        DispDtlsPin: Integer;
        ShipDtlsPin: Integer;
        Ln: Integer;
        ItemNo: Code[20];
        ItemCode: Integer;

    begin
        Clear(TranDtls);
        Clear(DocDtls);
        Clear(SellerDtls);
        Clear(BuyerDtls);
        Clear(DispDtls);
        Clear(ShipDtls);
        Clear(ItemListArr);
        Clear(ItemList);
        Clear(ValDtls);

        ////////// Get Sellr Detl////////
        if CompRec.FindFirst() then;
        SellerDtls_Stcd := '';
        if StateRec.Get(CompRec."State Code") THEN begin
            SellerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        //if SIHRec.FindFirst() then begin



        //TranDtls
        TranDtls.Add('TaxSch', 'GST');
        TranDtls.Add('SupTyp', 'B2B');
        TranDtls.Add('RegRev', 'N');
        TranDtls.Add('IgstOnIntra', 'N');
        MainJson.Add('Version', '1.1');
        MainJson.Add('TranDtls', TranDtls);
        //MainJson.WriteTo(JsonData);

        //DocDtls
        DocDtls.Add('Typ', 'INV');
        DocDtls.Add('No', SIHRec."No.");
        DocDtls.Add('Dt', FORMAT(SIHRec."Posting Date", 10, '<Day,2>/<Month,2>/<Year4>'));
        //DocDtls.Add('Dt', SIHRec."Posting Date");
        MainJson.Add('DocDtls', DocDtls);


        //SellerDtls
        SellerDtls.Add('Gstin', CompRec."GST Registration No.");
        SellerDtls.Add('LglNm', CompRec.Name);
        SellerDtls.Add('Addr1', CompRec.Address);
        SellerDtls.Add('Loc', CompRec.City);
        Evaluate(SellerDtlsPin, CompRec."Post Code");
        SellerDtls.Add('Pin', SellerDtlsPin);
        SellerDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('SellerDtls', SellerDtls);

        //BuyerDtls

        if CustRec.get(SIHRec."Sell-to Customer No.") then;
        if StateRec.Get(CustRec."State Code") THEN begin
            BuyerDtls_Stcd := StateRec."State Code (GST Reg. No.)";
        end;


        BuyerDtls.Add('Gstin', CustRec."GST Registration No.");
        BuyerDtls.Add('LglNm', CustRec.Name);
        BuyerDtls.Add('Pos', BuyerDtls_Stcd);
        BuyerDtls.Add('Addr1', CustRec.Address);
        BuyerDtls.Add('Loc', CustRec.City);
        Evaluate(BuyerDtlsPin, CustRec."Post Code");
        BuyerDtls.Add('Pin', BuyerDtlsPin);
        BuyerDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('BuyerDtls', BuyerDtls);


        //DispDtls
        DispDtls.Add('Nm', CompRec.Name);
        DispDtls.Add('Addr1', CompRec.Address);
        DispDtls.Add('Loc', CompRec.City);
        Evaluate(DispDtlsPin, CompRec."Post Code");
        DispDtls.Add('Pin', DispDtlsPin);
        DispDtls.Add('Stcd', SellerDtls_Stcd);
        MainJson.Add('DispDtls', DispDtls);

        //ShipDtls
        ShipDtls.Add('Gstin', CustRec."GST Registration No.");
        ShipDtls.Add('LglNm', SIHRec."Ship-to Name");
        //ShipDtls.Add('Addr1', StringConversionManagementCU.RemoveNonAlphaNumericCharacters(SIHRec."Ship-to Address"));
        ShipDtls.Add('Addr1', DeleteSpecialChars(SIHRec."Ship-to Address"));

        ShipDtls.Add('Loc', SIHRec."Ship-to City");
        Evaluate(ShipDtlsPin, SIHRec."Ship-to Post Code");
        ShipDtls.Add('Pin', ShipDtlsPin);
        ShipDtls.Add('Stcd', BuyerDtls_Stcd);
        MainJson.Add('ShipDtls', ShipDtls);
        //MainJson.WriteTo(JsonData); 


        //////Create JSON Line Item /////////////////////////////
        //ItemListArr Line Data
        SILRec.Reset();
        SILRec.SetRange("Document No.", SIHRec."No.");
        SILRec.SetFilter(Quantity, '<>%1', 0);
        SILRec.SetFilter("No.", '<>%1', '');
        if SILRec.FindFirst() then begin
            Clear(ItemListArr);
            G_CgstVal := 0;
            G_SgstVal := 0;
            G_IgstVal := 0;

            repeat
                Clear(ItemList);
                ItemCode := 0;
                //ItemNo := SILRec."No.";
                //ReplaceString;
                //ItemNo := ReplaceString(ItemNo, '-', '');
                // ItemNo := ReplaceString(ItemNo, '/', '');
                // ItemNo := ReplaceString(ItemNo, '\', '');
                ItemList.Add('ItemNo', ItemCode);
                //ItemList.Add('SlNo', SILRec."Line No.");
                ItemList.Add('SlNo', Format(Ln));

                if (SILRec.Type = SILRec.Type::"G/L Account") then begin
                    ItemList.Add('IsServc', 'Y');
                end else begin
                    ItemList.Add('IsServc', 'N');
                end;
                ItemList.Add('PrdDesc', SILRec.Description);
                ItemList.Add('HsnCd', SILRec."HSN/SAC Code");
                ItemList.Add('Qty', SILRec.Quantity);
                ItemList.Add('FreeQty', 0);
                ItemList.Add('Unit', SILRec."Unit of Measure Code");
                ItemList.Add('UnitPrice', SILRec."Unit Price");
                ItemList.Add('TotAmt', SILRec."Line Amount");
                ItemList.Add('Discount', SILRec."Line Discount Amount");
                ItemList.Add('PreTaxVal', 0);
                ItemList.Add('AssAmt', SILRec.Amount);
                G_AssVal += SILRec.Amount;

                DetailedGSTLedgerEntryRec.Reset();
                DetailedGSTLedgerEntryRec.SetRange("Document No.", SILRec."Document No.");
                DetailedGSTLedgerEntryRec.SetRange("Document Line No.", SILRec."Line No.");
                if DetailedGSTLedgerEntryRec.FindFirst() then;
                Cnt := DetailedGSTLedgerEntryRec.Count;

                TotItemVal := SILRec.Amount;


                ItemList.Add('GstRt', DetailedGSTLedgerEntryRec."GST %");
                if Cnt = 1 then begin
                    ItemList.Add('IgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                    G_IgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_CgstVal += 0;
                    G_SgstVal += 0;


                    ItemList.Add('CgstAmt', 0);
                    ItemList.Add('SgstAmt', 0);
                end else begin
                    ItemList.Add('IgstAmt', 0);
                    ItemList.Add('CgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);
                    ItemList.Add('SgstAmt', DetailedGSTLedgerEntryRec."GST Amount" * -1);

                    TotItemVal += DetailedGSTLedgerEntryRec."GST Amount" * -1 * 2;

                    G_IgstVal += 0;
                    G_CgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;
                    G_SgstVal += DetailedGSTLedgerEntryRec."GST Amount" * -1;

                end;

                ItemList.Add('CesRt', 0);
                ItemList.Add('CesAmt', 0);
                ItemList.Add('CesNonAdvlAmt', 0);
                ItemList.Add('StateCesRt', 0);
                ItemList.Add('StateCesAmt', 0);
                ItemList.Add('StateCesNonAdvlAmt', 0);
                ItemList.Add('OthChrg', 0);
                ItemList.Add('TotItemVal', TotItemVal);
                G_TotItemVal += TotItemVal;
                ItemListArr.Add(ItemList);
            until SILRec.Next() = 0;
        end;
        MainJson.Add('ItemList', ItemListArr);

        //ValDtls
        ValDtls.Add('AssVal', G_AssVal);
        ValDtls.Add('CgstVal', G_CgstVal);
        ValDtls.Add('SgstVal', G_SgstVal);
        ValDtls.Add('IgstVal', G_IgstVal);
        ValDtls.Add('CesVal', 0);
        ValDtls.Add('StCesVal', 0);
        ValDtls.Add('Discount', 0);
        ValDtls.Add('OthChrg', 0);
        ValDtls.Add('RndOffAmt', 0);
        ValDtls.Add('TotInvVal', G_TotItemVal);
        MainJson.Add('ValDtls', ValDtls);
        //EwbDtls
        // EwbDtls.Add('TransId', '21ADAPP6261D1Z1');
        // EwbDtls.Add('TransName', 'Just in time Shippers Pvt Limited');
        // EwbDtls.Add('TransMode', '1');
        // EwbDtls.Add('Distance', '0');
        // EwbDtls.Add('VehNo', 'KA331234');
        // EwbDtls.Add('VehType', 'R');
        // MainJson.Add('EwbDtls', EwbDtls);
        MainJson.WriteTo(JsonData);
        exit(JsonData);
        //end;
    end;


    local procedure CreateJSON2(): Text;
    var
        JArray: JsonArray;
        JsonObject: JsonObject;
        TranDtlsObject: JsonObject;
        TransactionObject: JsonObject;
        JsonData: Text;
    begin
        Clear(JArray);
        Clear(JsonObject);
        Clear(TranDtlsObject);
        Clear(TransactionObject);
        TranDtlsObject.Add('TaxSch', 'GST');
        TranDtlsObject.Add('SupTyp', 'B2B');
        TranDtlsObject.Add('RegRev', 'Y');
        TranDtlsObject.Add('EcmGstin', '');
        TranDtlsObject.Add('IgstOnIntra', 'N');
        TransactionObject.Add('Version', '1.1');
        TransactionObject.Add('TranDtls', TranDtlsObject);
        JsonObject.Add('transaction', TransactionObject);
        JArray.Add(JsonObject);
        JArray.WriteTo(JsonData);
        exit(JsonData);
    end;

    local procedure DeleteSpecialChars(var yourText: Text): Text;
    var
        AllowedChars: Text;
    begin
        AllowedChars := ' /abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789';
        exit(DelChr(yourText, '=', DELCHR(yourText, '=', AllowedChars)));
    end;

    procedure SetRequestText(var EInvoiceHistroyRec: Record EInvoiceHistory; RequestText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(EInvoiceHistroyRec."Request Text");
        EInvoiceHistroyRec."Request Text".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(RequestText);
        EInvoiceHistroyRec.Modify(True);
    end;

    procedure SetResponseText(var EInvoiceHistroyRec: Record EInvoiceHistory; ResponseText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(EInvoiceHistroyRec."Response Text");
        EInvoiceHistroyRec."Response Text".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(ResponseText);
        EInvoiceHistroyRec.Modify(True);
    end;

    //////////////////////////// SignedInvoice //////////////////////////////////////////
    procedure SetSignedInvoiceText(var EInvoiceRec: Record EInvoice; SignedInvoiceText: Text)
    var
        OutStream: OutStream;
    begin
        Clear(EInvoiceRec.SignedInvoice);
        EInvoiceRec.SignedInvoice.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(SignedInvoiceText);
        EInvoiceRec.Modify(True);
    end;

    procedure ReplaceString(String: Text[250]; FindWhat: Text[250]; ReplaceWith: Text[250]) NewString: Text[250]
    var
    begin
        WHILE STRPOS(String, FindWhat) > 0 DO
            String := DELSTR(String, STRPOS(String, FindWhat)) + ReplaceWith + COPYSTR(String, STRPOS(String, FindWhat) + STRLEN(FindWhat));
        NewString := String;
    end;

    procedure GetGSTBaseAmount(RecordIDRec: recordid): decimal
    var
        TaxTransactionRec: Record "Tax Transaction Value";
        BaseValue: Decimal;
    begin
        TaxTransactionRec.reset;
        TaxTransactionRec.SetRange("Tax Record ID", RecordIDRec);
        TaxTransactionRec.SetRange("Tax Type", 'GST');
        TaxTransactionRec.SetRange("Value Type", TaxTransactionRec."Value Type"::COMPONENT);
        TaxTransactionRec.SetRange("Value ID", 10);
        if TaxTransactionRec.FindFirst() then BaseValue := TaxTransactionRec.Amount else BaseValue := 0;
        exit(BaseValue);
    end;

    procedure GetIGSTAmount(RecordIDRec: recordid; Type: Option "0","1"): decimal
    var
        TaxTransactionRec: Record "Tax Transaction Value";
        TaxVal: Decimal;
    begin
        TaxTransactionRec.reset;
        TaxTransactionRec.SetRange("Tax Record ID", RecordIDRec);
        TaxTransactionRec.SetRange("Tax Type", 'GST');
        TaxTransactionRec.SetRange("Value Type", TaxTransactionRec."Value Type"::COMPONENT);
        TaxTransactionRec.SetRange("Value ID", 3);
        if TaxTransactionRec.FindFirst() then begin
            if type = type::"0" then TaxVal := TaxTransactionRec.Amount;
            if Type = type::"1" then TaxVal := TaxTransactionRec.Percent;
        end;
        exit(TaxVal);
    end;


    procedure GetCGSTAmount(RecordIDRec: recordid; Type: Option "0","1"): decimal
    var
        TaxTransactionRec: Record "Tax Transaction Value";
        TaxVal: Decimal;
    begin
        TaxTransactionRec.reset;
        TaxTransactionRec.SetRange("Tax Record ID", RecordIDRec);
        TaxTransactionRec.SetRange("Tax Type", 'GST');
        TaxTransactionRec.SetRange("Value Type", TaxTransactionRec."Value Type"::COMPONENT);
        TaxTransactionRec.SetRange("Value ID", 2);
        if TaxTransactionRec.FindFirst() then begin
            if type = type::"0" then TaxVal := TaxTransactionRec.Amount;
            if Type = type::"1" then TaxVal := TaxTransactionRec.Percent;
        end;
        exit(TaxVal);
    end;


    procedure GetSGSTAmount(RecordIDRec: recordid; Type: Option "0","1"): decimal
    var
        TaxTransactionRec: Record "Tax Transaction Value";
        TaxVal: Decimal;
    begin
        TaxTransactionRec.reset;
        TaxTransactionRec.SetRange("Tax Record ID", RecordIDRec);
        TaxTransactionRec.SetRange("Tax Type", 'GST');
        TaxTransactionRec.SetRange("Value Type", TaxTransactionRec."Value Type"::COMPONENT);
        TaxTransactionRec.SetRange("Value ID", 6);
        if TaxTransactionRec.FindFirst() then begin
            if type = type::"0" then TaxVal := TaxTransactionRec.Amount;
            if Type = type::"1" then TaxVal := TaxTransactionRec.Percent;
        end;
        exit(TaxVal);
    end;
    */

}
